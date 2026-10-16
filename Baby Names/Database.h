#import <Foundation/Foundation.h>
#import "DBUser.h"
#import "DBObject.h"
#import "DBQuery.h"

@interface Database : NSObject
+ (void)enableLocalDatastore;
+ (void)setApplicationId:(NSString *)applicationId clientKey:(NSString *)clientKey;
@end
