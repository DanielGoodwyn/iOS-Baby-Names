
#import "InfoController.h"
#import "NameController.h"
#import "NamesController.h"

@interface InfoController ()

@end

@implementation InfoController

#pragma mark - view

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameChosen = @"NO";
    self.nameLabel.text = @"";
    self.letterLabel.text = @"";
}

- (void)viewWillAppear:(BOOL)animated {
    NSArray *parsed = [_detailItem componentsSeparatedByString:@","];
    self.genderString = parsed[0];
    self.letterString = parsed[1];
    self.nameString = parsed[2];
    self.limitNumber = [parsed[3] intValue];
    if ([self.genderString isEqualToString:@"M"] || [self.genderString isEqualToString:@"👦"]) {
        self.genderString = @"M";
    } else if ([self.genderString isEqualToString:@"F"] || [self.genderString isEqualToString:@"👧"]) {
        self.genderString = @"F";
    } else {
        self.genderString = @"All";
    }
    
    self.genderLabel.text = @"";
    self.genderLabel.hidden = YES;
    
    if (!self.genderImageView) {
        self.genderImageView = [[UIImageView alloc] init];
        self.genderImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.genderImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.genderImageView];
    }
    if ([self.genderString isEqualToString:@"M"]) {
        self.genderImageView.image = [UIImage imageNamed:@"face_boy"];
        [self.view setBackgroundColor:[UIColor colorWithRed:.8 green:.85 blue:1 alpha:1]];
    } else if ([self.genderString isEqualToString:@"F"]) {
        self.genderImageView.image = [UIImage imageNamed:@"face_girl"];
        [self.view setBackgroundColor:[UIColor colorWithRed:1 green:.8 blue:.85 alpha:1]];
    } else {
        self.genderImageView.image = [UIImage imageNamed:@"face_baby"];
        [self.view setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    }
    self.urlString = @"https://www.behindthename.com/name/";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.urlString,self.nameString]];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    [self.view addSubview:self.webView];
    
    UIScreenEdgePanGestureRecognizer *left = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(leftEdge:)];
    UIScreenEdgePanGestureRecognizer *right = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(rightEdge:)];
    left.edges = UIRectEdgeLeft;
    right.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:left];
    [self.view addGestureRecognizer:right];
    
    [self layoutProgrammatically];
}

- (void)layoutProgrammatically {
    [self.view removeConstraints:self.view.constraints];
    [self.nameLabel removeConstraints:self.nameLabel.constraints];
    [self.webView removeConstraints:self.webView.constraints];
    
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.genderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.letterLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (!self.genderImageView) {
        self.genderImageView = [[UIImageView alloc] init];
        self.genderImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.genderImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.genderImageView];
    }
    
    UIButton *backBtn = nil, *saveBtn = nil;
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)v;
            btn.translatesAutoresizingMaskIntoConstraints = NO;
            NSString *title = [btn titleForState:UIControlStateNormal];
            if ([title isEqualToString:@"◀️"] || btn.tag == 101 || [btn.currentImage isEqual:[UIImage imageNamed:@"tool_back"]] || [[btn actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] containsObject:@"back:"] || btn.frame.origin.x < 150) backBtn = btn;
            else if ([title isEqualToString:@"💾"] || btn.tag == 102 || [btn.currentImage isEqual:[UIImage imageNamed:@"tool_save"]] || [[btn actionsForTarget:self forControlEvent:UIControlEventTouchDown] containsObject:@"save:"] || btn.frame.origin.x > 300) saveBtn = btn;
        }
    }
    
    if (backBtn) {
        [backBtn setImage:[UIImage imageNamed:@"tool_back"] forState:UIControlStateNormal];
        [backBtn setTitle:@"" forState:UIControlStateNormal];
        backBtn.tintColor = [UIColor labelColor];
        backBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    if (saveBtn) {
        [saveBtn setImage:[UIImage imageNamed:@"tool_save"] forState:UIControlStateNormal];
        [saveBtn setTitle:@"" forState:UIControlStateNormal];
        saveBtn.tintColor = [UIColor labelColor];
        saveBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    [NSLayoutConstraint activateConstraints:@[
        [self.nameLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.nameLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:70],
        [self.nameLabel.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-40],
        
        [self.webView.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:20],
        [self.webView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.webView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.webView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        
        [self.letterLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
        [self.letterLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:30],
        
        [self.genderImageView.centerYAnchor constraintEqualToAnchor:self.letterLabel.centerYAnchor],
        [self.genderImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-30],
        [self.genderImageView.widthAnchor constraintEqualToConstant:36],
        [self.genderImageView.heightAnchor constraintEqualToConstant:36]
    ]];
    
    if (backBtn) {
        [NSLayoutConstraint activateConstraints:@[
            [backBtn.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
            [backBtn.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:20],
            [backBtn.widthAnchor constraintEqualToConstant:44],
            [backBtn.heightAnchor constraintEqualToConstant:44]
        ]];
    }
    
    if (saveBtn) {
        [NSLayoutConstraint activateConstraints:@[
            [saveBtn.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
            [saveBtn.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-20],
            [saveBtn.widthAnchor constraintEqualToConstant:44],
            [saveBtn.heightAnchor constraintEqualToConstant:44]
        ]];
    }
}

#pragma mark - buttons

- (void)dealloc {
    self.webView.delegate = nil;
}

- (IBAction)back:(id)sender {
    [self goBack];
}

- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    
    self.nameChosen = @"NO";
    NSString * genderLetter;
    if ([self.genderString isEqual:@"👦"]||[self.genderString isEqual:@"M"]) {
        genderLetter =@"M";
    } if ([self.genderString isEqual:@"👧"]||[self.genderString isEqual:@"F"]) {
        genderLetter =@"F";
    }
    
    // save name
    // https://parse.com/docs/ios_guide#objects-saving/iOS
    
    DBUser *currentUser = [DBUser currentUser];
    DBQuery *query = [DBQuery queryWithClassName:@"names"];
    [query whereKey:@"name" equalTo:self.nameString];
    [query whereKey:@"userId" equalTo:[currentUser objectId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count>0){
            self.nameChosen = @"YES";
        } else {
            self.nameChosen = @"NO";
        }
        if ([self.nameChosen isEqualToString:@"NO"]) {
            DBObject *object = [DBObject objectWithClassName:@"names"];
            object[@"name"] = self.nameString;
            object[@"gender"] = genderLetter;
            object[@"userId"] = [currentUser objectId];
            [object saveInBackground];
            
            self.nameLabel.text = self.nameString;
            UIColor *originalColor = self.view.backgroundColor;
            [UIView animateWithDuration:.1
                             animations:^{
                                 [self.view setBackgroundColor:[UIColor whiteColor]];
                             }
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration:.1
                                                  animations:^{
                                                      [self.view setBackgroundColor: originalColor];}
                                                  completion:^(BOOL finished) {
                                                  }];
                             }];
        } else {
            self.nameChosen = @"NO";
            UIColor *originalColor = self.view.backgroundColor;
            [UIView animateWithDuration:.1
                             animations:^{
                                 [self.view setBackgroundColor:[UIColor redColor]];
                             }
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration:.1
                                                  animations:^{
                                                      [self.view setBackgroundColor: originalColor];}
                                                  completion:^(BOOL finished) {
                                                  }];
                                 self.nameChosen = @"NO";
                             }];
            self.nameChosen = @"NO";
        }
    }];
}

#pragma mark - detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
}

#pragma mark - edge pan gesture

- (void)leftEdge: (UIScreenEdgePanGestureRecognizer*)edgeRecognizer{
    [self goBack];
}

- (void)rightEdge: (UIScreenEdgePanGestureRecognizer*)edgeRecognizer{
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [segue.destinationViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    NSString *genderLetter;
    if ([self.genderString isEqual:@"👦"]) {
        genderLetter =@"M";
    } if ([self.genderString isEqual:@"👧"]) {
        genderLetter =@"F";
    }
    
    if ([[segue identifier] isEqualToString:@"home"]) {
        NSObject *object = [NSString stringWithFormat:@"%@,%@,%@,%i", genderLetter, self.letterString, self.nameString,self.limitNumber];
        [[segue destinationViewController] setDetailItem:object];
    }
}

- (void)lastPage {
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:@"Info" forKey:@"lastPage"];
    [currentUser saveInBackground];
}

@end
