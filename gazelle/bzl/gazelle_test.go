package bzl

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

import (
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	"github.com/bazelbuild/bazel-gazelle/testtools"
	"github.com/bazelbuild/rules_go/go/tools/bazel"
)

var gazellePath = findGazelle()

const testDataPath = "gazelle/bzl/testdata/"

// TestGazelleBinary runs a gazelle binary with starlib installed on each
// directory in `testdata/*`. Please see `testdata/README.md` for more
// information on each test.
func TestGazelleBinary(t *testing.T) {
	tests := map[string][]bazel.RunfileEntry{}

	files, err := bazel.ListRunfiles()
	if err != nil {
		t.Fatalf("bazel.ListRunfiles() error: %v", err)
	}
	for _, f := range files {
		if strings.HasPrefix(f.ShortPath, testDataPath) {
			relativePath := strings.TrimPrefix(f.ShortPath, testDataPath)
			parts := strings.SplitN(relativePath, "/", 2)
			if len(parts) < 2 {
				// This file is not a part of a testcase since it must be in a dir that
				// is the test case and then have a path inside of that.
				continue
			}

			tests[parts[0]] = append(tests[parts[0]], f)
		}
	}
	if len(tests) == 0 {
		t.Fatal("no tests found")
	}

	for testName, files := range tests {
		testPath(t, testName, files)
	}
}

func testPath(t *testing.T, name string, files []bazel.RunfileEntry) {
	t.Run(name, func(t *testing.T) {
		var inputs []testtools.FileSpec
		var goldens []testtools.FileSpec

		for _, f := range files {
			path := f.Path
			trim := testDataPath + name + "/"
			shortPath := strings.TrimPrefix(f.ShortPath, trim)
			info, err := os.Stat(path)
			if err != nil {
				t.Fatalf("os.Stat(%q) error: %v", path, err)
			}

			// Skip dirs.
			if info.IsDir() {
				continue
			}

			content, err := ioutil.ReadFile(path)
			if err != nil {
				t.Errorf("ioutil.ReadFile(%q) error: %v", path, err)
			}

			// Now trim the common prefix off.
			if strings.HasSuffix(shortPath, ".in") {
				inputs = append(inputs, testtools.FileSpec{
					Path:    strings.TrimSuffix(shortPath, ".in"),
					Content: string(content),
				})
			} else if strings.HasSuffix(shortPath, ".out") {
				goldens = append(goldens, testtools.FileSpec{
					Path:    strings.TrimSuffix(shortPath, ".out"),
					Content: string(content),
				})
			} else {
				inputs = append(inputs, testtools.FileSpec{
					Path:    shortPath,
					Content: string(content),
				})
				goldens = append(goldens, testtools.FileSpec{
					Path:    shortPath,
					Content: string(content),
				})
			}
		}

		dir, cleanup := testtools.CreateFiles(t, inputs)
		defer cleanup()

		cmd := exec.Command(gazellePath, "-build_file_name=BUILD")
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		cmd.Dir = dir
		if err := cmd.Run(); err != nil {
			t.Fatal(err)
		}

		testtools.CheckFiles(t, dir, goldens)
		if t.Failed() {
			filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
				if err != nil {
					return err
				}
				t.Logf("%q exists", path)
				return nil
			})
		}
	})
}

func findGazelle() string {
	gazellePath, ok := bazel.FindBinary("gazelle/bzl", "gazelle-skylib")
	if !ok {
		panic("could not find gazelle binary")
	}
	return gazellePath
}
