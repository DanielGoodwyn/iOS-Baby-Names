#import "DBObject.h"
#import <UIKit/UIKit.h>

@interface DBUser : DBObject
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *email;

+ (DBUser *)currentUser;
+ (void)logInWithUsernameInBackground:(NSString *)username password:(NSString *)password block:(void (^)(DBUser *user, NSError *error))block;
+ (void)beginWithEmail:(NSString *)email password:(NSString *)password block:(void (^)(DBUser *user, BOOL isNewUser, NSError *error))block;
+ (void)beginWithGoogleFromViewController:(UIViewController *)viewController block:(void (^)(DBUser *user, NSError *error))block;
+ (void)logOut;
- (void)signUpInBackgroundWithBlock:(void (^)(BOOL succeeded, NSError *error))block;
+ (instancetype)user;
+ (void)requestPasswordResetForEmailInBackground:(NSString *)email block:(void (^)(BOOL succeeded, NSError *error))block;
@end
