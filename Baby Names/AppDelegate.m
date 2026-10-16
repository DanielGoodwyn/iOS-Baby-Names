#import "Database.h"
#import "AppDelegate.h"
#import <GoogleSignIn/GoogleSignIn.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Database enableLocalDatastore];
    [Database setApplicationId:@"bm6jT0Rj1lUCwutfFk1WUgXm4wLRpN1Jz4LKMLqw" clientKey:@"Y8IFJzyA64AhAUOh7TvOn7FXd3U6xcIhwY4pQWuz"];

    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [GIDSignIn.sharedInstance handleURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

@end
