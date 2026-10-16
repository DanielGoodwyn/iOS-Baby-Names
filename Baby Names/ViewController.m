
#import "ViewController.h"
#import "NameController.h"
#import "LoginController.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - login

- (void)login {
    DBUser *currentUser = [DBUser currentUser];
    if (currentUser == nil) {
        LoginController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginController"];
        loginController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.view.window makeKeyAndVisible];
        [self presentViewController:loginController animated:NO completion:nil];
    }
}

#pragma mark - view

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self.alphabet removeAllObjects];
    self.alphabetIndex = 0;

    self.alphabet = [NSMutableArray arrayWithArray: @[
    @"ALL",
    @"A", @"B", @"C", @"D", @"E", @"F",
    @"G", @"H", @"I", @"J", @"K", @"L",
    @"M", @"N", @"O", @"P", @"Q", @"R",
    @"S", @"T", @"U", @"V", @"W", @"X",
    @"Y", @"Z" ]];
    
    [self.alphabetPicker selectRow:self.alphabetIndex inComponent:0 animated:YES];
    
    UIScreenEdgePanGestureRecognizer *left = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(leftEdge:)];
    UIScreenEdgePanGestureRecognizer *right = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(rightEdge:)];
    left.edges = UIRectEdgeLeft;
    right.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:left];
    [self.view addGestureRecognizer:right];
    
    [self layoutProgrammatically];
}

- (void)layoutProgrammatically {
    UIButton *boyBtn = nil, *bothBtn = nil, *girlBtn = nil;
    UIButton *topBtn = nil, *playBtn = nil, *profileBtn = nil, *notesBtn = nil;
    
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)v;
            btn.translatesAutoresizingMaskIntoConstraints = NO; // Enable auto layout
            NSString *title = [btn titleForState:UIControlStateNormal];
            if ([title isEqualToString:@"👦"]) boyBtn = btn;
            else if ([title isEqualToString:@"👶"]) bothBtn = btn;
            else if ([title isEqualToString:@"👧"]) girlBtn = btn;
            else if ([title isEqualToString:@"TOP"]) topBtn = btn;
            else {
                // Determine by frame position to identify remaining buttons
                if (btn.frame.origin.y < 100) {
                    if (btn.frame.origin.x < 150) profileBtn = btn; // Top left
                    else notesBtn = btn; // Top right
                } else if (btn.frame.origin.y > 300) {
                    playBtn = btn; // Bottom right play button
                }
            }
        }
    }
    
    // Top Bar (Profile, Notes)
    if (profileBtn && notesBtn) {
        [NSLayoutConstraint activateConstraints:@[
            [profileBtn.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
            [profileBtn.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:20],
            
            [notesBtn.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
            [notesBtn.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-20]
        ]];
    }
    
    // Center Emojis
    if (boyBtn && bothBtn && girlBtn) {
        UIStackView *emojiStack = [[UIStackView alloc] initWithArrangedSubviews:@[boyBtn, bothBtn, girlBtn]];
        emojiStack.axis = UILayoutConstraintAxisHorizontal;
        emojiStack.distribution = UIStackViewDistributionEqualSpacing;
        emojiStack.spacing = 20;
        emojiStack.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:emojiStack];
        
        [NSLayoutConstraint activateConstraints:@[
            [emojiStack.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [emojiStack.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-40],
        ]];
    }
    
    // Bottom Bar (TOP, limit textfield, Play)
    if (topBtn && playBtn && self.limitTextField) {
        self.limitTextField.translatesAutoresizingMaskIntoConstraints = NO;
        self.limitTextField.textColor = [UIColor labelColor];
        
        [NSLayoutConstraint activateConstraints:@[
            [topBtn.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
            [topBtn.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:20],
            
            [self.limitTextField.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
            [self.limitTextField.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            
            [playBtn.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
            [playBtn.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-20]
        ]];
    }
    
    // Alphabet Picker
    self.alphabetPicker.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.alphabetPicker.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.alphabetPicker.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-80],
        [self.alphabetPicker.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.9]
    ]];
}

- (UIColor *)boyBackgroundColor {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull tc) {
        if (tc.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return [UIColor colorWithRed:0.12 green:0.21 blue:0.37 alpha:1.0];
        } else {
            return [UIColor colorWithRed:.8 green:.85 blue:1 alpha:1];
        }
    }];
}

- (UIColor *)girlBackgroundColor {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull tc) {
        if (tc.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return [UIColor colorWithRed:0.37 green:0.12 blue:0.24 alpha:1.0];
        } else {
            return [UIColor colorWithRed:1 green:.8 blue:.85 alpha:1];
        }
    }];
}

- (UIColor *)allBackgroundColor {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull tc) {
        if (tc.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return [UIColor colorWithRed:0.12 green:0.12 blue:0.12 alpha:1.0];
        } else {
            return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (!_detailItem) {
        self.genderString = @"👦";
        [self.view setBackgroundColor:[self boyBackgroundColor]];
        self.limitNumber = 25;
    } else {
        NSArray *parsed = [_detailItem componentsSeparatedByString:@","];
        self.genderString = parsed[0];
        self.letterString = parsed[1];
        self.limitNumber = [parsed[3] intValue];
        
        NSString *genderLetter;
        if ([self.genderString isEqual:@"M"]) {
            genderLetter =@"👦";
        } if ([self.genderString isEqual:@"F"]) {
            genderLetter =@"👧";
        } if ([self.genderString isEqual:@"All"]) {
            genderLetter =@"👶";
        }
        
        self.letterString = parsed[1];
        if ([genderLetter isEqual:@"👦"]) {
            [self.view setBackgroundColor:[self boyBackgroundColor]];
        } if ([genderLetter isEqual:@"👧"]) {
            [self.view setBackgroundColor:[self girlBackgroundColor]];
        } if ([genderLetter isEqual:@"👶"]) {
            [self.view setBackgroundColor:[self allBackgroundColor]];
        }
        
        for (int i = 0; i<[self.alphabet count]; i++) {
            if ([self.letterString isEqual: self.alphabet[i]]) {
                self.alphabetIndex = i;
            }
        }
    }
    self.limitTextField.text = [NSString stringWithFormat:@"%i",self.limitNumber];
    [self.alphabetPicker selectRow:self.alphabetIndex inComponent:0 animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    DBUser *currentUser = [DBUser currentUser];
    [self login];
    if ([self.genderString isEqual:@"👦"]) {
        self.genderString =@"M";
    } if ([self.genderString isEqual:@"👧"]) {
        self.genderString =@"F";
    } if ([self.genderString isEqual:@"👶"]) {
        self.genderString =@"All";
    }
    
    self.genderString = [currentUser objectForKey:@"gender"];
    
    self.letterString = [currentUser objectForKey:@"letter"];
    
    self.limitNumber = (int)[[currentUser objectForKey:@"limit"] integerValue];
    
    self.sortString = [currentUser objectForKey:@"sort"];
    
    if ([self.sortString isEqualToString:@"popular"]) {
        [self setPopular];
    } else if ([self.sortString isEqualToString:@"uncommon"]) {
        [self setUncommon];
    } else if ([self.sortString isEqualToString:@"namesAtoZ"]) {
        [self setNamesAtoZ];
    } else if ([self.sortString isEqualToString:@"namesZtoA"]) {
        [self setNamesZtoA];
    } else {
        self.sortString = @"popular";
        [self setPopular];
    }
    
    for (int i = 0; i<[self.alphabet count]; i++) {
        if ([self.letterString isEqual: self.alphabet[i]]) {
            self.alphabetIndex = i;
        }
    }
    
    [self.alphabetPicker selectRow:self.alphabetIndex inComponent:0 animated:YES];
    self.limitTextField.text = [NSString stringWithFormat: @"%i", self.limitNumber];
    
    if ([self.genderString isEqualToString:@"M"]) {
        [self.view setBackgroundColor:[self boyBackgroundColor]];
    } else if ([self.genderString isEqualToString:@"F"]) {
        [self.view setBackgroundColor:[self girlBackgroundColor]];
    } else {
        [self.view setBackgroundColor:[self allBackgroundColor]];
    }

}

#pragma mark - picker delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.alphabet.count;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = self.alphabet[row];
    return [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName: [UIColor labelColor]}];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.alphabet[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.alphabetIndex = (int)row;
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:self.alphabet[self.alphabetIndex] forKey:@"letter"];
    [currentUser saveInBackground];
}

#pragma mark - text field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self setLimitToUser];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self setLimitToUser];}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self setLimitToUser];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self setLimitToUser];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self setLimitToUser];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    self.limitNumber = [textField.text intValue];
    [self setLimitToUser];
    return YES;
}

#pragma mark - set parse data to user

- (void) setLimitToUser {
    self.limitNumber = [self.limitTextField.text intValue];
    if (self.limitNumber > 1000){
        self.limitNumber = 1000;
    }
    if (self.limitNumber < 1){
        self.limitNumber = 1;
    }
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject: [NSNumber numberWithInteger:self.limitNumber] forKey:@"limit"];
    [currentUser saveInBackground];
}

#pragma mark - detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
}

#pragma mark - edge pan gesture

- (void)leftEdge: (UIScreenEdgePanGestureRecognizer*)edgeRecognizer{
    [self lastPage];
    [self performSegueWithIdentifier:@"login" sender:edgeRecognizer];
}

- (void)rightEdge: (UIScreenEdgePanGestureRecognizer*)edgeRecognizer{
    [self lastPage];
    [self performSegueWithIdentifier:@"name" sender:edgeRecognizer];
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [segue.destinationViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self lastPage];
    
    NSString *genderLetter;
    genderLetter = self.genderString;
    if ([self.genderString isEqual:@"👦"]) {
        genderLetter =@"M";
    } if ([self.genderString isEqual:@"👧"]) {
        genderLetter =@"F";
    } if ([self.genderString isEqual:@"👶"]) {
        genderLetter =@"All";
    }
    
    if (self.limitNumber > 200){
        self.limitNumber = 200;
    }
    if (self.limitNumber < 1){
        self.limitNumber = 1;
    }

    if ([[segue identifier] isEqualToString:@"name"]) {
        NSObject *myString = [[NSObject alloc] init];
        myString = [NSString stringWithFormat:@"%@,%@,👶,%i",genderLetter, self.alphabet[self.alphabetIndex], self.limitNumber];
        [[segue destinationViewController] setDetailItem:myString];
    }
}

#pragma mark - buttons

- (IBAction)sort:(id)sender {
    UIAlertController * view = [UIAlertController alertControllerWithTitle:@"Sort" message:@"Select a sort order." preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* namesAtoZ = [UIAlertAction actionWithTitle:@"🔜 A-Z" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self setNamesAtoZ];
        [view dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction* namesZtoA = [UIAlertAction actionWithTitle:@"🔙 Z-A" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self setNamesZtoA];
        [view dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction* popular = [UIAlertAction actionWithTitle:@"🔝 popular ▶️" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self setPopular];
        [view dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction* uncommon = [UIAlertAction actionWithTitle:@"🔚 uncommon ▶️" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self setUncommon];
        [view dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction* newest = [UIAlertAction actionWithTitle:@"🆕 newest 📝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self setNewest];
        [view dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction* oldest = [UIAlertAction actionWithTitle:@"👴 oldest 📝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self setOldest];
        [view dismissViewControllerAnimated:YES completion:nil];
    }];
    [view addAction:namesAtoZ];
    [view addAction:namesZtoA];
    [view addAction:popular];
    [view addAction:uncommon];
    [view addAction:newest];
    [view addAction:oldest];
    [self presentViewController:view animated:YES completion:nil];
}

- (IBAction)boy:(id)sender {
    self.genderString = @"👦";
    [self.view setBackgroundColor:[self boyBackgroundColor]];
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:@"M" forKey:@"gender"];
    [currentUser saveInBackground];
}

- (IBAction)girl:(id)sender {
    self.genderString = @"👧";
    [self.view setBackgroundColor:[self girlBackgroundColor]];
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:@"F" forKey:@"gender"];
    [currentUser saveInBackground];
}

- (IBAction)either:(id)sender {
    self.genderString = @"👶";
    [self.view setBackgroundColor:[self allBackgroundColor]];
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:@"All" forKey:@"gender"];
    [currentUser saveInBackground];
}

- (void)lastPage {
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:@"Home" forKey:@"lastPage"];
    [currentUser saveInBackground];
}

#pragma mark - sort setters

- (void)setPopular {
    self.sortString = @"popular";
    [self.sortButton setTitle:@"🔝" forState:UIControlStateNormal];
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:@"popular" forKey:@"sort"];
    [currentUser saveInBackground];
}

- (void)setUncommon {
    self.sortString = @"uncommon";
    [self.sortButton setTitle:@"🔚" forState:UIControlStateNormal];
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:@"uncommon" forKey:@"sort"];
    [currentUser saveInBackground];
}

- (void)setNamesAtoZ {
    self.sortString = @"namesAtoZ";
    [self.sortButton setTitle:@"🔜" forState:UIControlStateNormal];
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:@"namesAtoZ" forKey:@"sort"];
    [currentUser saveInBackground];
}

- (void)setNamesZtoA {
    self.sortString = @"namesZtoA";
    [self.sortButton setTitle:@"🔙" forState:UIControlStateNormal];
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:@"namesZtoA" forKey:@"sort"];
    [currentUser saveInBackground];
}

- (void)setNewest {
    self.sortString = @"newest";
    [self.sortButton setTitle:@"🆕" forState:UIControlStateNormal];
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:@"newest" forKey:@"sort"];
    [currentUser saveInBackground];
}

- (void)setOldest {
    self.sortString = @"oldest";
    [self.sortButton setTitle:@"👴" forState:UIControlStateNormal];
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:@"oldest" forKey:@"sort"];
    [currentUser saveInBackground];
}

@end
