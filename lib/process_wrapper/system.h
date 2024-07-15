#ifndef RUST_PRIVATE_RUSTC_WRAPPER_SYSTEM_H_
#define RUST_PRIVATE_RUSTC_WRAPPER_SYSTEM_H_

#include <string>
#include <vector>

#if defined(_WIN32) && defined(UNICODE)
#define RTW_WIN_UNICODE
#endif  // defined(_WIN32) && defined(UNICODE)

#if defined(RTW_WIN_UNICODE)
#define RTW_SYS_STR_LITERAL(str) L##str
#else
#define RTW_SYS_STR_LITERAL(str) str
#endif

namespace process_wrapper {

class System {
 public:
#if defined(RTW_WIN_UNICODE)
  using StrType = std::wstring;
#else
  using StrType = std::string;
#endif  // defined(RTW_WIN_UNICODE)

  using Arguments = std::vector<StrType>;
  using EnvironmentBlock = std::vector<StrType>;

 public:
  // Converts to the system string format
  static StrType ToStrType(const std::string& string);

  // Joins an environment variable in a single string
  static StrType ComposeEnvironmentVariable(const StrType& key,
                                            const StrType& value);

  // Gets the working directory of the current process
  static StrType GetWorkingDirectory();

  // Joins paths using the system convention 
  static StrType JoinPaths(const StrType& path1, const StrType& path2);

  // Simple function to execute a process that inherits all the current
  // process handles.
  // Even if the function doesn't modify global state it is not reentrant
  // It is meant to be called once during the lifetime of the parent process
  static int Exec(const StrType& executable, const Arguments& arguments,
                  const EnvironmentBlock& environment_block);
};

}  // namespace process_wrapper

#endif  // RUST_PRIVATE_RUSTC_WRAPPER_SYSTEM_H_
