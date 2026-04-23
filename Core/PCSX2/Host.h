//
//  Host.h
//  Alune
//
//  Created by Jarrod Norwell on 10/4/2026.
//

#include <functional>
#include <memory>
#include <string>
#include <string_view>
#include <vector>

#define SDL_MAIN_HANDLED
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include <SDL3/SDL_metal.h>
#include <SDL3/SDL_video.h>

#include "common/ProgressCallback.h"
#include "common/SettingsInterface.h"
#include "common/WindowInfo.h"

#include "pcsx2/Achievements.h"
#include "pcsx2/Input/InputManager.h"

namespace Host
{
    void RequestShutdown();
    void RunOnMainThread(std::function<void()> func, bool wait);
    bool CopyTextToClipboard(const std::string_view text);
    void OnOSDMessage(const std::string &, float, u32);
    void ReportError(const char *, const char *);
    bool ConfirmAction(const char *, const char *, const char *);
    std::optional<std::string> OpenFileSelectionDialog(const char *, const char *, const char *, const char *);
    std::optional<std::string> OpenDirectorySelectionDialog(const char *, const char *);
    void SysLog(const char *fmt, ...);
    void LoadSettings(SettingsInterface &, std::unique_lock<std::mutex> &);
    void RequestResetSettings(bool);
    void SetDefaultUISettings(SettingsInterface &si);
    const char *GetTranslatedStringImpl(const char *key);
    u32 GetDisplayRefreshRate();
    std::optional<WindowInfo> AcquireRenderWindow(bool recreate_window);
    void ReleaseRenderWindow();
    bool InNoGUIMode();
    void OnVMPaused();
    void OnVMResumed();
    void OnVMStarted();
    void OnVMStarting();
    void EndTextInput();
    bool IsFullscreen();
    void SetMouseMode(bool, bool);
    void OnGameChanged(const std::string &, const std::string &, const std::string &, const std::string &, unsigned int, unsigned int);
    void OnVMDestroyed();
    void SetFullscreen(bool);
    void BeginTextInput();
    bool ConfirmMessage(std::string_view, std::string_view);
    void RunOnCPUThread(std::function<void()>, bool);
    void ReportInfoAsync(std::string_view, std::string_view);
    void ReportErrorAsync(std::string_view title, std::string_view msg);
    void OnSaveStateSaved(std::string_view);
    void OnSaveStateLoaded(std::string_view, bool);
    void BeginPresentFrame();
    void OnSaveStateLoading(std::string_view);
    bool LocaleCircleConfirm();

    void RefreshGameListAsync(bool);
    bool RequestResetSettings(bool, bool, bool, bool, bool);
    void CancelGameListRefresh();
    void RequestVMShutdown(bool, bool, bool);
    void RequestExitBigPicture();
    void OnInputDeviceConnected(std::string_view, std::string_view);
    void RequestExitApplication(bool);
    void CheckForSettingsChanges(const Pcsx2Config &);
    void OnAchievementsRefreshed();
    void PumpMessagesOnCPUThread();
    std::string TranslatePluralToString(const char *, const char *, const char *, int);
    void CommitBaseSettingChanges();
    void OnInputDeviceDisconnected(InputBindingKey, std::string_view);
    void OpenHostFileSelectorAsync(std::string_view, bool, std::function<void(const std::string &)>, std::vector<std::string>, std::string_view);
    std::unique_ptr<ProgressCallback> CreateHostProgressCallback();
    void OnAchievementsLoginSuccess(char const *, u32, u32, u32);
    void OnPerformanceMetricsUpdated();
    void OnAchievementsLoginRequested(Achievements::LoginRequestReason);
    bool ShouldPreferHostFileSelector();
    void OnCoverDownloaderOpenRequested();
    void OnCreateMemoryCardOpenRequested();
    void OnAchievementsHardcoreModeChanged(bool);
    void OpenURL(std::string_view);
}

namespace Host::Internal
{
    s32 GetTranslatedStringImpl(const std::string_view, const std::string_view, char *, size_t);
}
