#import "Database.h"
@import FirebaseCore;

@implementation Database
+ (void)enableLocalDatastore {}
+ (void)setApplicationId:(NSString *)applicationId clientKey:(NSString *)clientKey {
    if ([FIRApp defaultApp] == nil) {
        [FIRApp configure];
    }
}
@end
