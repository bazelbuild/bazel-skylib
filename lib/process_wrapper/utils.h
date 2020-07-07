#ifndef LIB_PROCESS_WRAPPER_UTILS_H_
#define LIB_PROCESS_WRAPPER_UTILS_H_

#include <string>

#include "lib/process_wrapper/system.h"

namespace process_wrapper {

// Converts to and frin the system string format
System::StrType FromUtf8(const std::string& string);
std::string ToUtf8(const System::StrType& string);

void ReplaceToken(System::StrType& str, const System::StrType& token,
                  const System::StrType& replacement);

bool ReadFileToArray(const System::StrType& file_path, System::StrVecType& vec);

}  // namespace process_wrapper

#endif  // LIB_PROCESS_WRAPPER_UTILS_H_