#import <Foundation/Foundation.h>

@interface DBObject : NSObject
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *parseClassName;
@property (nonatomic, strong) NSMutableDictionary *data;

+ (instancetype)objectWithClassName:(NSString *)className;
- (instancetype)initWithClassName:(NSString *)className;
- (void)setObject:(id)object forKey:(NSString *)key;
- (void)setObject:(id)object forKeyedSubscript:(NSString *)key;

- (id)objectForKey:(NSString *)key;
- (id)objectForKeyedSubscript:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
- (void)saveInBackground;
- (void)saveInBackgroundWithBlock:(void (^)(BOOL succeeded, NSError *error))block;
- (void)deleteInBackground;
- (void)deleteInBackgroundWithBlock:(void (^)(BOOL succeeded, NSError *error))block;
- (void)fetchInBackgroundWithBlock:(void (^)(DBObject *object, NSError *error))block;
@end
