//
//  FileSystem.h
//  Alune
//
//  Created by Jarrod Norwell on 10/4/2026.
//

#include <string>
#include <vector>

#include "common/Pcsx2Types.h"

namespace FileSystem {
int OpenFDFileContent(const char*);
bool OpenFDFileContent(const std::string&, int, s64, s64);
std::string GetValidDrive(const std::string&);
std::vector<std::string> GetOpticalDriveList();
}
