//
//  Host.mm
//  Alune
//
//  Created by Jarrod Norwell on 10/4/2026.
//

#import "Host.h"

#include "common/Console.h"
#include "pcsx2/VMManager.h"

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>
#import <UIKit/UIKit.h>

#include <stop_token>
#include <thread>

extern std::jthread thread;
extern MTKView *imp_renderingView;

void Host::RequestShutdown() {
    SDL_Event event;
    event.type = SDL_EVENT_QUIT;
    SDL_PushEvent(&event);
}

void Host::RunOnMainThread(std::function<void()> func, bool wait) {
  if (wait) {
    dispatch_sync(dispatch_get_main_queue(), ^{
      func();
    });
  } else {
    dispatch_async(dispatch_get_main_queue(), ^{
      func();
    });
  }
}

bool Host::CopyTextToClipboard(const std::string_view text) {
  [[UIPasteboard generalPasteboard]
      setString:[NSString stringWithCString:std::string{text}.c_str()
                                   encoding:NSUTF8StringEncoding]];
  return true;
}

void Host::OnOSDMessage(const std::string &, float, u32) {}

void Host::ReportError(const char *, const char *) {}

bool Host::ConfirmAction(const char *, const char *, const char *) {
  return true;
}

std::optional<std::string> Host::OpenFileSelectionDialog(const char *,
                                                         const char *,
                                                         const char *,
                                                         const char *) {
  return std::nullopt;
}

std::optional<std::string> Host::OpenDirectorySelectionDialog(const char *,
                                                              const char *) {
  return std::nullopt;
}

void Host::SysLog(const char *fmt, ...) {
  va_list args;
  va_start(args, fmt);
  vprintf(fmt, args);
  va_end(args);
}

void Host::LoadSettings(SettingsInterface &, std::unique_lock<std::mutex> &) {}

void Host::RequestResetSettings(bool) {}

void Host::SetDefaultUISettings(SettingsInterface &si) {}

const char *Host::GetTranslatedStringImpl(const char *key) { return nullptr; }

u32 Host::GetDisplayRefreshRate() { return 60; }

std::optional<WindowInfo> Host::AcquireRenderWindow(bool recreate_window) {
    Console.WriteLn("Host::AcquireRenderWindow(recreate=%d) called.",
                    recreate_window);
    
    __block WindowInfo wi = {};
    wi.type = WindowInfo::Type::iOS;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        wi.window_handle = (__bridge void *)imp_renderingView;
        
        MTKView *renderView = (__bridge MTKView *)wi.window_handle;
        
        CGFloat nativeScale = renderView.contentScaleFactor;
        wi.surface_width = static_cast<u32>(renderView.bounds.size.width * nativeScale);
        wi.surface_height = static_cast<u32>(renderView.bounds.size.height * nativeScale);
        wi.surface_scale = nativeScale;
        wi.surface_refresh_rate = 60.0f;
    });
    
    Console.WriteLn("Host::AcquireRenderWindow: Returning WindowInfo (Type=%d, "
                    "View=%p, Size=%ux%u, Scale=%.2f)",
                    (int)wi.type, wi.window_handle, wi.surface_width,
                    wi.surface_height, wi.surface_scale);
    
    return wi;
}

void Host::ReleaseRenderWindow() {}

bool Host::InNoGUIMode() { return true; }

void Host::OnVMPaused() {}

void Host::OnVMResumed() {}

void Host::OnVMStarted() {}

void Host::OnVMStarting() {}

void Host::EndTextInput() {}

bool Host::IsFullscreen() { return true; }

void Host::SetMouseMode(bool, bool) {}

void Host::OnGameChanged(const std::string &, const std::string &,
                         const std::string &, const std::string &, unsigned int,
                         unsigned int) {}

void Host::OnVMDestroyed() {}

void Host::SetFullscreen(bool) {}

void Host::BeginTextInput() {}

bool Host::ConfirmMessage(std::string_view, std::string_view) { return true; }

void Host::RunOnCPUThread(std::function<void()>, bool) {}

void Host::ReportInfoAsync(std::string_view, std::string_view) {}

void Host::ReportErrorAsync(std::string_view title, std::string_view msg) {
  Console.Error("Host::ReportErrorAsync: %s - %s", std::string{title}.c_str(),
                std::string{msg}.c_str());
}

void Host::OnSaveStateSaved(std::string_view) {}

void Host::OnSaveStateLoaded(std::string_view, bool) {}

void Host::BeginPresentFrame() {}

void Host::OnSaveStateLoading(std::string_view) {}

bool Host::LocaleCircleConfirm() { return true; }

void Host::RefreshGameListAsync(bool) {}

bool Host::RequestResetSettings(bool, bool, bool, bool, bool) { return true; }

void Host::CancelGameListRefresh() {}

void Host::RequestVMShutdown(bool, bool, bool) {}

void Host::RequestExitBigPicture() {}

void Host::OnInputDeviceConnected(std::string_view, std::string_view) {}

void Host::RequestExitApplication(bool) {}

void Host::CheckForSettingsChanges(const Pcsx2Config &) {}

void Host::OnAchievementsRefreshed() {}

void Host::PumpMessagesOnCPUThread() {}

std::string Host::TranslatePluralToString(const char *, const char *,
                                          const char *, int) {
  return std::string{};
}

void Host::CommitBaseSettingChanges() {}

void Host::OnInputDeviceDisconnected(InputBindingKey, std::string_view) {}

void Host::OpenHostFileSelectorAsync(std::string_view, bool,
                                     std::function<void(const std::string &)>,
                                     std::vector<std::string>,
                                     std::string_view) {}

std::unique_ptr<ProgressCallback> Host::CreateHostProgressCallback() {
  return ProgressCallback::CreateNullProgressCallback();
}

void Host::OnAchievementsLoginSuccess(char const *, u32, u32, u32) {}

void Host::OnPerformanceMetricsUpdated() {}

void Host::OnAchievementsLoginRequested(Achievements::LoginRequestReason) {}

bool Host::ShouldPreferHostFileSelector() { return true; }

void Host::OnCoverDownloaderOpenRequested() {}

void Host::OnCreateMemoryCardOpenRequested() {}

void Host::OnAchievementsHardcoreModeChanged(bool) {}

void Host::OpenURL(std::string_view) {}

// MARK: Host::Internal
s32 Host::Internal::GetTranslatedStringImpl(const std::string_view,
                                            const std::string_view, char *,
                                            size_t) {
  return 0;
}
