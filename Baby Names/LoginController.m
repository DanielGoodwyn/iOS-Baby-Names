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
        self.guestButton.hidden = YES;
        self.googleBeginButton.hidden = YES;
        self.logoutButton.hidden = NO;
        self.logoutButton.alpha = 1.0;
        self.deleteAccountButton.hidden = NO;
        self.deleteAccountButton.alpha = 1.0;
        
        self.loginButton.hidden = YES;
        self.signupButton.hidden = YES;
    } else {
        self.loginLabel.text = @"Sign in to sync your favorite baby names across devices, or continue as a guest.";
        self.loginLabel.textColor = [UIColor labelColor];
        self.emailLabel.hidden = NO;
        self.passwordLabel.hidden = NO;
        self.forgotButton.hidden = NO;
        self.beginButton.hidden = NO;
        self.guestButton.hidden = NO;
        self.googleBeginButton.hidden = YES;
        self.logoutButton.hidden = YES;
        self.deleteAccountButton.hidden = YES;
        
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
    
    // Close / Back Button
    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.closeButton setTitle:@"✕" forState:UIControlStateNormal];
    self.closeButton.titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    [self.closeButton setTitleColor:[UIColor secondaryLabelColor] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.closeButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [self.closeButton.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:20],
        [self.closeButton.widthAnchor constraintEqualToConstant:44],
        [self.closeButton.heightAnchor constraintEqualToConstant:44]
    ]];

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
    
    // Continue as Guest Button
    self.guestButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.guestButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.guestButton setTitle:@"Continue as Guest" forState:UIControlStateNormal];
    self.guestButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self.guestButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    self.guestButton.backgroundColor = [UIColor clearColor];
    [self.guestButton.heightAnchor constraintEqualToConstant:44].active = YES;
    [self.guestButton addTarget:self action:@selector(guestAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Logout Button
    self.logoutButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.logoutButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.logoutButton setTitle:@"Log Out" forState:UIControlStateNormal];
    self.logoutButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.logoutButton.backgroundColor = [UIColor systemBlueColor];
    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.logoutButton.layer.cornerRadius = 10;
    [self.logoutButton.heightAnchor constraintEqualToConstant:50].active = YES;
    [self.logoutButton addTarget:self action:@selector(logoutAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Delete Account Button (Guideline 5.1.1(v))
    self.deleteAccountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.deleteAccountButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.deleteAccountButton setTitle:@"Delete Account" forState:UIControlStateNormal];
    self.deleteAccountButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    [self.deleteAccountButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    self.deleteAccountButton.backgroundColor = [UIColor clearColor];
    [self.deleteAccountButton.heightAnchor constraintEqualToConstant:44].active = YES;
    [self.deleteAccountButton addTarget:self action:@selector(deleteAccountAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // UIStackView
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.loginLabel,
        self.emailLabel,
        self.passwordLabel,
        self.forgotButton,
        self.beginButton,
        self.guestButton,
        self.logoutButton,
        self.deleteAccountButton
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

- (void)returnToHome {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        @try {
            [self performSegueWithIdentifier:@"home" sender:nil];
        } @catch (NSException *e) {
            NSLog(@"Segue home: %@", e);
        }
    }
}

- (void)closeAction:(id)sender {
    [self returnToHome];
}

- (void)guestAction:(id)sender {
    [self returnToHome];
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
            [self lastPage];
            [self returnToHome];
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
    // Deprecated in favor of direct email/password authentication
}

- (void)logoutAction:(id)sender {
    [DBUser logOut];
    self.emailLabel.text = @"";
    self.passwordLabel.text = @"";
    [self getUser];
}

- (void)deleteAccountAction:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Account"
                                                                   message:@"Are you sure you want to permanently delete your account and all associated saved favorite names? This action cannot be undone."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete Account" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.loginLabel.text = @"Deleting account...";
        self.loginLabel.textColor = [UIColor labelColor];
        self.deleteAccountButton.enabled = NO;
        self.logoutButton.enabled = NO;
        
        [DBUser deleteCurrentUserWithCompletion:^(BOOL succeeded, NSError *error) {
            self.deleteAccountButton.enabled = YES;
            self.logoutButton.enabled = YES;
            if (succeeded) {
                self.emailLabel.text = @"";
                self.passwordLabel.text = @"";
                [self getUser];
                
                UIAlertController *doneAlert = [UIAlertController alertControllerWithTitle:@"Account Deleted"
                                                                                   message:@"Your account and all associated saved names have been permanently deleted."
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                [doneAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:doneAlert animated:YES completion:nil];
            } else {
                self.loginLabel.text = error.localizedDescription ?: @"Error deleting account";
                self.loginLabel.textColor = [UIColor systemRedColor];
            }
        }];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
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
    [self returnToHome];
}

- (void)rightEdge:(UIScreenEdgePanGestureRecognizer *)edgeRecognizer {
    [self returnToHome];
}

- (void)lastPage {
    DBUser *currentUser = [DBUser currentUser];
    if (currentUser) {
        [currentUser setObject:@"Account" forKey:@"lastPage"];
        [currentUser saveInBackground];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [segue.destinationViewController setModalPresentationStyle:UIModalPresentationFullScreen];
}

@end
