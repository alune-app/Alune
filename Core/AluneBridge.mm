// AluneBridge.mm — ObjC bridge implementation
// SPDX-License-Identifier: GPL-3.0+

#import "AluneBridge.h"

#import <MetalKit/MetalKit.h>
#import <TargetConditionals.h>

#define SDL_MAIN_HANDLED
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

#include "CDVD/CDVD.h"
#include "CDVD/CDVDcommon.h"
#include "Common.h"
#include "Counters.h"
#include "GS/GSState.h"
#include "SIO/Pad/Pad.h"
#include "SIO/Pad/PadDualshock2.h"
#include "VMManager.h"
#include "common/Error.h"
#include "common/FileSystem.h"
#include "common/Path.h"
#include "pcsx2/INISettingsInterface.h"

#include "common/Console.h"
#include "common/FileSystem.h"
#include "common/Path.h"
#include "common/ProgressCallback.h"
#include "pcsx2/Achievements.h"
#include "pcsx2/CDVD/CDVD.h"
#include "pcsx2/CDVD/CDVDcommon.h"
#include "pcsx2/CDVD/CDVDdiscReader.h"
#include "pcsx2/Config.h"
#include "pcsx2/Counters.h" // g_FrameCount
#include "pcsx2/ImGui/ImGuiManager.h"
#include "pcsx2/Input/InputManager.h"
#include "pcsx2/SIO/Pad/Pad.h"
#include "pcsx2/SIO/Pad/PadDualshock2.h"
#include "pcsx2/VMManager.h"

#include "pcsx2/DEV9/net.h"
#include "pcsx2/DEV9/pcap_io.h"

#include "pcsx2/Host.h"
#include "pcsx2/Host/AudioStreamTypes.h"

#include "common/HTTPDownloader.h"
#include "common/WindowInfo.h"
#include <atomic>
#include <condition_variable>
#include <mutex>
#include <optional>
#include <sys/stat.h> // For mkdir
#include <sys/types.h>
#include <sys/sysctl.h>
#include <string>
#include <vector>
#include <thread>

#include "common/Darwin/DarwinMisc.h"

#include "Host.h"

#include <algorithm>
#include <atomic>
#include <cctype>
#include <condition_variable>
#include <filesystem>
#include <memory>
#include <mutex>
#include <thread>

#if __has_include("Core-Swift.h")
#import "Core-Swift.h"
#endif

#include <libzip/zip.h>
#include <filesystem>
#include <fstream>

bool unzip_file(const char* zipPath, const char* destination) {
    int err = 0;
    zip* archive = zip_open(zipPath, 0, &err);
    if (!archive) return false;

    zip_int64_t count = zip_get_num_entries(archive, 0);

    for (zip_uint64_t i = 0; i < count; i++) {
        const char* name = zip_get_name(archive, i, 0);
        if (!name) continue;
        if (std::string{name} == "__MACOSX") continue;;

        std::filesystem::path outPath = std::filesystem::path(destination) / name;
        if (std::filesystem::exists(outPath))
            continue;

        // Create directories
        std::filesystem::create_directories(outPath.parent_path());

        zip_file* zf = zip_fopen_index(archive, i, 0);
        if (!zf) continue;

        std::ofstream out(outPath, std::ios::binary);

        char buffer[4096];
        zip_int64_t bytesRead;

        while ((bytesRead = zip_fread(zf, buffer, sizeof(buffer))) > 0) {
            out.write(buffer, bytesRead);
        }

        zip_fclose(zf);
    }

    zip_close(archive);
    return true;
}

NSString *serial(const char* isoPath) {
    Error error;
    std::string* serial = new std::string("");
    u32* crc{};
    
    CDVD = &CDVDapi_Iso;
    CDVD->open(isoPath, &error);
    cdvdGetDiscInfo(serial, nullptr, nullptr, crc, nullptr);
    DoCDVDclose();
    
    NSLog(@"%@", [NSString stringWithCString:serial->c_str() encoding:NSUTF8StringEncoding]);
    if (serial == nullptr)
        return @"";
    else
        return [NSString stringWithCString:serial->c_str() encoding:NSUTF8StringEncoding];
}

static INISettingsInterface* settings;

#include "pcsx2/MTGS.h"

extern void GSResizeDisplayWindow(int width, int height, float scale);

@implementation AluneGameView
-(void) layoutSubviews {
    [super layoutSubviews];
    
    CGFloat nativeScale = 1; //self.contentScaleFactor;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    [(CAMetalLayer *)self.layer setDrawableSize:CGSizeMake(width * nativeScale, height * nativeScale)];
    
    MTGS::RunOnGSThread([nativeScale, width, height]() {
        GSResizeDisplayWindow(static_cast<int>(width * nativeScale), static_cast<int>(height * nativeScale), nativeScale);
    });
}
@end

AluneGameView *imp_renderingView;

@implementation AluneBridge
-(AluneBridge *) init {
    if (self = [super init]) {
        SDL_SetMainReady();
        
        NSURL *documentDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        
        std::string documentDirectoryString{[documentDirectoryURL.path UTF8String]};
        std::filesystem::path documentDirectoryPath{documentDirectoryString};
        
        std::filesystem::path logsPath{documentDirectoryPath / "logs"};
        
        EmuFolders::AppRoot = documentDirectoryPath.string();
        EmuFolders::Bios = (documentDirectoryPath / "bios").string();
        EmuFolders::Cache = (documentDirectoryPath / "caches").string();
        EmuFolders::Cheats = (documentDirectoryPath / "cheats").string();
        EmuFolders::Covers = (documentDirectoryPath / "covers").string();
        EmuFolders::DataRoot = documentDirectoryPath.string();
        EmuFolders::DebuggerLayouts = (documentDirectoryPath / "settings" / "debugger_layouts").string();
        EmuFolders::DebuggerSettings = (documentDirectoryPath / "settings" / "debugger_settings").string();
        EmuFolders::GameSettings = (documentDirectoryPath / "game_settings").string();
        EmuFolders::InputProfiles = (documentDirectoryPath / "input_profiles").string();
        EmuFolders::Logs = logsPath.string();
        EmuFolders::MemoryCards = (documentDirectoryPath / "memory_cards").string();
        EmuFolders::Patches = (documentDirectoryPath / "patches").string();
        EmuFolders::Resources = (documentDirectoryPath / "resources").string();
        EmuFolders::Savestates = (documentDirectoryPath / "save_states").string();
        EmuFolders::Settings = (documentDirectoryPath / "settings").string();
        EmuFolders::Snapshots = (documentDirectoryPath / "snapshots").string();
        EmuFolders::Textures = (documentDirectoryPath / "textures").string();
        EmuFolders::UserResources = (documentDirectoryPath / "user_resources").string();
        EmuFolders::Videos = (documentDirectoryPath / "videos").string();
        
        if (EmuFolders::EnsureFoldersExist())
            NSLog(@"%@", documentDirectoryURL.path);
        
        std::filesystem::path resourcesPath{EmuFolders::Resources};
        ImGuiManager::SetFontPathAndRange((resourcesPath / "fonts" / "Roboto-Regular.ttf").string(), {});
        
        // freopen((logsPath / "log.txt").c_str(), "w", stderr);
        // dup2(STDERR_FILENO, STDOUT_FILENO);
        //
        // fflush(stderr);
        
        Log::SetConsoleOutputLevel(LOGLEVEL::LOGLEVEL_INFO);
        Log::SetDebugOutputLevel(LOGLEVEL::LOGLEVEL_INFO);
        
        std::filesystem::path settingsPath{EmuFolders::Settings};
        
        settings = new INISettingsInterface((settingsPath / "settings.txt").string());
        if (!settings->Load()) {
            VMManager::SetDefaultSettings(*settings, true, true, true, true, true);
            
            settings->SetBoolValue("EmuCore/CPU", "ExtraMemory", true);
            settings->SetIntValue("EmuCore/CPU", "CoreType", 0);
            settings->SetBoolValue("EmuCore/CPU", "UseArm64Dynarec", false);
            // settings->SetBoolValue("EmuCore/CPU", "EnableSparseMemory", true);
            
            settings->SetBoolValue("EmuCore/CPU/Recompiler", "EnableEE", false);
            settings->SetBoolValue("EmuCore/CPU/Recompiler", "EnableIOP", false);
            settings->SetBoolValue("EmuCore/CPU/Recompiler", "EnableEECache", false);
            settings->SetBoolValue("EmuCore/CPU/Recompiler", "EnableVU0", false);
            settings->SetBoolValue("EmuCore/CPU/Recompiler", "EnableVU1", false);
            settings->SetBoolValue("EmuCore/CPU/Recompiler", "EnableFastmem", true);
            
            settings->SetBoolValue("EmuCore/GS", "VsyncEnable", false);
            settings->SetBoolValue("EmuCore/GS", "DisableMailboxPresentation", false);
            settings->SetIntValue("EmuCore/GS", "VsyncQueueSize", 2);
            settings->SetStringValue("EmuCore/GS", "AspectRatio", "4:3");
            
            settings->SetIntValue("EmuCore/Speedhacks", "EECycleRate", 0);
            settings->SetIntValue("EmuCore/Speedhacks", "EECycleSkip", 0);
            settings->SetBoolValue("EmuCore/Speedhacks", "fastCDVD", false);
            settings->SetBoolValue("EmuCore/Speedhacks", "WaitLoop", false);
            settings->SetBoolValue("EmuCore/Speedhacks", "vuFlagHack", false);
            settings->SetBoolValue("EmuCore/Speedhacks", "vuThread", false);
            settings->SetBoolValue("EmuCore/Speedhacks", "vu1Instant", false);
            settings->SetBoolValue("EmuCore/Speedhacks", "MTVU", false);
            
            // Force these for now
            settings->SetIntValue("EmuCore/GS", "Renderer", static_cast<int>(GSRendererType::Metal));
            settings->SetStringValue("EmuCore/GS", "CustomDriverPath", "@rpath/MoltenVK.framework/MoltenVK");
            settings->SetIntValue("EmuCore/GS", "OsdMessagesPos", 0);
            settings->SetIntValue("EmuCore/GS", "OsdPerformancePos", 0);
            settings->SetStringValue("SPU2/Output", "Backend", "SDL");
            settings->SetBoolValue("InputSources", "SDL", false);
            
            settings->SetStringValue("Folders", "Bios", "bios");
            settings->SetStringValue("Folders", "Cache", "caches");
            settings->SetStringValue("Folders", "Cheats", "cheats");
            settings->SetStringValue("Folders", "Covers", "covers");
            settings->SetStringValue("Folders", "DebuggerLayouts", "debugger_layouts");
            settings->SetStringValue("Folders", "DebuggerSettings", "debugger_settings");
            settings->SetStringValue("Folders", "GameSettings", "game_settings");
            settings->SetStringValue("Folders", "InputProfiles", "input_profiles");
            settings->SetStringValue("Folders", "Logs", "logs");
            settings->SetStringValue("Folders", "MemoryCards", "memory_cards");
            settings->SetStringValue("Folders", "Patches", "patches");
            settings->SetStringValue("Folders", "Resources", "resources");
            settings->SetStringValue("Folders", "Savestates", "save_states");
            settings->SetStringValue("Folders", "Settings", "settings");
            settings->SetStringValue("Folders", "Snapshots", "snapshots");
            settings->SetStringValue("Folders", "Textures", "textures");
            settings->SetStringValue("Folders", "UserResources", "user_resources");
            settings->SetStringValue("Folders", "Videos", "videos");
            
            settings->Save();
        }
        
        Host::Internal::SetBaseSettingsLayer(settings);
        
        VMManager::Internal::LoadStartupSettings();
        VMManager::ApplySettings();
        
        DarwinMisc::SetCrashLogFD(STDERR_FILENO);
    } return self;
}

+(AluneBridge *) sharedInstance {
    static AluneBridge *sharedInstance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AluneBridge alloc] init];
    });
    return sharedInstance;
}

// MARK: View
-(void) initializeRenderingView {
    extern AluneGameView *imp_renderingView;
    imp_renderingView = [[AluneGameView alloc] initWithFrame:CGRectZero device:MTLCreateSystemDefaultDevice()];
}

-(AluneGameView *) renderingView {
    extern AluneGameView *imp_renderingView;
    return imp_renderingView;
}

// MARK: Input
-(void) press:(uint32_t)button slot:(uint8_t)slot {
    auto pad = static_cast<PadDualshock2*>(Pad::GetPad(slot));
    if (pad)
        pad->Set(button, static_cast<float>(PS2ButtonPressState::PS2ButtonPressStatePressed));
}

-(void) release:(uint32_t)button slot:(uint8_t)slot {
    auto pad = static_cast<PadDualshock2*>(Pad::GetPad(slot));
    if (pad)
        pad->Set(button, static_cast<float>(PS2ButtonPressState::PS2ButtonPressStateReleased));
}

-(void) drag:(uint32_t)thumbstick point:(CGPoint)point slot:(uint8_t)slot {
    auto pad = static_cast<PadDualshock2*>(Pad::GetPad(slot));
    if (pad) {
        CGFloat x = point.x;
        CGFloat y = point.y;
        
        switch (static_cast<PS2ThumbstickSide>(thumbstick)) {
            case PS2ThumbstickSide::PS2ThumbstickSideLeft: {
                pad->Set(PadDualshock2::Inputs::PAD_L_RIGHT, x > 0 ? x : 0.0f);
                pad->Set(PadDualshock2::Inputs::PAD_L_LEFT, x < 0 ? -x : 0.0f);
                pad->Set(PadDualshock2::Inputs::PAD_L_DOWN, y > 0 ? y : 0.0f);
                pad->Set(PadDualshock2::Inputs::PAD_L_UP, y < 0 ? -y : 0.0f);
                break;
            }
                
            case PS2ThumbstickSide::PS2ThumbstickSideRight: {
                pad->Set(PadDualshock2::Inputs::PAD_R_RIGHT, x > 0 ? x : 0.0f);
                pad->Set(PadDualshock2::Inputs::PAD_R_LEFT, x < 0 ? -x : 0.0f);
                pad->Set(PadDualshock2::Inputs::PAD_R_DOWN, y > 0 ? y : 0.0f);
                pad->Set(PadDualshock2::Inputs::PAD_R_UP, y < 0 ? -y : 0.0f);
                break;
            }
        }
    }
}

// MARK: Settings
-(BOOL) getBoolSetting:(NSString *)section key:(NSString *)key {
    bool value{};
    settings->GetBoolValue([section cStringUsingEncoding:NSUTF8StringEncoding], [key cStringUsingEncoding:NSUTF8StringEncoding], &value);
    return value;
}

-(void) setBoolSetting:(NSString *)section key:(NSString *)key value:(BOOL)value {
    settings->SetBoolValue([section cStringUsingEncoding:NSUTF8StringEncoding], [key cStringUsingEncoding:NSUTF8StringEncoding], value);
    settings->Save();
}

-(double) getDoubleSetting:(NSString *)section key:(NSString *)key {
    double value{};
    settings->GetDoubleValue([section cStringUsingEncoding:NSUTF8StringEncoding], [key cStringUsingEncoding:NSUTF8StringEncoding], &value);
    return value;
}

-(void) setDoubleSetting:(NSString *)section key:(NSString *)key value:(double)value {
    settings->SetDoubleValue([section cStringUsingEncoding:NSUTF8StringEncoding], [key cStringUsingEncoding:NSUTF8StringEncoding], value);
    settings->Save();
}

-(NSInteger) getIntSetting:(NSString *)section key:(NSString *)key {
    int value{};
    settings->GetIntValue([section cStringUsingEncoding:NSUTF8StringEncoding], [key cStringUsingEncoding:NSUTF8StringEncoding], &value);
    return [[NSNumber numberWithInt:value] integerValue];
}

-(void) setIntSetting:(NSString *)section key:(NSString *)key value:(NSInteger)value {
    settings->SetIntValue([section cStringUsingEncoding:NSUTF8StringEncoding], [key cStringUsingEncoding:NSUTF8StringEncoding],
                          [[NSNumber numberWithInteger:value] intValue]);
    settings->Save();
}

-(NSString *) getStringSetting:(NSString *)section key:(NSString *)key {
    std::string value{};
    settings->GetStringValue([section cStringUsingEncoding:NSUTF8StringEncoding], [key cStringUsingEncoding:NSUTF8StringEncoding], &value);
    return [NSString stringWithCString:value.c_str() encoding:NSUTF8StringEncoding];
}

-(void) setStringSetting:(NSString *)section key:(NSString *)key value:(NSString *)value {
    settings->SetStringValue([section cStringUsingEncoding:NSUTF8StringEncoding], [key cStringUsingEncoding:NSUTF8StringEncoding],
                             [value cStringUsingEncoding:NSUTF8StringEncoding]);
    settings->Save();
}

-(void) resetSettings {
    NSURL *documentDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    
    std::string documentDirectoryString{[documentDirectoryURL.path UTF8String]};
    std::filesystem::path documentDirectoryPath{documentDirectoryString};
    
    std::filesystem::path logsPath{documentDirectoryPath / "logs"};
    
    EmuFolders::AppRoot = documentDirectoryPath.string();
    EmuFolders::Bios = (documentDirectoryPath / "bios").string();
    EmuFolders::Cache = (documentDirectoryPath / "caches").string();
    EmuFolders::Cheats = (documentDirectoryPath / "cheats").string();
    EmuFolders::Covers = (documentDirectoryPath / "covers").string();
    EmuFolders::DataRoot = documentDirectoryPath.string();
    EmuFolders::DebuggerLayouts = (documentDirectoryPath / "settings" / "debugger_layouts").string();
    EmuFolders::DebuggerSettings = (documentDirectoryPath / "settings" / "debugger_settings").string();
    EmuFolders::GameSettings = (documentDirectoryPath / "game_settings").string();
    EmuFolders::InputProfiles = (documentDirectoryPath / "input_profiles").string();
    EmuFolders::Logs = logsPath.string();
    EmuFolders::MemoryCards = (documentDirectoryPath / "memory_cards").string();
    EmuFolders::Patches = (documentDirectoryPath / "patches").string();
    EmuFolders::Resources = (documentDirectoryPath / "resources").string();
    EmuFolders::Savestates = (documentDirectoryPath / "save_states").string();
    EmuFolders::Settings = (documentDirectoryPath / "settings").string();
    EmuFolders::Snapshots = (documentDirectoryPath / "snapshots").string();
    EmuFolders::Textures = (documentDirectoryPath / "textures").string();
    EmuFolders::UserResources = (documentDirectoryPath / "user_resources").string();
    EmuFolders::Videos = (documentDirectoryPath / "videos").string();
    
    if (EmuFolders::EnsureFoldersExist())
        NSLog(@"all folders created successfully");
    
    VMManager::SetDefaultSettings(*settings, true, true, true, true, true);
    
    settings->SetBoolValue("EmuCore/CPU", "ExtraMemory", true);
    settings->SetIntValue("EmuCore/CPU", "CoreType", 0);
    settings->SetBoolValue("EmuCore/CPU", "UseArm64Dynarec", false);
    // settings->SetBoolValue("EmuCore/CPU", "EnableSparseMemory", true);
    
    settings->SetBoolValue("EmuCore/CPU/Recompiler", "EnableEE", false);
    settings->SetBoolValue("EmuCore/CPU/Recompiler", "EnableIOP", false);
    settings->SetBoolValue("EmuCore/CPU/Recompiler", "EnableEECache", false);
    settings->SetBoolValue("EmuCore/CPU/Recompiler", "EnableVU0", false);
    settings->SetBoolValue("EmuCore/CPU/Recompiler", "EnableVU1", false);
    settings->SetBoolValue("EmuCore/CPU/Recompiler", "EnableFastmem", true);
    
    settings->SetBoolValue("EmuCore/GS", "VsyncEnable", false);
    settings->SetBoolValue("EmuCore/GS", "DisableMailboxPresentation", false);
    settings->SetIntValue("EmuCore/GS", "VsyncQueueSize", 2);
    settings->SetStringValue("EmuCore/GS", "AspectRatio", "4:3");
    
    settings->SetIntValue("EmuCore/Speedhacks", "EECycleRate", 0);
    settings->SetIntValue("EmuCore/Speedhacks", "EECycleSkip", 0);
    settings->SetBoolValue("EmuCore/Speedhacks", "fastCDVD", false);
    settings->SetBoolValue("EmuCore/Speedhacks", "WaitLoop", false);
    settings->SetBoolValue("EmuCore/Speedhacks", "vuFlagHack", false);
    settings->SetBoolValue("EmuCore/Speedhacks", "vuThread", false);
    settings->SetBoolValue("EmuCore/Speedhacks", "vu1Instant", false);
    settings->SetBoolValue("EmuCore/Speedhacks", "MTVU", false);
    
    // Force these for now
    settings->SetIntValue("EmuCore/GS", "Renderer", static_cast<int>(GSRendererType::Metal));
    settings->SetStringValue("EmuCore/GS", "CustomDriverPath", "@rpath/MoltenVK.framework/MoltenVK");
    settings->SetIntValue("EmuCore/GS", "OsdMessagesPos", 0);
    settings->SetIntValue("EmuCore/GS", "OsdPerformancePos", 0);
    settings->SetStringValue("SPU2/Output", "Backend", "SDL");
    
    settings->SetStringValue("Folders", "Bios", "bios");
    settings->SetStringValue("Folders", "Cache", "caches");
    settings->SetStringValue("Folders", "Cheats", "cheats");
    settings->SetStringValue("Folders", "Covers", "covers");
    settings->SetStringValue("Folders", "DebuggerLayouts", "debugger_layouts");
    settings->SetStringValue("Folders", "DebuggerSettings", "debugger_settings");
    settings->SetStringValue("Folders", "GameSettings", "game_settings");
    settings->SetStringValue("Folders", "InputProfiles", "input_profiles");
    settings->SetStringValue("Folders", "Logs", "logs");
    settings->SetStringValue("Folders", "MemoryCards", "memory_cards");
    settings->SetStringValue("Folders", "Patches", "patches");
    settings->SetStringValue("Folders", "Resources", "resources");
    settings->SetStringValue("Folders", "Savestates", "save_states");
    settings->SetStringValue("Folders", "Settings", "settings");
    settings->SetStringValue("Folders", "Snapshots", "snapshots");
    settings->SetStringValue("Folders", "Textures", "textures");
    settings->SetStringValue("Folders", "UserResources", "user_resources");
    settings->SetStringValue("Folders", "Videos", "videos");
    
    settings->Save();
}

// MARK: Setup
-(void) insertBIOS:(NSURL *)url {
    settings->SetStringValue("Filenames", "BIOS", [url.lastPathComponent cStringUsingEncoding:NSUTF8StringEncoding]);
    
    settings->Save();
}

-(uint32_t) insertDisc:(NSString *)name {
    settings->SetStringValue("GameISO", "BootISO", [name cStringUsingEncoding:NSUTF8StringEncoding]);
    settings->Save();
    
    VMManager::Internal::LoadStartupSettings();
    VMManager::ApplySettings();
    
    
#if !TARGET_OS_SIMULATOR
#if TARGET_OS_IPHONE
    if (!DarwinMisc::IsJITAvailable())
        DarwinMisc::Alune_FORCE_EE_INTERP = 1;
#endif
#endif
    
    if (SDL_Init(SDL_INIT_AUDIO) == false)
        NSLog(@"SDL_Init failed, %s", SDL_GetError());
    
    return 0;
}


-(void) pause {
    std::thread thread([]() {
        VMManager::SetPaused(true);
    });
    thread.detach();
}

-(void) unpause {
    std::thread thread([]() {
        VMManager::SetPaused(false);
    });
    thread.detach();
}

-(void) start {
    if (!VMManager::Internal::CPUThreadInitialize())
        VMManager::Internal::CPUThreadShutdown();
    
    std::filesystem::path documentDirectoryPath{EmuFolders::DataRoot};
    std::filesystem::path isosPath{documentDirectoryPath / "isos"};
    
    std::filesystem::path gamePath{(isosPath / settings->GetStringValue("GameISO", "BootISO"))};
    std::string extension{gamePath.extension().string()};
    
    std::transform(extension.begin(), extension.end(), extension.begin(), ::tolower);
    
    VMBootParameters boot_params{};
    boot_params.fast_boot = true;
    if (extension == ".elf") {
        boot_params.elf_override = gamePath.string();
        boot_params.source_type = CDVD_SourceType::NoDisc;
    } else if (extension == ".iso") {
        boot_params.filename = gamePath.string();
        boot_params.source_type = CDVD_SourceType::Iso;
    }
    
    std::thread([boot_params]() {
        if (VMManager::Initialize(boot_params)) {
            VMManager::SetState(VMState::Running);
            
            while (true) {
                VMState state = VMManager::GetState();
                if (state == VMState::Running)
                    VMManager::Execute();
                else if (state == VMState::Shutdown || state == VMState::Stopping)
                    break;
                else
                    usleep(250000);
            }
            
            VMManager::Shutdown(false);
            
            VMManager::Internal::CPUThreadShutdown();
        }
    }).detach();
}

-(void) stop {
    std::thread thread([]() {
        VMManager::SetState(VMState::Stopping);
    });
    thread.detach();
}


-(BOOL) isPaused {
    return VMManager::GetState() == VMState::Paused;
}

-(BOOL) isRunning {
    return VMManager::GetState() == VMState::Running;
}


-(BOOL) JITAvailable {
    return DarwinMisc::IsJITAvailable();
}
@end
