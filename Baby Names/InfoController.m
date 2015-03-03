
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
}

- (void)viewWillAppear:(BOOL)animated {
    NSArray *parsed = [_detailItem componentsSeparatedByString:@","];
    self.genderString = parsed[0];
    self.letterString = parsed[1];
    self.nameString = parsed[2];
    self.limitNumber = [parsed[3] intValue];
    if ([self.genderString isEqual:@"M"]) {
        self.genderString =@"👦";
    } if ([self.genderString isEqual:@"F"]) {
        self.genderString =@"👧";
    }
    if ([self.genderString isEqual:@"👦"]) {
        [self.view setBackgroundColor:[UIColor colorWithRed:.8 green:.85 blue:1 alpha:1]];
    } if ([self.genderString isEqual:@"👧"]) {
        [self.view setBackgroundColor:[UIColor colorWithRed:1 green:.8 blue:.85 alpha:1]];
    }
    self.urlString = @"http://www.behindthename.com/name/";
    
    self.genderLabel.text = self.genderString;
    if ([self.letterString isEqualToString:@"ALL"]) {
        self.letterLabel.text = @"*";
    } else {
        self.letterLabel.text = self.letterString;
    }
    
    self.nameLabel.text = self.nameString;
    if ([self.genderString isEqual:@"👦"]) {
        [self.view setBackgroundColor:[UIColor colorWithRed:.8 green:.85 blue:1 alpha:1]];
    } if ([self.genderString isEqual:@"👧"]) {
        [self.view setBackgroundColor:[UIColor colorWithRed:1 green:.8 blue:.85 alpha:1]];
    }
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
}

#pragma mark - buttons

- (IBAction)back:(id)sender {
    [self goBack];
}

- (void)goBack {
    PFUser *currentUser = [PFUser currentUser];
    NSString *lastPage = [currentUser objectForKey:@"lastPage"];
    if ([lastPage isEqualToString:@"NewNames" ]) {
        NameController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NameController"];
        [self.view.window makeKeyAndVisible];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    if ([lastPage isEqualToString:@"MyNames" ]) {
        NamesController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NamesController"];
        [self.view.window makeKeyAndVisible];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    [self lastPage];
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
    
    PFQuery *query = [PFQuery queryWithClassName:@"names"];
    [query whereKey:@"name" equalTo:self.nameString];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count>0){
            self.nameChosen = @"YES";
        } else {
            self.nameChosen = @"NO";
        }
        if ([self.nameChosen isEqualToString:@"NO"]) {
            PFUser *currentUser = [PFUser currentUser];
            
            PFObject *object = [PFObject objectWithClassName:@"names"];
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
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:@"Info" forKey:@"lastPage"];
    [currentUser saveInBackground];
}

@end
