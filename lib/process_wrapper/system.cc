#include "lib/process_wrapper/system.h"

#if defined(RTW_WIN_UNICODE)
#include <codecvt>
#include <locale>
#endif  // defined(RTW_WIN_UNICODE)

namespace process_wrapper {

System::StrType System::FromUtf8(const std::string& string) {
#if defined(RTW_WIN_UNICODE)
  return std::wstring_convert<std::codecvt_utf8<wchar_t>>().from_bytes(string);
#else
  return string;
#endif  // defined(RTW_WIN_UNICODE)
}

std::string System::ToUtf8(const System::StrType& string) {
#if defined(RTW_WIN_UNICODE)
  return std::wstring_convert<std::codecvt_utf8<wchar_t>>().to_bytes(string);
#else
  return string;
#endif  // defined(RTW_WIN_UNICODE)
}

}  // namespace process_wrapper
