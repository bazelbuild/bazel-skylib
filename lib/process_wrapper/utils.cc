#include "lib/process_wrapper/utils.h"

#include <fstream>
#include <iostream>
#include <streambuf>

#if defined(PW_WIN_UNICODE)
#include <codecvt>
#include <locale>
#endif  // defined(PW_WIN_UNICODE)

namespace process_wrapper {

System::StrType FromUtf8(const std::string& string) {
#if defined(PW_WIN_UNICODE)
  return std::wstring_convert<std::codecvt_utf8<wchar_t>>().from_bytes(string);
#else
  return string;
#endif  // defined(PW_WIN_UNICODE)
}

std::string ToUtf8(const System::StrType& string) {
#if defined(PW_WIN_UNICODE)
  return std::wstring_convert<std::codecvt_utf8<wchar_t>>().to_bytes(string);
#else
  return string;
#endif  // defined(PW_WIN_UNICODE)
}

void ReplaceToken(System::StrType& str, const System::StrType& token,
                  const System::StrType& replacement) {
  std::size_t pos = str.find(token);
  if (pos != std::string::npos) {
    str.replace(pos, token.size(), replacement);
  }
}

bool ReadFileToArray(const System::StrType& file_path,
                     System::StrVecType& vec) {
  std::ifstream file(file_path);
  if (file.fail()) {
    std::cerr << "Failed to open env file: " << ToUtf8(file_path) << std::endl;
    return false;
  }
  std::string line;
  while (std::getline(file, line)) {
    // handle CRLF files when as they might be
    // written on windows and read from linux
    if (!line.empty() && line.back() == '\r') {
      line.pop_back();
    }

    // Skip empty lines if any
    if (line.empty()) {
      continue;
    }

    vec.push_back(FromUtf8(line));
  }
  return true;
}  // namespace process_wrapper

}  // namespace process_wrapper
