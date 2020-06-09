package gazelle

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

const base = "testdata"

// TestGazelleBinary runs a gazelle binary with starlib installed on each
// directory in `testdata/*`. Please see `testdata/README.md` for more
// information on each test.
func TestGazelleBinary(t *testing.T) {
	testdata, err := bazel.Runfile(base)
	if err != nil {
		t.Errorf("bazel.Runfile(%q) error: %v", base, err)
	}
	ds, err := ioutil.ReadDir(testdata)
	if err != nil {
		t.Errorf("ioutil.ReadDir(%q) error: %v", base, err)
	}
	for _, d := range ds {
		if d.IsDir() {
			t.Run(d.Name(), testPath(d.Name()))
		}
	}
}

func testPath(dir string) func(t *testing.T) {
	return func(t *testing.T) {
		var inputs []testtools.FileSpec
		var goldens []testtools.FileSpec

		if err := filepath.Walk(filepath.Join(base, dir), func(path string, info os.FileInfo, err error) error {
			// If you were called with an error, don't try to recover, just fail.
			if err != nil {
				return err
			}

			// Skip dirs.
			if info.IsDir() {
				return nil
			}

			content, err := ioutil.ReadFile(path)
			if err != nil {
				return err
			}

			// Now trim the common prefix off.
			newPath := strings.TrimPrefix(path, filepath.Join(base, dir)+"/")

			if strings.HasSuffix(newPath, ".in") {
				inputs = append(inputs, testtools.FileSpec{
					Path:    strings.TrimSuffix(newPath, ".in"),
					Content: string(content),
				})
			} else if strings.HasSuffix(newPath, ".out") {
				goldens = append(goldens, testtools.FileSpec{
					Path:    strings.TrimSuffix(newPath, ".out"),
					Content: string(content),
				})
			} else {
				inputs = append(inputs, testtools.FileSpec{
					Path:    newPath,
					Content: string(content),
				})
				goldens = append(goldens, testtools.FileSpec{
					Path:    newPath,
					Content: string(content),
				})
			}

			return nil
		}); err != nil {
			t.Errorf("filepath.Walk(%q) error: %v", filepath.Join(base, dir), err)
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
	}
}

func findGazelle() string {
	gazellePath, ok := bazel.FindBinary("gazelle", "gazelle-skylib")
	if !ok {
		panic("could not find gazelle binary")
	}
	return gazellePath
}
