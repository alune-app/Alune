// AluneBridge.h — ObjC bridge for C++ emulator control
// SPDX-License-Identifier: GPL-3.0+

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>
#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif

bool unzip_file(const char* zipPath, const char* destination);
NSString *serial(const char* isoPath);

#ifdef __cplusplus
}
#endif

typedef NS_ENUM(NSInteger, AluneEmulatorState) {
    AluneEmulatorStateStopped = 0,
    AluneEmulatorStateRunning,
    AluneEmulatorStatePaused,
    AluneEmulatorStateSaving,
    AluneEmulatorStateSuspended,
};

typedef NS_ENUM(NSInteger, AluneCoreType) {
    AluneCoreTypeJIT = 0,
    AluneCoreTypeInterpreter = 1,
};

typedef NS_ENUM(NSUInteger, PS2ButtonPressState) {
    PS2ButtonPressStateReleased = 0,
    PS2ButtonPressStatePressed = 1
};

@interface AluneGameView : MTKView
@end

@interface AluneBridge : NSObject
+(AluneBridge *) sharedInstance NS_SWIFT_NAME(shared());

// MARK: View
-(void) initializeRenderingView NS_SWIFT_NAME(initialize());
-(AluneGameView *) renderingView;

// MARK: Input
-(void) press:(uint32_t)button slot:(uint8_t)slot NS_SWIFT_NAME(press(button:slot:));
-(void) release:(uint32_t)button slot:(uint8_t)slot NS_SWIFT_NAME(release(button:slot:));

-(void) drag:(uint32_t)thumbstick point:(CGPoint)point slot:(uint8_t)slot NS_SWIFT_NAME(drag(thumbstick:point:slot:));

// MARK: Settings
-(BOOL) getBoolSetting:(NSString *)section key:(NSString *)key NS_SWIFT_NAME(getBoolSetting(section:key:));
-(void) setBoolSetting:(NSString *)section key:(NSString *)key value:(BOOL)value NS_SWIFT_NAME(setBoolSetting(section:key:value:));
-(double) getDoubleSetting:(NSString *)section key:(NSString *)key NS_SWIFT_NAME(getDoubleSetting(section:key:));
-(void) setDoubleSetting:(NSString *)section key:(NSString *)key value:(double)value NS_SWIFT_NAME(setDoubleSetting(section:key:value:));
-(NSInteger) getIntSetting:(NSString *)section key:(NSString *)key NS_SWIFT_NAME(getIntSetting(section:key:));
-(void) setIntSetting:(NSString *)section key:(NSString *)key value:(NSInteger)value NS_SWIFT_NAME(setIntSetting(section:key:value:));
-(NSString *) getStringSetting:(NSString *)section key:(NSString *)key NS_SWIFT_NAME(getStringSetting(section:key:));
-(void) setStringSetting:(NSString *)section key:(NSString *)key value:(NSString *)value NS_SWIFT_NAME(setStringSetting(section:key:value:));
-(void) resetSettings;

// MARK: Setup
-(void) insertBIOS:(NSURL *)url NS_SWIFT_NAME(insert(bios:));
-(uint32_t) insertDisc:(NSString *)name NS_SWIFT_NAME(insert(disc:));

-(void) pause;
-(void) unpause;
-(void) start;
-(void) stop;

-(BOOL) isPaused NS_SWIFT_NAME(paused());
-(BOOL) isRunning NS_SWIFT_NAME(running());

-(BOOL) JITAvailable;
@end
