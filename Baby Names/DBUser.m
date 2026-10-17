#import "DBUser.h"
#import <GoogleSignIn/GoogleSignIn.h>
@import FirebaseAuth;
@import FirebaseFirestore;

@implementation DBUser
static DBUser *_currentUser = nil;

- (instancetype)init {
    self = [super initWithClassName:@"users"];
    return self;
}

+ (instancetype)user {
    return [[self alloc] init];
}

+ (DBUser *)currentUser {
#if TARGET_OS_SIMULATOR
    if (!_currentUser) {
        _currentUser = [[DBUser alloc] init];
        _currentUser.objectId = @"sim_test_user_id";
        _currentUser.email = @"test@babynames.com";
        _currentUser.username = @"test";
        [_currentUser setObject:@"test" forKey:@"username"];
        [_currentUser setObject:@"test@babynames.com" forKey:@"email"];
        [_currentUser setObject:@25 forKey:@"limit"];
        [_currentUser setObject:@"ALL" forKey:@"letter"];
        [_currentUser setObject:@"All" forKey:@"gender"];
        [_currentUser setObject:@"popular" forKey:@"sort"];
    }
    return _currentUser;
#else
    FIRUser *fbUser = [FIRAuth auth].currentUser;
    if (fbUser && !_currentUser) {
        _currentUser = [[DBUser alloc] init];
        _currentUser.objectId = fbUser.uid;
        _currentUser.email = fbUser.email;
        _currentUser.username = fbUser.email;
    } else if (!fbUser) {
        _currentUser = nil;
    }
    return _currentUser;
#endif
}

+ (void)logInWithUsernameInBackground:(NSString *)username password:(NSString *)password block:(void (^)(DBUser *, NSError *))block {
    NSString *authEmail = [username containsString:@"@"] ? username : [NSString stringWithFormat:@"%@@babynames.com", username];
    [[FIRAuth auth] signInWithEmail:authEmail password:password completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        if (error) {
            if (block) block(nil, error);
        } else {
            DBUser *user = [[DBUser alloc] init];
            user.objectId = authResult.user.uid;
            user.email = authResult.user.email;
            user.username = username;
            _currentUser = user;
            
            [user fetchInBackgroundWithBlock:^(DBObject *fetchedUser, NSError *fetchError) {
                if (block) block((DBUser *)fetchedUser, nil);
            }];
        }
    }];
}

+ (void)beginWithEmail:(NSString *)email password:(NSString *)password block:(void (^)(DBUser *, BOOL, NSError *))block {
    NSString *cleanEmail = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
    if (cleanEmail.length == 0 || password.length == 0) {
        if (block) {
            NSError *err = [NSError errorWithDomain:@"BabyNames" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Please enter both email and password."}];
            block(nil, NO, err);
        }
        return;
    }
    
    [[FIRAuth auth] signInWithEmail:cleanEmail password:password completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable signInError) {
        if (!signInError && authResult.user) {
            DBUser *user = [[DBUser alloc] init];
            user.objectId = authResult.user.uid;
            user.email = authResult.user.email;
            user.username = [cleanEmail componentsSeparatedByString:@"@"].firstObject;
            _currentUser = user;
            [user fetchInBackgroundWithBlock:^(DBObject *fetchedUser, NSError *fetchError) {
                if (block) block((DBUser *)fetchedUser, NO, nil);
            }];
        } else {
            [[FIRAuth auth] createUserWithEmail:cleanEmail password:password completion:^(FIRAuthDataResult * _Nullable createResult, NSError * _Nullable createError) {
                if (!createError && createResult.user) {
                    DBUser *user = [[DBUser alloc] init];
                    user.objectId = createResult.user.uid;
                    user.email = createResult.user.email;
                    NSString *uname = [cleanEmail componentsSeparatedByString:@"@"].firstObject;
                    user.username = uname;
                    [user setObject:uname forKey:@"username"];
                    [user setObject:cleanEmail forKey:@"email"];
                    [user setObject:@25 forKey:@"limit"];
                    [user setObject:@"ALL" forKey:@"letter"];
                    [user setObject:@"Adam" forKey:@"name"];
                    [user setObject:@"All" forKey:@"gender"];
                    [user setObject:@"Account" forKey:@"lastPage"];
                    [user setObject:@"popular" forKey:@"sort"];
                    _currentUser = user;
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *saveError) {
                        if (block) block(user, YES, nil);
                    }];
                } else {
                    if (createError.code == FIRAuthErrorCodeEmailAlreadyInUse) {
                        NSError *err = [NSError errorWithDomain:@"BabyNames" code:FIRAuthErrorCodeWrongPassword userInfo:@{NSLocalizedDescriptionKey: @"Incorrect password. Tap Forgot Password to reset."}];
                        if (block) block(nil, NO, err);
                    } else {
                        if (block) block(nil, NO, createError);
                    }
                }
            }];
        }
    }];
}

+ (void)beginWithGoogleFromViewController:(UIViewController *)viewController block:(void (^)(DBUser *, NSError *))block {
    @try {
        if (!GIDSignIn.sharedInstance.configuration) {
            NSString *clientID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GIDClientID"];
            if (!clientID) {
                clientID = @"486710219401-nraiolsfoqqivgktvq1nps726anor72d.apps.googleusercontent.com";
            }
            GIDSignIn.sharedInstance.configuration = [[GIDConfiguration alloc] initWithClientID:clientID];
        }
        
        [GIDSignIn.sharedInstance signInWithPresentingViewController:viewController completion:^(GIDSignInResult * _Nullable signInResult, NSError * _Nullable error) {
            if (error) {
                if (block) block(nil, error);
                return;
            }
            
            GIDGoogleUser *gUser = signInResult.user;
            NSString *idToken = gUser.idToken.tokenString;
            NSString *accessToken = gUser.accessToken.tokenString;
            
            FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:idToken accessToken:accessToken];
            [[FIRAuth auth] signInWithCredential:credential completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable authError) {
                if (authError) {
                    if (block) block(nil, authError);
                    return;
                }
                FIRUser *fbUser = authResult.user;
                DBUser *user = [[DBUser alloc] init];
                user.objectId = fbUser.uid;
                user.email = fbUser.email;
                NSString *uname = fbUser.displayName.length > 0 ? fbUser.displayName : [fbUser.email componentsSeparatedByString:@"@"].firstObject;
                user.username = uname;
                _currentUser = user;
                
                [user fetchInBackgroundWithBlock:^(DBObject *fetchedUser, NSError *fetchError) {
                    if (!user[@"username"]) {
                        [user setObject:uname forKey:@"username"];
                        [user setObject:fbUser.email forKey:@"email"];
                        [user setObject:@25 forKey:@"limit"];
                        [user setObject:@"ALL" forKey:@"letter"];
                        [user setObject:@"Adam" forKey:@"name"];
                        [user setObject:@"All" forKey:@"gender"];
                        [user setObject:@"Account" forKey:@"lastPage"];
                        [user setObject:@"popular" forKey:@"sort"];
                        [user saveInBackground];
                    }
                    if (block) block(user, nil);
                }];
            }];
        }];
    } @catch (NSException *exception) {
        NSLog(@"Exception in beginWithGoogleFromViewController: %@", exception);
        if (block) {
            NSError *err = [NSError errorWithDomain:@"BabyNamesGoogle" code:-1 userInfo:@{NSLocalizedDescriptionKey: exception.reason ?: @"Google Sign-In failed"}];
            block(nil, err);
        }
    }
}

+ (void)logOut {
    NSError *error;
    [[FIRAuth auth] signOut:&error];
    [GIDSignIn.sharedInstance signOut];
    _currentUser = nil;
}

- (void)signUpInBackgroundWithBlock:(void (^)(BOOL, NSError *))block {
    NSString *authEmail = (self.email && self.email.length > 0) ? self.email : [NSString stringWithFormat:@"%@@babynames.com", self.username];
    [[FIRAuth auth] createUserWithEmail:authEmail password:self.password completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        if (error) {
            if (block) block(NO, error);
        } else {
            self.objectId = authResult.user.uid;
            if (self.username) [self setObject:self.username forKey:@"username"];
            if (self.email) [self setObject:self.email forKey:@"email"];
            _currentUser = self;
            [self saveInBackgroundWithBlock:block];
        }
    }];
}

+ (void)requestPasswordResetForEmailInBackground:(NSString *)email block:(void (^)(BOOL succeeded, NSError *error))block {
    [[FIRAuth auth] sendPasswordResetWithEmail:email completion:^(NSError * _Nullable error) {
        if (block) {
            block(error == nil, error);
        }
    }];
}
@end
