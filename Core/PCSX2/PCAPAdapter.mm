//
//  PCAPAdapter.m
//  Alune
//
//  Created by Jarrod Norwell on 10/4/2026.
//

#include "pcsx2/DEV9/pcap_io.h"

PCAPAdapter::PCAPAdapter() {
    
}

PCAPAdapter::~PCAPAdapter() {
    
}

bool PCAPAdapter::blocks() {
    return false;
}

bool PCAPAdapter::isInitialised() {
    return false;
}

bool PCAPAdapter::recv(NetPacket*) {
    return false;
}

bool PCAPAdapter::send(NetPacket*) {
    return false;
}

void PCAPAdapter::reloadSettings() {
    
}

std::vector<AdapterEntry> PCAPAdapter::GetAdapters() {
    return {};
}

AdapterOptions PCAPAdapter::GetAdapterOptions() {
    return {};
}

bool PCAPAdapter::InitPCAP(const std::string&, bool) {
    return false;
}

bool PCAPAdapter::SetMACSwitchedFilter(PacketReader::MAC_Address) {
    return false;
}

void PCAPAdapter::SetMACBridgedRecv(NetPacket*) {
    
}

void PCAPAdapter::SetMACBridgedSend(NetPacket*) {
    
}

void PCAPAdapter::HandleFrameCheckSequence(NetPacket*) {
    
}

bool PCAPAdapter::ValidateEtherFrame(NetPacket*) {
    return false;
}
