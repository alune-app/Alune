//
//  FileSystem.mm
//  Alune
//
//  Created by Jarrod Norwell on 10/4/2026.
//

#import "FileSystem.h"

int FileSystem::OpenFDFileContent(const char*) {
    return 0;
}

bool FileSystem::OpenFDFileContent(const std::string&, int, s64, s64) {
    return true;
}

std::string FileSystem::GetValidDrive(const std::string&) {
    return std::string{};
}

std::vector<std::string> FileSystem::GetOpticalDriveList() {
    return {};
}
