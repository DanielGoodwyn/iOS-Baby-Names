#import <UIKit/UIKit.h>
#import "Database.h"

@interface LoginController : UIViewController

@property (nonatomic, strong) UILabel *loginLabel;
@property (nonatomic, strong) UITextField *emailLabel;
@property (nonatomic, strong) UITextField *passwordLabel;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *logoutButton;
@property (nonatomic, strong) UIButton *signupButton;

@property (nonatomic, strong) UIButton *beginButton;
@property (nonatomic, strong) UIButton *googleBeginButton;
@property (nonatomic, strong) UIButton *forgotButton;

@property NSString *emailString;
@property NSString *passwordString;

- (void)begin;
- (void)beginWithGoogle;

@end
