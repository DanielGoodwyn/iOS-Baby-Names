#import <Foundation/Foundation.h>
#import "DBObject.h"

@interface DBQuery : NSObject
+ (instancetype)queryWithClassName:(NSString *)className;
- (instancetype)initWithClassName:(NSString *)className;
- (void)whereKey:(NSString *)key equalTo:(id)object;
- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex;
- (void)whereKey:(NSString *)key containsString:(NSString *)substring;

- (void)orderByAscending:(NSString *)key;
- (void)orderByDescending:(NSString *)key;
@property (nonatomic, assign) NSInteger limit;
- (void)findObjectsInBackgroundWithBlock:(void (^)(NSArray *objects, NSError *error))block;
@end
