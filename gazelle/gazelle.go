/* Copyright 2020 The Bazel Authors. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Package gazelle generates a `bzl_library` target for every `.bzl` file in
// each package.
//
// The `bzl_library` rule is provided by
// https://github.com/bazelbuild/bazel-skylib.
//
// This extension is experimental and subject to change. It is not included
// in the default Gazelle binary.
package gazelle

import (
	"flag"
	"fmt"
	"io/ioutil"
	"path/filepath"
	"sort"
	"strings"

	"github.com/bazelbuild/bazel-gazelle/config"
	"github.com/bazelbuild/bazel-gazelle/label"
	"github.com/bazelbuild/bazel-gazelle/language"
	"github.com/bazelbuild/bazel-gazelle/repo"
	"github.com/bazelbuild/bazel-gazelle/resolve"
	"github.com/bazelbuild/bazel-gazelle/rule"

	"go.starlark.net/syntax"
)

const languageName = "starlark"
const fileType = ".bzl"

var ignoreSuffix = suffixes{
	"_tests.bzl",
	"_test.bzl",
}

type suffixes []string

func (s suffixes) Matches(test string) bool {
	for _, v := range s {
		if strings.HasSuffix(test, v) {
			return true
		}
	}
	return false
}

type bzlLibraryLang struct{}

// NewLanguage is called by Gazelle to install this language extension in a binary.
func NewLanguage() language.Language {
	return &bzlLibraryLang{}
}

// Name returns the name of the language. This should be a prefix of the
// kinds of rules generated by the language, e.g., "go" for the Go extension
// since it generates "go_library" rules.
func (*bzlLibraryLang) Name() string { return languageName }

// The following methods are implemented to satisfy the
// https://pkg.go.dev/github.com/bazelbuild/bazel-gazelle/resolve?tab=doc#Resolver
// interface, but are otherwise unused.
func (*bzlLibraryLang) RegisterFlags(fs *flag.FlagSet, cmd string, c *config.Config) {}
func (*bzlLibraryLang) CheckFlags(fs *flag.FlagSet, c *config.Config) error          { return nil }
func (*bzlLibraryLang) KnownDirectives() []string                                    { return nil }
func (*bzlLibraryLang) Configure(c *config.Config, rel string, f *rule.File)         {}

// Kinds returns a map of maps rule names (kinds) and information on how to
// match and merge attributes that may be found in rules of those kinds. All
// kinds of rules generated for this language may be found here.
func (*bzlLibraryLang) Kinds() map[string]rule.KindInfo {
	return kinds
}

// Loads returns .bzl files and symbols they define. Every rule generated by
// GenerateRules, now or in the past, should be loadable from one of these
// files.
func (*bzlLibraryLang) Loads() []rule.LoadInfo { return nil }

// Fix repairs deprecated usage of language-specific rules in f. This is
// called before the file is indexed. Unless c.ShouldFix is true, fixes
// that delete or rename rules should not be performed.
func (*bzlLibraryLang) Fix(c *config.Config, f *rule.File) {}

// Imports returns a list of ImportSpecs that can be used to import the rule
// r. This is used to populate RuleIndex.
//
// If nil is returned, the rule will not be indexed. If any non-nil slice is
// returned, including an empty slice, the rule will be indexed.
func (b *bzlLibraryLang) Imports(c *config.Config, r *rule.Rule, f *rule.File) []resolve.ImportSpec {
	srcs := r.AttrStrings("srcs")
	imports := make([]resolve.ImportSpec, len(srcs))

	for _, src := range srcs {
		spec := resolve.ImportSpec{
			// Lang is the language in which the import string appears (this should
			// match Resolver.Name).
			Lang: languageName,
			// Imp is an import string for the library.
			Imp: fmt.Sprintf("//%s:%s", f.Pkg, src),
		}

		imports = append(imports, spec)
	}

	return imports
}

// Embeds returns a list of labels of rules that the given rule embeds. If
// a rule is embedded by another importable rule of the same language, only
// the embedding rule will be indexed. The embedding rule will inherit
// the imports of the embedded rule.
// Since SkyLark doesn't support embedding this should always return nil.
func (*bzlLibraryLang) Embeds(r *rule.Rule, from label.Label) []label.Label { return nil }

// Resolve translates imported libraries for a given rule into Bazel
// dependencies. Information about imported libraries is returned for each
// rule generated by language.GenerateRules in
// language.GenerateResult.Imports. Resolve generates a "deps" attribute (or
// the appropriate language-specific equivalent) for each import according to
// language-specific rules and heuristics.
func (*bzlLibraryLang) Resolve(c *config.Config, ix *resolve.RuleIndex, rc *repo.RemoteCache, r *rule.Rule, importsRaw interface{}, from label.Label) {
	imports := importsRaw.([]string)

	r.DelAttr("deps")

	if len(imports) == 0 {
		return
	}

	deps := make([]string, 0, len(imports))
	for _, imp := range imports {
		if strings.HasPrefix(imp, "@") {
			// This is a dependency that is external to the current repo.
			deps = append(deps, strings.TrimSuffix(imp, fileType))
		} else {
			res := resolve.ImportSpec{
				Lang: languageName,
				Imp:  imp,
			}
			matches := ix.FindRulesByImport(res, languageName)
			fmt.Printf("ix: %v\n", ix)

			if len(matches) == 0 {
				fmt.Printf("Didn't find match for %q\n", imp)
			}

			for _, m := range matches {
				deps = append(deps, m.Label.String())
			}
		}
	}

	sort.Strings(deps)
	if len(deps) > 0 {
		r.SetAttr("deps", deps)
	}
}

var kinds = map[string]rule.KindInfo{
	"bzl_library": {
		NonEmptyAttrs:  map[string]bool{"srcs": true, "deps": true},
		MergeableAttrs: map[string]bool{"srcs": true},
	},
}

// GenerateRules extracts build metadata from source files in a directory.
// GenerateRules is called in each directory where an update is requested
// in depth-first post-order.
//
// args contains the arguments for GenerateRules. This is passed as a
// struct to avoid breaking implementations in the future when new
// fields are added.
//
// A GenerateResult struct is returned. Optional fields may be added to this
// type in the future.
//
// Any non-fatal errors this function encounters should be logged using
// log.Print.
func (*bzlLibraryLang) GenerateRules(args language.GenerateArgs) language.GenerateResult {
	var rules []*rule.Rule
	var imports []interface{}
	for _, f := range append(args.RegularFiles) {
		if ignoreSuffix.Matches(f) {
			continue
		}
		if strings.HasSuffix(f, fileType) {
			name := strings.TrimSuffix(f, fileType)
			r := rule.NewRule("bzl_library", name)

			r.SetAttr("srcs", []string{f})

			if args.File == nil || !args.File.HasDefaultVisibility() {
				var inPrivateDir bool
				for _, d := range strings.Split(args.Dir, string(filepath.Separator)) {
					if d == "private" {
						inPrivateDir = true
					}
				}
				if !inPrivateDir {
					r.SetAttr("visibility", []string{"//visibility:public"})
				}
			}

			fullPath := filepath.Join(args.Dir, f)
			loads, err := getBzlFileLoads(fullPath)
			if err != nil {
				fmt.Printf("Error getting getBzlFileLoads(%q, %q): %v", args.Dir, f, err)
				// Don't `continue` since it is reasonable to create a target even without deps.
			}
			fmt.Printf("loads: %v\n", loads)

			rules = append(rules, r)
			imports = append(imports, loads)
		}
	}
	return language.GenerateResult{
		Gen:     rules,
		Imports: imports,
	}
}

func getBzlFileLoads(path string) ([]string, error) {
	f, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("ioutil.ReadFile(%q) error: %v", path, err)
	}
	ast, err := syntax.Parse(path, f, 0644)
	if err != nil {
		return nil, fmt.Errorf("syntax.Parse(%q) error: %v", f, err)
	}

	var loads []string
	syntax.Walk(ast, func(n syntax.Node) bool {
		if l, ok := n.(*syntax.LoadStmt); ok {
			val, ok := l.Module.Value.(string)
			if !ok {
				fmt.Printf("The load statement at %s:%s is not a simple string. Therefore, bazel targets can not be generated automatically for it.", path, l.Module.TokenPos)
				return true
			}
			loads = append(loads, val)
		}
		return true
	})
	sort.Strings(loads)

	return loads, nil
}
