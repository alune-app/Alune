//
//  IOCtlSrc.mm
//  Alune
//
//  Created by Jarrod Norwell on 10/4/2026.
//

#include <string>
#include <vector>

#include "pcsx2/CDVD/CDVDdiscReader.h"

IOCtlSrc::IOCtlSrc(std::string filename) {
    
}

IOCtlSrc::~IOCtlSrc() {
    
}
    
bool IOCtlSrc::Reopen(Error*) {
    return true;
}

u32 IOCtlSrc::GetSectorCount() const {
    return 0;
}

const std::vector<toc_entry>& IOCtlSrc::ReadTOC() const {
    static std::vector<toc_entry> entries;
    return entries;
}

bool IOCtlSrc::ReadSectors2048(u32, u32, u8*) const {
    return true;
}

bool IOCtlSrc::ReadSectors2352(u32, u32, u8*) const {
    return true;
}

bool IOCtlSrc::ReadTrackSubQ(cdvdSubQ*) const {
    return true;
}

u32 IOCtlSrc::GetLayerBreakAddress() const {
    return 0;
}

s32 IOCtlSrc::GetMediaType() const {
    return 0;
}

void IOCtlSrc::SetSpindleSpeed(bool) const {
    
}

bool IOCtlSrc::DiscReady() {
    return true;
}
