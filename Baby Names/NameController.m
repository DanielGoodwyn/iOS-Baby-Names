
#import "NameController.h"

@interface NameController ()

@end

@implementation NameController

#pragma mark - view

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameChosen = @"NO";

    self.names = [[NSMutableArray alloc] init];
    self.genders = [[NSMutableArray alloc] init];
    NSArray *parsed = [_detailItem componentsSeparatedByString:@","];
    if (parsed.count >= 2) {
        self.genderString = parsed[0];
        self.letterString = parsed[1];
    }
    if (parsed.count >= 4) {
        self.limitNumber = [parsed[3] intValue];
    }
    
    DBUser *currentUser = [DBUser currentUser];

    if (self.genderString == nil || [self.genderString length] == 0) {
        self.genderString = [currentUser objectForKey:@"gender"];
    }
    if (self.letterString == nil || [self.letterString length] == 0) {
        self.letterString = [currentUser objectForKey:@"letter"];
    }
    if (self.limitNumber == 0) {
        self.limitNumber = (int)[[currentUser objectForKey:@"limit"] integerValue];
        if (self.limitNumber == 0) self.limitNumber = 25;
    }
    self.sortString = [currentUser objectForKey:@"sort"] ?: @"popular";
    
    if ([self.genderString isEqualToString:@"M"] || [self.genderString isEqualToString:@"👦"]) {
        self.genderString = @"M";
    } else if ([self.genderString isEqualToString:@"F"] || [self.genderString isEqualToString:@"👧"]) {
        self.genderString = @"F";
    } else {
        self.genderString = @"All"; // Defaults to both
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
    
    [self layoutProgrammatically];
    
    if (self.letterString == nil || [self.letterString length] == 0 || [self.letterString isEqualToString:@"*"] || [self.letterString caseInsensitiveCompare:@"ALL"] == NSOrderedSame) {
        self.letterString = @"ALL";
        self.letterLabel.text = @"*";
    } else {
        self.letterLabel.text = self.letterString;
    }
    
    UIScreenEdgePanGestureRecognizer *left = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(leftEdge:)];
    UIScreenEdgePanGestureRecognizer *right = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(rightEdge:)];
    left.edges = UIRectEdgeLeft;
    right.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:left];
    [self.view addGestureRecognizer:right];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.names removeAllObjects];
    [self.genders removeAllObjects];
    
    NSString *genderLetter = @"All";
    if ([self.genderString isEqualToString:@"👦"] || [self.genderString isEqualToString:@"M"]) {
        genderLetter = @"M";
    } else if ([self.genderString isEqualToString:@"👧"] || [self.genderString isEqualToString:@"F"]) {
        genderLetter = @"F";
    } else {
        genderLetter = @"All";
    }
    [self.activityIndicator startAnimating];
    DBQuery *query = [DBQuery queryWithClassName:@"Name"];
    
    BOOL hasLetterFilter = (self.letterString != nil && [self.letterString length] > 0 && ![self.letterString isEqualToString:@"ALL"] && ![self.letterString isEqualToString:@"*"]);
    if (hasLetterFilter) {
        [query whereKey:@"name" matchesRegex:[NSString stringWithFormat:@"%@.*", self.letterString]];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *filtered = [NSMutableArray array];
            for (DBObject *object in objects) {
                NSString *n = [object objectForKey:@"name"];
                NSString *g = [object objectForKey:@"gender"];
                if (!n) continue;
                
                BOOL genderMatch = YES;
                if ([genderLetter isEqualToString:@"M"]) {
                    genderMatch = [g isEqualToString:@"M"];
                } else if ([genderLetter isEqualToString:@"F"]) {
                    genderMatch = [g isEqualToString:@"F"];
                }
                
                BOOL letterMatch = YES;
                if (hasLetterFilter) {
                    letterMatch = [[n lowercaseString] hasPrefix:[self.letterString lowercaseString]];
                }
                
                if (genderMatch && letterMatch) {
                    [filtered addObject:object];
                }
            }
            
            [filtered sortUsingComparator:^NSComparisonResult(DBObject *a, DBObject *b) {
                if ([self.sortString isEqualToString:@"uncommon"]) {
                    NSInteger rankA = [[a objectForKey:@"rank"] integerValue];
                    NSInteger rankB = [[b objectForKey:@"rank"] integerValue];
                    if (rankA != rankB) {
                        return rankA > rankB ? NSOrderedAscending : NSOrderedDescending;
                    }
                    return [[a objectForKey:@"name"] compare:[b objectForKey:@"name"] options:NSCaseInsensitiveSearch];
                } else if ([self.sortString isEqualToString:@"popular"]) {
                    NSInteger rankA = [[a objectForKey:@"rank"] integerValue];
                    NSInteger rankB = [[b objectForKey:@"rank"] integerValue];
                    if (rankA == 0) rankA = 999999;
                    if (rankB == 0) rankB = 999999;
                    if (rankA != rankB) {
                        return rankA < rankB ? NSOrderedAscending : NSOrderedDescending;
                    }
                    return [[a objectForKey:@"name"] compare:[b objectForKey:@"name"] options:NSCaseInsensitiveSearch];
                } else if ([self.sortString isEqualToString:@"namesZtoA"]) {
                    return [[b objectForKey:@"name"] compare:[a objectForKey:@"name"] options:NSCaseInsensitiveSearch];
                } else { // namesAtoZ
                    return [[a objectForKey:@"name"] compare:[b objectForKey:@"name"] options:NSCaseInsensitiveSearch];
                }
            }];
            
            NSInteger count = MIN((NSInteger)filtered.count, (NSInteger)self.limitNumber);
            for (NSInteger i = 0; i < count; i++) {
                DBObject *obj = filtered[i];
                [self.names addObject:[obj objectForKey:@"name"]];
                [self.genders addObject:[obj objectForKey:@"gender"]];
            }
        }
        [self.namesTable reloadData];
        [self setRandomName];
        [self.activityIndicator stopAnimating];
        if (self.names.count > 0 && self.index < self.names.count) {
            [self.namesTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            [self setNameToUser];
        } else {
            self.name.text = @"No names found";
            self.index = 0; // Reset index if no names found to prevent crashes
        }
    }];
}

#pragma mark - set name to user

- (void) setNameToUser {
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:self.names[self.index] forKey:@"name"];
    [currentUser saveInBackground];
}

#pragma mark - shake

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self setRandomName];
        [self.namesTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        [self setNameToUser];
    }
}

#pragma mark - random

- (void)setRandomName {
    if ([self.names count] == 0) {
        [self.name setText:@"No names found"];
        return;
    }
    int lo = 0;
    int hi = (int)[self.names count];
    self.index = lo + arc4random() % (hi - lo);
    [self.name setText:self.names[self.index]];
}

#pragma mark - helper

-(UITableViewCell *)parentCellForView:(id)theView
{
    id viewSuperView = [theView superview];
    while (viewSuperView != nil) {
        if ([viewSuperView isKindOfClass:[UITableViewCell class]]) {
            return (UITableViewCell *)viewSuperView;
        }
        else {
            viewSuperView = [viewSuperView superview];
        }
    }
    return nil;
}

#pragma mark - detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
}

#pragma mark - buttons

- (IBAction)random:(id)sender {
    [self setRandomName];
    [self.namesTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self setNameToUser];
}

-(IBAction)save:(UIButton*)sender {
    self.nameChosen = @"NO";
    UIButton *button = (UIButton *)sender;
    UITableViewCell *cell = [self parentCellForView:button];
    NSString * genderLetter;
    if ([self.genderString isEqual:@"👦"]||[self.genderString isEqual:@"M"]) {
        genderLetter =@"M";
    } if ([self.genderString isEqual:@"👧"]||[self.genderString isEqual:@"F"]) {
        genderLetter =@"F";
    } if ([self.genderString isEqual:@"👶"]||[self.genderString isEqual:@"All"]) {
        genderLetter =@"All";
    }
    
    if (cell != nil) {
        NSIndexPath *indexPath = [self.namesTable indexPathForCell:cell];
        
        // save name
        // https://parse.com/docs/ios_guide#objects-saving/iOS
        
        DBUser *currentUser = [DBUser currentUser];
        DBQuery *query = [DBQuery queryWithClassName:@"names"];
        [query whereKey:@"name" equalTo:self.names[indexPath.row]];
        [query whereKey:@"userId" equalTo:[currentUser objectId]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count>0){
                self.nameChosen = @"YES";
            } else {
                self.nameChosen = @"NO";
            }
            if ([self.nameChosen isEqualToString:@"NO"]) {
                DBObject *object = [DBObject objectWithClassName:@"names"];
                object[@"name"] = self.names[indexPath.row];
                object[@"gender"] = genderLetter;
                object[@"userId"] = [currentUser objectId];
                [object saveInBackground];
                
                self.name.text = self.names[indexPath.row];
                
                [self.namesTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                [self setNameToUser];
                
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
}

#pragma mark - edge pan gesture

- (void)leftEdge: (UIScreenEdgePanGestureRecognizer*)edgeRecognizer{
    [self lastPage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightEdge: (UIScreenEdgePanGestureRecognizer*)edgeRecognizer{
    [self lastPage];
    [self performSegueWithIdentifier:@"info" sender:edgeRecognizer];
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [segue.destinationViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self lastPage];
    NSString *genderLetter;
    if ([self.genderString isEqual:@"👦"]) {
        genderLetter =@"M";
    } if ([self.genderString isEqual:@"👧"]) {
        genderLetter =@"F";
    } if ([self.genderString isEqual:@"👶"]) {
        genderLetter =@"All";
    }
    NSString *name;
    if ([[segue identifier] isEqualToString:@"info"]||[[segue identifier] isEqualToString:@"home"]) {
        NSIndexPath *indexPath = [self.namesTable indexPathForSelectedRow];
        if (indexPath && indexPath.row < self.names.count) {
            name = self.names[indexPath.row];
        } else {
            name = @"None";
        }
        NSString *string = [NSString stringWithFormat:@"%@,%@,%@,%i", genderLetter, self.letterString, name, self.limitNumber];
        [[segue destinationViewController] setDetailItem:string];
    }
}

#pragma mark - table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.names count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"name"];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    }
    cell.textLabel.text = [self.names objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor labelColor];
    if (indexPath.row < self.genders.count) {
        if ([[self.genders objectAtIndex:indexPath.row] isEqual:@"F"]) {
            cell.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull tc) {
                return tc.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor colorWithRed:0.37 green:0.12 blue:0.24 alpha:1.0] : [UIColor colorWithRed:1 green:.8 blue:.85 alpha:1];
            }];
            cell.selectedBackgroundView = [UIView new];
            cell.selectedBackgroundView.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull tc) {
                return tc.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor colorWithRed:0.5 green:0.15 blue:0.3 alpha:1.0] : [UIColor colorWithRed:.8 green:.6 blue:.65 alpha:1];
            }];
        } else {
            cell.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull tc) {
                return tc.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor colorWithRed:0.12 green:0.21 blue:0.37 alpha:1.0] : [UIColor colorWithRed:.8 green:.85 blue:1 alpha:1];
            }];
            cell.selectedBackgroundView = [UIView new];
            cell.selectedBackgroundView.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull tc) {
                return tc.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor colorWithRed:0.18 green:0.3 blue:0.5 alpha:1.0] : [UIColor colorWithRed:.6 green:.65 blue:0.8 alpha:1];
            }];
        }
    }
    for (UIView *v in cell.contentView.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *sBtn = (UIButton *)v;
            [sBtn setImage:[UIImage imageNamed:@"tool_save"] forState:UIControlStateNormal];
            [sBtn setTitle:@"" forState:UIControlStateNormal];
            sBtn.tintColor = [UIColor labelColor];
            sBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.name.text = self.names[indexPath.row];
    [self.namesTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self setNameToUser];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {        
        [self.names removeObjectAtIndex:indexPath.row];
        if (indexPath.row < self.genders.count) {
            [self.genders removeObjectAtIndex:indexPath.row];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
    [self.namesTable reloadData];
    
    [self layoutProgrammatically];
}

- (void)layoutProgrammatically {
    [self.view removeConstraints:self.view.constraints];
    [self.name removeConstraints:self.name.constraints];
    [self.namesTable removeConstraints:self.namesTable.constraints];
    
    self.name.translatesAutoresizingMaskIntoConstraints = NO;
    self.name.textColor = [UIColor labelColor];
    self.namesTable.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.genderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.letterLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (!self.genderImageView) {
        self.genderImageView = [[UIImageView alloc] init];
        self.genderImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.genderImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.genderImageView];
    }
    
    // Find buttons
    UIButton *cancelBtn = nil, *saveBtn = nil, *homeBtn = nil, *shuffleBtn = nil;
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)v;
            btn.translatesAutoresizingMaskIntoConstraints = NO;
            NSString *title = [btn titleForState:UIControlStateNormal];
            if ([title isEqualToString:@"✖️"]) cancelBtn = btn;
            else if ([title isEqualToString:@"❤️"]) saveBtn = btn;
            else if (btn.frame.origin.y < 100) {
                if (btn.frame.origin.x < 150) homeBtn = btn;
                else shuffleBtn = btn;
            }
        }
    }
    
    [NSLayoutConstraint activateConstraints:@[
        [self.name.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.name.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:70],
        [self.name.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-40],
        
        [self.namesTable.topAnchor constraintEqualToAnchor:self.name.bottomAnchor constant:20],
        [self.namesTable.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.namesTable.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        
        [self.letterLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
        [self.letterLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:30],
        
        [self.genderImageView.centerYAnchor constraintEqualToAnchor:self.letterLabel.centerYAnchor],
        [self.genderImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-30],
        [self.genderImageView.widthAnchor constraintEqualToConstant:36],
        [self.genderImageView.heightAnchor constraintEqualToConstant:36]
    ]];
    
    if (homeBtn) {
        [homeBtn setImage:[UIImage imageNamed:@"tool_back"] forState:UIControlStateNormal];
        [homeBtn setTitle:@"" forState:UIControlStateNormal];
        homeBtn.tintColor = [UIColor labelColor];
        homeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    if (shuffleBtn) {
        [shuffleBtn setImage:[UIImage imageNamed:@"tool_shuffle"] forState:UIControlStateNormal];
        [shuffleBtn setTitle:@"" forState:UIControlStateNormal];
        shuffleBtn.tintColor = [UIColor labelColor];
        shuffleBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    if (homeBtn && shuffleBtn) {
        [NSLayoutConstraint activateConstraints:@[
            [homeBtn.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
            [homeBtn.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:20],
            [homeBtn.widthAnchor constraintEqualToConstant:44],
            [homeBtn.heightAnchor constraintEqualToConstant:44],
            
            [shuffleBtn.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
            [shuffleBtn.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-20],
            [shuffleBtn.widthAnchor constraintEqualToConstant:44],
            [shuffleBtn.heightAnchor constraintEqualToConstant:44]
        ]];
    }

    if (cancelBtn && saveBtn) {
        [NSLayoutConstraint activateConstraints:@[
            [cancelBtn.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-40],
            [cancelBtn.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:60],
            
            [saveBtn.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-40],
            [saveBtn.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-60],
            
            [self.namesTable.bottomAnchor constraintEqualToAnchor:cancelBtn.topAnchor constant:-20]
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [self.namesTable.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
        ]];
    }
    

}

- (void)lastPage {
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:@"NewNames" forKey:@"lastPage"];
    [currentUser saveInBackground];
}

@end
