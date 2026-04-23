//
//  CocoaTools.mm
//  Alune
//
//  Created by Jarrod Norwell on 10/4/2026.
//

#import "CocoaTools.h"
#import "Host.h"

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

#include <dlfcn.h>

#include <common/Console.h>

void CocoaTools::InhibitAppNap(const std::string&) {
    
}

void CocoaTools::UninhibitAppNap() {
    
}

std::string CocoaTools::GetBundlePath() {
    return std::string{[[[NSBundle mainBundle] bundlePath] UTF8String]};
}

void* CocoaTools::CreateMetalLayer(WindowInfo* wi) {
    void* layer = (__bridge void*)((__bridge MTKView *)wi->window_handle).layer;
    wi->surface_handle = layer;
    return layer;
}

void CocoaTools::DestroyMetalLayer(WindowInfo* wi) {
    if (wi->surface_handle) {
        
    }
}

std::optional<std::string> CocoaTools::GetResourcePath() {
    return std::string{[[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"resources"].path UTF8String]};
}

std::optional<std::string> CocoaTools::GetNonTranslocatedBundlePath() {
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    if (!url)
        return std::nullopt;
    
    if (void* handle = dlopen("/System/Library/Frameworks/Security.framework/Security", RTLD_LAZY))
    {
        auto IsTranslocatedURL = reinterpret_cast<Boolean(*)(CFURLRef path, bool* isTranslocated, CFErrorRef*__nullable error)>(dlsym(handle, "SecTranslocateIsTranslocatedURL"));
        auto CreateOriginalPathForURL = reinterpret_cast<CFURLRef __nullable(*)(CFURLRef translocatedPath, CFErrorRef*__nullable error)>(dlsym(handle, "SecTranslocateCreateOriginalPathForURL"));
        bool is_translocated = false;
        if (IsTranslocatedURL)
            IsTranslocatedURL((__bridge CFURLRef)url, &is_translocated, nullptr);
        if (is_translocated)
        {
            if (CFURLRef actual = CreateOriginalPathForURL((__bridge CFURLRef)url, nullptr))
                url = (__bridge NSURL *)actual;
        }
        dlclose(handle);
    }
    
    return std::string([url fileSystemRepresentation]);
}
