//
//  CocoaTools.h
//  Alune
//
//  Created by Jarrod Norwell on 10/4/2026.
//

#include <string>

#include "common/WindowInfo.h"

#include "pcsx2/Config.h"

namespace CocoaTools {
void InhibitAppNap(const std::string&);
void UninhibitAppNap();
std::string GetBundlePath();
void* CreateMetalLayer(WindowInfo* wi);
void DestroyMetalLayer(WindowInfo* wi);

std::optional<std::string> GetResourcePath();
std::optional<std::string> GetNonTranslocatedBundlePath();
}
