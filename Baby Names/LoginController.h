#import <UIKit/UIKit.h>
#import "Database.h"

@interface LoginController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@property (nonatomic, strong) UIButton *beginButton;
@property (nonatomic, strong) UIButton *googleBeginButton;
@property (nonatomic, strong) UIButton *forgotButton;

@property NSString *emailString;
@property NSString *passwordString;

- (void)begin;
- (void)beginWithGoogle;

@end
