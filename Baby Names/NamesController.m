
#import "NamesController.h"

@interface NamesController ()

@end

@implementation NamesController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.names = [[NSMutableArray alloc] init];
    self.genders = [[NSMutableArray alloc] init];
    
    [self layoutProgrammatically];
}

- (void)layoutProgrammatically {
    [self.view removeConstraints:self.view.constraints];
    [self.name removeConstraints:self.name.constraints];
    [self.namesTable removeConstraints:self.namesTable.constraints];
    
    self.name.translatesAutoresizingMaskIntoConstraints = NO;
    self.name.textColor = [UIColor labelColor];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Find all buttons
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
    
    self.namesTable.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.name.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.name.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:40],
        [self.name.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-40],
        
        [self.namesTable.topAnchor constraintEqualToAnchor:self.name.bottomAnchor constant:20],
        [self.namesTable.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.namesTable.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
    
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

- (void)viewWillAppear:(BOOL)animated {
    [self getNameListWithGender:nil];
}

- (void)getNameListWithGender:(NSString*) gender {
    DBUser *currentUser = [DBUser currentUser];
    
    [self.activityIndicator startAnimating];
    
    [self.names removeAllObjects];
    [self.genders removeAllObjects];
    
    if (gender != nil) {
        if ([gender isEqualToString:@"F"]) {
            [self.names addObject:@"👧"];
            [self.genders addObject:@"F"];
        } else {
            [self.names addObject:@"👦"];
            [self.genders addObject:@"M"];
        }
    } else {
        [self.names addObject:@"👶"];
        [self.genders addObject:@"All"];
    }    
    
    DBQuery *query = [DBQuery queryWithClassName:@"names"];
    [query whereKey:@"userId" equalTo:[currentUser objectId]];
    
    NSString *letterString = [currentUser objectForKey:@"letter"] ?: @"ALL";
    NSString *sortString = [currentUser objectForKey:@"sort"] ?: @"namesAtoZ";
    NSString *genderString = [currentUser objectForKey:@"gender"] ?: @"All";
    int limitNumber = (int)[[currentUser objectForKey:@"limit"] integerValue];
    if (limitNumber == 0) limitNumber = 25;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *filtered = [NSMutableArray array];
            for (DBObject *object in objects) {
                NSString *objGender = [object objectForKey:@"gender"];
                NSString *objName = [object objectForKey:@"name"];
                if (!objName) continue;
                
                NSString *effectiveGender = (gender != nil) ? gender : genderString;
                BOOL isM = [effectiveGender isEqualToString:@"M"] || [effectiveGender isEqualToString:@"👦"];
                BOOL isF = [effectiveGender isEqualToString:@"F"] || [effectiveGender isEqualToString:@"👧"];
                BOOL genderMatch = (!isM && !isF) || (isM && [objGender isEqualToString:@"M"]) || (isF && [objGender isEqualToString:@"F"]);
                
                BOOL letterMatch = YES;
                if (letterString != nil && [letterString length] > 0 && ![letterString isEqualToString:@"ALL"] && ![letterString isEqualToString:@"*"]) {
                    letterMatch = [[objName lowercaseString] hasPrefix:[letterString lowercaseString]];
                }
                
                if (genderMatch && letterMatch) {
                    [filtered addObject:object];
                }
            }
            
            [filtered sortUsingComparator:^NSComparisonResult(DBObject *a, DBObject *b) {
                if ([sortString isEqualToString:@"oldest"]) {
                    id da = [a objectForKey:@"createdAt"];
                    id db = [b objectForKey:@"createdAt"];
                    if ([da respondsToSelector:@selector(compare:)] && [db respondsToSelector:@selector(compare:)]) {
                        return [da compare:db];
                    }
                    return NSOrderedSame;
                } else if ([sortString isEqualToString:@"newest"]) {
                    id da = [a objectForKey:@"createdAt"];
                    id db = [b objectForKey:@"createdAt"];
                    if ([da respondsToSelector:@selector(compare:)] && [db respondsToSelector:@selector(compare:)]) {
                        return [db compare:da];
                    }
                    return NSOrderedSame;
                } else if ([sortString isEqualToString:@"namesZtoA"]) {
                    return [[b objectForKey:@"name"] caseInsensitiveCompare:[a objectForKey:@"name"]];
                } else {
                    return [[a objectForKey:@"name"] caseInsensitiveCompare:[b objectForKey:@"name"]];
                }
            }];
            
            int limit = MIN(limitNumber, (int)filtered.count);
            for (int i = 0; i < limit; i++) {
                NSString *name = [[filtered objectAtIndex:i] objectForKey:@"name"];
                NSString *gender = [[filtered objectAtIndex:i] objectForKey:@"gender"];
                [self.names addObject:name ?: @"Unknown"];
                [self.genders addObject:gender ?: @"M"];
            }
        } else {
        }
        
        if (self.names.count > 0) {
            [self.names removeObjectAtIndex:0];
            [self.genders removeObjectAtIndex:0];
        }
        
        [self.namesTable reloadData];
        [self.activityIndicator stopAnimating];
        [self random:nil];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setRandomName];
    if (self.names.count > 0) {
        [self.namesTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
    
    UIScreenEdgePanGestureRecognizer *left = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(leftEdge:)];
    UIScreenEdgePanGestureRecognizer *right = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(rightEdge:)];
    left.edges = UIRectEdgeLeft;
    right.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:left];
    [self.view addGestureRecognizer:right];
}

#pragma mark - random

- (void)setRandomName {
    if ([self.names count] == 0) {
        [self.name setText:@"No names found"];
        return;
    }
    int lo = 0;
    int hi = (int)[self.names count];
    if (hi > 200) {hi=200;}
    self.index = lo + arc4random() % (hi - lo);
    [self.name setText:self.names[self.index]];
}

#pragma mark - shake

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self setRandomName];
        if (self.names.count > 0) {
            [self.namesTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
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

#pragma mark - buttons

- (IBAction)random:(id)sender {
    [self setRandomName];
    if (self.names.count > 0) {
        [self.namesTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
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
    
    NSString *genderEmoji;
    if ([[self.genders objectAtIndex:indexPath.row]  isEqual: @"F"]) {
        genderEmoji = @"👧";
        cell.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull tc) {
            return tc.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor colorWithRed:0.37 green:0.12 blue:0.24 alpha:1.0] : [UIColor colorWithRed:1 green:.8 blue:.85 alpha:1];
        }];
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull tc) {
            return tc.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor colorWithRed:0.5 green:0.15 blue:0.3 alpha:1.0] : [UIColor colorWithRed:.8 green:.6 blue:.65 alpha:1];
        }];
    } else {
        genderEmoji = @"👦";
        cell.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull tc) {
            return tc.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor colorWithRed:0.12 green:0.21 blue:0.37 alpha:1.0] : [UIColor colorWithRed:.8 green:.85 blue:1 alpha:1];
        }];
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull tc) {
            return tc.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor colorWithRed:0.18 green:0.3 blue:0.5 alpha:1.0] : [UIColor colorWithRed:.6 green:.65 blue:0.8 alpha:1];
        }];
    }
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:0];
    label.textColor = [UIColor labelColor];
    label.text = [self.names objectAtIndex:indexPath.row];
    label = (UILabel *)[cell viewWithTag:1];
    label.text = @"";
    NSString *imageName = [genderEmoji isEqualToString:@"👧"] ? @"face_girl" : @"face_boy";
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.namesTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // delete from database
        // https://parse.com/docs/ios_guide#objects-deleting/iOS
        
        DBQuery *query = [DBQuery queryWithClassName:@"names"];
        [query whereKey:@"name" containsString:self.names[indexPath.row]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (DBObject *object in objects) {
                    [object deleteInBackground];
                }
            } else {
            }
        }];
        
        [self.names removeObjectAtIndex:indexPath.row];
        [self.genders removeObjectAtIndex:indexPath.row];
        [self.namesTable reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
    [self.namesTable reloadData];
}

#pragma mark - detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [segue.destinationViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self lastPage];
    self.genderLetter = @"M";
    NSIndexPath *indexPath = [self.namesTable indexPathForSelectedRow];
    self.genderLetter = [self.genders objectAtIndex:indexPath.row];
    
    NSString *fullString = self.names[indexPath.row];
    NSString *prefix = nil;
    
    if ([fullString length] >= 1)
        prefix = [fullString substringToIndex:1];
    else
        prefix = fullString;
    
    if ([[segue identifier] isEqualToString:@"info"]||[[segue identifier] isEqualToString:@"home"]) {
        NSString *string = [NSString stringWithFormat:@"%@,%@,%@,%i", self.genderLetter, prefix, self.names[indexPath.row], 5];
        [[segue destinationViewController] setDetailItem:string];
    }
}

- (void)lastPage {
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:@"MyNames" forKey:@"lastPage"];
    [currentUser saveInBackground];
}

@end
