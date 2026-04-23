//
//  InputManager.h
//  Alune
//
//  Created by Jarrod Norwell on 10/4/2026.
//

#include <optional>
#include <string>
#include <string_view>

#include "common/Pcsx2Types.h"

namespace InputManager {
void Initialize();
void Shutdown();
void Update();
void SetRumble(int, u8, u8);
const char* ConvertHostKeyboardCodeToIcon(unsigned int);
std::optional<std::string> ConvertHostKeyboardCodeToString(unsigned int);
std::optional<unsigned int> ConvertHostKeyboardStringToCode(std::string_view);
}
