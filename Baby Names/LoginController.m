#import "LoginController.h"

@interface LoginController () <UITextFieldDelegate>

@end

@implementation LoginController

#pragma mark - view

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getUser];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScreenEdgePanGestureRecognizer *left = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(leftEdge:)];
    UIScreenEdgePanGestureRecognizer *right = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(rightEdge:)];
    left.edges = UIRectEdgeLeft;
    right.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:left];
    [self.view addGestureRecognizer:right];
    
    [self layoutProgrammatically];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    [self getUser];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textDidChange:(NSNotification *)note {
    [self updateButtonStates];
}

- (void)getUser {
    DBUser *currentUser = [DBUser currentUser];
    if (currentUser != nil) {
        self.loginLabel.text = [NSString stringWithFormat:@"Logged in as:\n%@", currentUser.email ?: currentUser.username ?: @"User"];
        self.loginLabel.textColor = [UIColor labelColor];
        self.emailLabel.hidden = YES;
        self.passwordLabel.hidden = YES;
        self.forgotButton.hidden = YES;
        self.beginButton.hidden = YES;
        self.googleBeginButton.hidden = YES;
        self.logoutButton.hidden = NO;
        self.logoutButton.alpha = 1.0;
        
        self.loginButton.hidden = YES;
        self.signupButton.hidden = YES;
    } else {
        self.loginLabel.text = @"Type your email and password below.";
        self.loginLabel.textColor = [UIColor labelColor];
        self.emailLabel.hidden = NO;
        self.passwordLabel.hidden = NO;
        self.forgotButton.hidden = NO;
        self.beginButton.hidden = NO;
        self.googleBeginButton.hidden = NO;
        self.logoutButton.hidden = YES;
        
        self.loginButton.hidden = YES;
        self.signupButton.hidden = YES;
        
        [self updateButtonStates];
    }
}

- (void)updateButtonStates {
    if ([DBUser currentUser] == nil) {
        NSString *e = [self.emailLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *p = self.passwordLabel.text;
        if (e.length > 0 && p.length > 0) {
            self.beginButton.enabled = YES;
            self.beginButton.alpha = 1.0;
        } else {
            self.beginButton.enabled = NO;
            self.beginButton.alpha = 0.4;
        }
    }
}

- (void)updateBorderColors {
    self.emailLabel.layer.borderColor = [UIColor separatorColor].CGColor;
    self.passwordLabel.layer.borderColor = [UIColor separatorColor].CGColor;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self updateBorderColors];
}

- (void)layoutProgrammatically {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // Clean any existing subviews from storyboard just in case
    for (UIView *sub in [self.view.subviews copy]) {
        [sub removeFromSuperview];
    }
    
    // Tap to dismiss keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    // Status/Header Label
    self.loginLabel = [[UILabel alloc] init];
    self.loginLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.loginLabel.textColor = [UIColor labelColor];
    self.loginLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.loginLabel.textAlignment = NSTextAlignmentCenter;
    self.loginLabel.numberOfLines = 0;
    self.loginLabel.alpha = 1.0;
    
    // Email Field
    self.emailLabel = [[UITextField alloc] init];
    self.emailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.emailLabel.textColor = [UIColor labelColor];
    self.emailLabel.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.emailLabel.borderStyle = UITextBorderStyleNone;
    self.emailLabel.layer.cornerRadius = 10;
    self.emailLabel.layer.masksToBounds = YES;
    self.emailLabel.layer.borderWidth = 1.0;
    self.emailLabel.font = [UIFont systemFontOfSize:16];
    self.emailLabel.tintColor = [UIColor systemBlueColor];
    self.emailLabel.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailLabel.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailLabel.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailLabel.spellCheckingType = UITextSpellCheckingTypeNo;
    self.emailLabel.clearsOnBeginEditing = NO;
    self.emailLabel.returnKeyType = UIReturnKeyNext;
    self.emailLabel.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email"
                                                                            attributes:@{NSForegroundColorAttributeName: [UIColor placeholderTextColor]}];
    UIView *emailPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 48)];
    self.emailLabel.leftView = emailPadding;
    self.emailLabel.leftViewMode = UITextFieldViewModeAlways;
    UIView *emailRightPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 48)];
    self.emailLabel.rightView = emailRightPadding;
    self.emailLabel.rightViewMode = UITextFieldViewModeAlways;
    [self.emailLabel.heightAnchor constraintEqualToConstant:48].active = YES;
    self.emailLabel.delegate = self;
    
    // Password Field
    self.passwordLabel = [[UITextField alloc] init];
    self.passwordLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.passwordLabel.textColor = [UIColor labelColor];
    self.passwordLabel.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.passwordLabel.borderStyle = UITextBorderStyleNone;
    self.passwordLabel.layer.cornerRadius = 10;
    self.passwordLabel.layer.masksToBounds = YES;
    self.passwordLabel.layer.borderWidth = 1.0;
    self.passwordLabel.font = [UIFont systemFontOfSize:16];
    self.passwordLabel.tintColor = [UIColor systemBlueColor];
    self.passwordLabel.secureTextEntry = YES;
    self.passwordLabel.clearsOnBeginEditing = NO;
    self.passwordLabel.returnKeyType = UIReturnKeyDone;
    self.passwordLabel.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password"
                                                                               attributes:@{NSForegroundColorAttributeName: [UIColor placeholderTextColor]}];
    UIView *passPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 48)];
    self.passwordLabel.leftView = passPadding;
    self.passwordLabel.leftViewMode = UITextFieldViewModeAlways;
    UIView *passRightPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 48)];
    self.passwordLabel.rightView = passRightPadding;
    self.passwordLabel.rightViewMode = UITextFieldViewModeAlways;
    [self.passwordLabel.heightAnchor constraintEqualToConstant:48].active = YES;
    self.passwordLabel.delegate = self;
    
    [self updateBorderColors];
    if (@available(iOS 17.0, *)) {
        [self registerForTraitChanges:@[[UITraitUserInterfaceStyle self]] withAction:@selector(updateBorderColors)];
    }
    
    // Forgot Password Button
    self.forgotButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.forgotButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.forgotButton setTitle:@"Forgot Password?" forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    self.forgotButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    [self.forgotButton addTarget:self action:@selector(forgotPasswordTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // Begin Button
    self.beginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.beginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.beginButton setTitle:@"Begin" forState:UIControlStateNormal];
    self.beginButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.beginButton.backgroundColor = [UIColor systemBlueColor];
    [self.beginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.beginButton.layer.cornerRadius = 10;
    [self.beginButton.heightAnchor constraintEqualToConstant:50].active = YES;
    [self.beginButton addTarget:self action:@selector(beginAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Begin with Google Button
    self.googleBeginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.googleBeginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.googleBeginButton setTitle:@"Begin with Google" forState:UIControlStateNormal];
    self.googleBeginButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.googleBeginButton.backgroundColor = [UIColor colorWithRed:0.26 green:0.52 blue:0.96 alpha:1.0];
    [self.googleBeginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.googleBeginButton.layer.cornerRadius = 10;
    [self.googleBeginButton.heightAnchor constraintEqualToConstant:50].active = YES;
    [self.googleBeginButton addTarget:self action:@selector(beginWithGoogleAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Logout Button
    self.logoutButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.logoutButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.logoutButton setTitle:@"Log Out" forState:UIControlStateNormal];
    self.logoutButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.logoutButton.backgroundColor = [UIColor systemRedColor];
    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.logoutButton.layer.cornerRadius = 10;
    [self.logoutButton.heightAnchor constraintEqualToConstant:50].active = YES;
    [self.logoutButton addTarget:self action:@selector(logoutAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // UIStackView
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.loginLabel,
        self.emailLabel,
        self.passwordLabel,
        self.forgotButton,
        self.beginButton,
        self.googleBeginButton,
        self.logoutButton
    ]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 16;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];
    
    [NSLayoutConstraint activateConstraints:@[
        [stack.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-20],
        [stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:32],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-32]
    ]];
}

- (void)beginAction:(id)sender {
    [self begin];
}

- (void)begin {
    NSString *email = [self.emailLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = self.passwordLabel.text;
    
    self.loginLabel.text = @"Checking account...";
    self.loginLabel.textColor = [UIColor labelColor];
    
    [DBUser beginWithEmail:email password:password block:^(DBUser *user, BOOL isNewUser, NSError *error) {
        if (user) {
            [self getUser];
            [self performSegueWithIdentifier:@"home" sender:nil];
            [self lastPage];
        } else {
            self.loginLabel.text = error.localizedDescription ?: @"Authentication error";
            self.loginLabel.textColor = [UIColor systemRedColor];
        }
    }];
}

- (void)beginWithGoogleAction:(id)sender {
    [self beginWithGoogle];
}

- (void)beginWithGoogle {
    self.loginLabel.text = @"Signing in with Google...";
    self.loginLabel.textColor = [UIColor labelColor];
    
    @try {
        [DBUser beginWithGoogleFromViewController:self block:^(DBUser *user, NSError *error) {
            if (user) {
                [self getUser];
                [self performSegueWithIdentifier:@"home" sender:nil];
                [self lastPage];
            } else {
                self.loginLabel.text = error.localizedDescription ?: @"Google Sign-In failed";
                self.loginLabel.textColor = [UIColor systemRedColor];
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"Exception in beginWithGoogle: %@", exception);
        self.loginLabel.text = exception.reason ?: @"Google Sign-In error";
        self.loginLabel.textColor = [UIColor systemRedColor];
    }
}

- (void)logoutAction:(id)sender {
    [DBUser logOut];
    self.emailLabel.text = @"";
    self.passwordLabel.text = @"";
    [self getUser];
}

- (void)forgotPasswordTapped:(id)sender {
    NSString *email = [self.emailLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (email.length == 0) {
        self.loginLabel.text = @"Enter email to reset password";
        self.loginLabel.textColor = [UIColor systemRedColor];
        return;
    }
    
    [DBUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            self.loginLabel.text = @"Password reset email sent";
            self.loginLabel.textColor = [UIColor systemGreenColor];
        } else {
            self.loginLabel.text = error.localizedDescription ?: @"Error resetting password";
            self.loginLabel.textColor = [UIColor systemRedColor];
        }
    }];
}

#pragma mark - text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailLabel) {
        [self.passwordLabel becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self begin];
    }
    return NO;
}

#pragma mark - edge pan gesture

- (void)leftEdge:(UIScreenEdgePanGestureRecognizer *)edgeRecognizer {
    if ([DBUser currentUser]) {
        [self performSegueWithIdentifier:@"home" sender:nil];
    }
}

- (void)rightEdge:(UIScreenEdgePanGestureRecognizer *)edgeRecognizer {
    if ([DBUser currentUser]) {
        [self performSegueWithIdentifier:@"home" sender:nil];
    }
}

- (void)lastPage {
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:@"Account" forKey:@"lastPage"];
    [currentUser saveInBackground];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [segue.destinationViewController setModalPresentationStyle:UIModalPresentationFullScreen];
}

@end
