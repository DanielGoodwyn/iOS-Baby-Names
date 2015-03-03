
#import "LoginController.h"

@interface LoginController ()

@end

@implementation LoginController

#pragma mark - view

- (void)viewWillAppear:(BOOL)animated {
    [self getUser];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getUser];
    UIScreenEdgePanGestureRecognizer *left = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(leftEdge:)];
    UIScreenEdgePanGestureRecognizer *right = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(rightEdge:)];
    left.edges = UIRectEdgeLeft;
    right.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:left];
    [self.view addGestureRecognizer:right];
    
    PFUser *currentUser = [PFUser currentUser];
    if ([[currentUser username] isEqualToString:@""]) {
        self.usernameLabel.text = @" ";
    }
    if ([[currentUser email] isEqualToString:@""]) {
        self.emailLabel.text = @" ";
    }
    if ([[currentUser password] isEqualToString:@""]) {
        self.passwordLabel.text = @" ";
    }
    if (currentUser!=nil) {
        self.usernameString = [[currentUser username] capitalizedString];
        self.emailString = [currentUser email];
        self.passwordString = [currentUser password];
        self.usernameLabel.text = self.usernameString;
        self.emailLabel.text = self.emailString;
        self.passwordLabel.text = self.passwordString;
    } else {
        self.usernameString = @"";
        self.emailString = @"";
        self.passwordString = @"";
        self.usernameLabel.text = self.usernameString;
        self.emailLabel.text = self.emailString;
        self.passwordLabel.text = self.passwordString;
    }
}

- (void)getUser {
    PFUser *currentUser = [PFUser currentUser];
    if ([PFUser currentUser] != nil) {
        [self.loginButton setAlpha:0];
        [self.signupButton setAlpha:0];
        [self.logoutButton setAlpha:1];
        [self.loginLabel setAlpha:0];
        [self.passwordLabel setAlpha:0];
        self.loginLabel.text = [currentUser email];
        [self.loginLabel adjustsFontSizeToFitWidth];
        self.loginLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.loginLabel.text = [currentUser.username capitalizedString];
    } else {
        [self.loginButton setAlpha:1];
        [self.signupButton setAlpha:1];
        [self.logoutButton setAlpha:0];
        [self.loginLabel setAlpha:1];
        [self.passwordLabel setAlpha:1];
        self.loginLabel.text = @"login";
        self.usernameLabel.text = @"";
        self.emailLabel.text = @"";
        self.passwordLabel.text = @"";
    }
}

#pragma mark - text field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        self.usernameString = self.usernameLabel.text;
        self.passwordString = self.passwordLabel.text;
        [self logIn];
    }
    return NO;
}

#pragma mark - edge pan gesture

- (void)leftEdge: (UIScreenEdgePanGestureRecognizer*)edgeRecognizer{
    [self logIn];
}

- (void)rightEdge: (UIScreenEdgePanGestureRecognizer*)edgeRecognizer{
    [self logIn];
}

#pragma mark - buttons

- (IBAction)signup:(id)sender {
    [self signUp];
}

- (IBAction)login:(id)sender {
    [self logIn];
}

- (IBAction)logout:(id)sender {
    [PFUser logOut];
    [self getUser];
}

- (void)signUp {
    PFUser *user = [PFUser user];
    user.username = [self.usernameLabel.text lowercaseString];
    user.email = [self.emailLabel.text lowercaseString];
    user.password = self.passwordLabel.text;
    user[@"limit"] = @25;
    user[@"letter"] = @"A";
    user[@"name"] = @"Adam";
    user[@"gender"] = @"M";
    user[@"lastPage"] = @"Account";
    user[@"sort"] = @"popular";
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self logIn];
    }];
}

- (void)logIn {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [self performSegueWithIdentifier:@"home" sender:nil];
    } else {
        currentUser = [PFUser user];
        currentUser.username = self.usernameString;
        if (self.passwordString == nil) {
            self.passwordString = @"password";
        }
        currentUser.password = self.passwordString;
        [PFUser logInWithUsernameInBackground:[self.usernameLabel.text lowercaseString] password:[self.passwordLabel.text lowercaseString] block:^(PFUser *user, NSError *error) {
            if (user) {
                [self getUser];
                [self performSegueWithIdentifier:@"home" sender:nil];
            } else {
                self.loginLabel.text = @"login";
                [self signUp];
            }
        }];
        [self lastPage];
    }
}

- (void)lastPage {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:@"Account" forKey:@"lastPage"];
    [currentUser saveInBackground];
}

@end
