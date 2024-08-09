# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Unit testing support now lives in @rules_testing//lib:unittest.bzl. This version
  is deprecated and will be removed in the future.
  Please replace loads of @bazel_skylib//lib:unittest.bzl to @rules_testing//lib:unittest.bzl
  to reflect the new location of unittest.bzl"
"""

load(
    "@rules_testing//lib:unittest.bzl",
    _analysistest = "analysistest",
    _asserts = "asserts",
    _loadingtest = "loadingtest",
    _unittest = "unittest",
)

unittest = _unittest
analysistest = _analysistest
loadingtest = _loadingtest
asserts = _asserts
