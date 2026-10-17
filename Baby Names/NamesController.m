
#import "NamesController.h"

@interface NamesController ()
@property (nonatomic, strong) NSArray<DBObject *> *rawFavorites;
@property (nonatomic, strong) id favoritesListener;
@end

@implementation NamesController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.names = [[NSMutableArray alloc] init];
    self.genders = [[NSMutableArray alloc] init];
    self.rawFavorites = @[];
    self.name.text = @"";
    
    self.boyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.boyButton setImage:[UIImage imageNamed:@"face_boy"] forState:UIControlStateNormal];
    [self.boyButton addTarget:self action:@selector(filterBoy:) forControlEvents:UIControlEventTouchUpInside];
    self.boyButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.boyButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.bothButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bothButton setImage:[UIImage imageNamed:@"face_baby"] forState:UIControlStateNormal];
    [self.bothButton addTarget:self action:@selector(filterBoth:) forControlEvents:UIControlEventTouchUpInside];
    self.bothButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.bothButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.girlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.girlButton setImage:[UIImage imageNamed:@"face_girl"] forState:UIControlStateNormal];
    [self.girlButton addTarget:self action:@selector(filterGirl:) forControlEvents:UIControlEventTouchUpInside];
    self.girlButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.girlButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.genderStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.boyButton, self.bothButton, self.girlButton]];
    self.genderStackView.axis = UILayoutConstraintAxisHorizontal;
    self.genderStackView.distribution = UIStackViewDistributionEqualSpacing;
    self.genderStackView.alignment = UIStackViewAlignmentCenter;
    self.genderStackView.spacing = 28;
    self.genderStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.genderStackView];
    
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
    UIButton *homeBtn = nil, *shuffleBtn = nil;
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)v;
            if (btn == self.boyButton || btn == self.bothButton || btn == self.girlButton) continue;
            btn.translatesAutoresizingMaskIntoConstraints = NO;
            if ([[btn actionsForTarget:self forControlEvent:UIControlEventTouchDown] containsObject:@"random:"]) {
                shuffleBtn = btn;
            } else if ([btn.currentImage isEqual:[UIImage imageNamed:@"tool_shuffle"]] || btn.frame.origin.x > 300) {
                shuffleBtn = btn;
            } else if ([btn.currentImage isEqual:[UIImage imageNamed:@"tool_back"]] || btn.frame.origin.x < 150) {
                homeBtn = btn;
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
    self.namesTable.backgroundColor = [UIColor clearColor];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.name.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.name.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [self.name.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:64],
        [self.name.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-64],
        
        [self.genderStackView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.genderStackView.topAnchor constraintEqualToAnchor:self.name.bottomAnchor constant:10],
        
        [self.boyButton.widthAnchor constraintEqualToConstant:44],
        [self.boyButton.heightAnchor constraintEqualToConstant:44],
        [self.bothButton.widthAnchor constraintEqualToConstant:44],
        [self.bothButton.heightAnchor constraintEqualToConstant:44],
        [self.girlButton.widthAnchor constraintEqualToConstant:44],
        [self.girlButton.heightAnchor constraintEqualToConstant:44],
        
        [self.namesTable.topAnchor constraintEqualToAnchor:self.genderStackView.bottomAnchor constant:14],
        [self.namesTable.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.namesTable.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.namesTable.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
}

- (UIColor *)boyBackgroundColor {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull tc) {
        return tc.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor colorWithRed:0.12 green:0.21 blue:0.37 alpha:1.0] : [UIColor colorWithRed:.8 green:.85 blue:1 alpha:1];
    }];
}

- (UIColor *)girlBackgroundColor {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull tc) {
        return tc.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor colorWithRed:0.37 green:0.12 blue:0.24 alpha:1.0] : [UIColor colorWithRed:1 green:.8 blue:.85 alpha:1];
    }];
}

- (UIColor *)allBackgroundColor {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull tc) {
        return tc.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor colorWithRed:0.12 green:0.12 blue:0.12 alpha:1.0] : [UIColor whiteColor];
    }];
}

- (void)updateGenderVisualState {
    if ([self.genderString isEqualToString:@"M"] || [self.genderString isEqualToString:@"👦"]) {
        self.genderString = @"M";
        self.boyButton.alpha = 1.0;
        self.bothButton.alpha = 0.35;
        self.girlButton.alpha = 0.35;
        self.view.backgroundColor = [self boyBackgroundColor];
    } else if ([self.genderString isEqualToString:@"F"] || [self.genderString isEqualToString:@"👧"]) {
        self.genderString = @"F";
        self.boyButton.alpha = 0.35;
        self.bothButton.alpha = 0.35;
        self.girlButton.alpha = 1.0;
        self.view.backgroundColor = [self girlBackgroundColor];
    } else {
        self.genderString = @"All";
        self.boyButton.alpha = 0.35;
        self.bothButton.alpha = 1.0;
        self.girlButton.alpha = 0.35;
        self.view.backgroundColor = [self allBackgroundColor];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DBUser *currentUser = [DBUser currentUser];
    NSString *userGender = [currentUser objectForKey:@"gender"];
    if (self.genderString == nil) {
        if ([userGender isEqualToString:@"M"] || [userGender isEqualToString:@"👦"]) {
            self.genderString = @"M";
        } else if ([userGender isEqualToString:@"F"] || [userGender isEqualToString:@"👧"]) {
            self.genderString = @"F";
        } else {
            self.genderString = @"All";
        }
    }
    [self updateGenderVisualState];
    [self startFavoritesListener];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.favoritesListener) {
        DBQuery *q = [DBQuery queryWithClassName:@"names"];
        [q removeListener:self.favoritesListener];
        self.favoritesListener = nil;
    }
}

- (void)dealloc {
    if (self.favoritesListener) {
        DBQuery *q = [DBQuery queryWithClassName:@"names"];
        [q removeListener:self.favoritesListener];
        self.favoritesListener = nil;
    }
}

- (void)startFavoritesListener {
    DBUser *currentUser = [DBUser currentUser];
    if (![currentUser objectId]) return;
    
    if (self.favoritesListener) {
        DBQuery *q = [DBQuery queryWithClassName:@"names"];
        [q removeListener:self.favoritesListener];
        self.favoritesListener = nil;
    }
    
    [self.activityIndicator startAnimating];
    DBQuery *query = [DBQuery queryWithClassName:@"names"];
    [query whereKey:@"userId" equalTo:[currentUser objectId]];
    
    __weak typeof(self) weakSelf = self;
    self.favoritesListener = [query addSnapshotListenerWithBlock:^(NSArray *objects, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [strongSelf.activityIndicator stopAnimating];
        if (!error && objects) {
            strongSelf.rawFavorites = objects;
        } else {
            strongSelf.rawFavorites = @[];
        }
        [strongSelf applyFilterAndReload];
    }];
}

- (void)applyFilterAndReload {
    DBUser *currentUser = [DBUser currentUser];
    NSString *letterString = [currentUser objectForKey:@"letter"] ?: @"ALL";
    NSString *sortString = [currentUser objectForKey:@"sort"] ?: @"namesAtoZ";
    int limitNumber = (int)[[currentUser objectForKey:@"limit"] integerValue];
    if (limitNumber == 0) limitNumber = 25;
    
    [self.names removeAllObjects];
    [self.genders removeAllObjects];
    
    NSMutableArray *filtered = [NSMutableArray array];
    BOOL isM = [self.genderString isEqualToString:@"M"];
    BOOL isF = [self.genderString isEqualToString:@"F"];
    BOOL hasLetter = (letterString != nil && [letterString length] > 0 && ![letterString isEqualToString:@"ALL"] && ![letterString isEqualToString:@"*"]);
    
    for (DBObject *object in self.rawFavorites) {
        NSString *objGender = [object objectForKey:@"gender"];
        NSString *objName = [object objectForKey:@"name"];
        if (!objName) continue;
        
        BOOL genderMatch = (!isM && !isF) || (isM && [objGender isEqualToString:@"M"]) || (isF && [objGender isEqualToString:@"F"]);
        BOOL letterMatch = YES;
        if (hasLetter) {
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
        } else if ([sortString isEqualToString:@"uncommon"]) {
            NSInteger rankA = [[a objectForKey:@"rank"] integerValue];
            NSInteger rankB = [[b objectForKey:@"rank"] integerValue];
            if (rankA != rankB) {
                return rankA > rankB ? NSOrderedAscending : NSOrderedDescending;
            }
            return [[a objectForKey:@"name"] caseInsensitiveCompare:[b objectForKey:@"name"]];
        } else if ([sortString isEqualToString:@"popular"]) {
            NSInteger rankA = [[a objectForKey:@"rank"] integerValue];
            NSInteger rankB = [[b objectForKey:@"rank"] integerValue];
            if (rankA == 0) rankA = 999999;
            if (rankB == 0) rankB = 999999;
            if (rankA != rankB) {
                return rankA < rankB ? NSOrderedAscending : NSOrderedDescending;
            }
            return [[a objectForKey:@"name"] caseInsensitiveCompare:[b objectForKey:@"name"]];
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
    
    [self.namesTable reloadData];
    
    if (self.names.count > 0) {
        [self setRandomName];
        [self.namesTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        if ([self.genderString isEqualToString:@"M"]) {
            self.name.text = @"No boy favorites yet";
        } else if ([self.genderString isEqualToString:@"F"]) {
            self.name.text = @"No girl favorites yet";
        } else {
            self.name.text = @"No favorites saved yet";
        }
    }
}

- (IBAction)filterBoy:(id)sender {
    if (![self.genderString isEqualToString:@"M"]) {
        self.genderString = @"M";
        [self updateGenderVisualState];
        DBUser *currentUser = [DBUser currentUser];
        [currentUser setObject:@"M" forKey:@"gender"];
        [currentUser saveInBackground];
        [self applyFilterAndReload];
    }
}

- (IBAction)filterBoth:(id)sender {
    if (![self.genderString isEqualToString:@"All"]) {
        self.genderString = @"All";
        [self updateGenderVisualState];
        DBUser *currentUser = [DBUser currentUser];
        [currentUser setObject:@"All" forKey:@"gender"];
        [currentUser saveInBackground];
        [self applyFilterAndReload];
    }
}

- (IBAction)filterGirl:(id)sender {
    if (![self.genderString isEqualToString:@"F"]) {
        self.genderString = @"F";
        [self updateGenderVisualState];
        DBUser *currentUser = [DBUser currentUser];
        [currentUser setObject:@"F" forKey:@"gender"];
        [currentUser saveInBackground];
        [self applyFilterAndReload];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
        if ([self.genderString isEqualToString:@"M"]) {
            [self.name setText:@"No boy favorites yet"];
        } else if ([self.genderString isEqualToString:@"F"]) {
            [self.name setText:@"No girl favorites yet"];
        } else {
            [self.name setText:@"No favorites saved yet"];
        }
        return;
    }
    int lo = 0;
    int hi = (int)[self.names count];
    if (hi > 200) { hi = 200; }
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"name"];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"name"];
    }
    
    NSString *genderEmoji;
    if ([[self.genders objectAtIndex:indexPath.row] isEqual:@"F"]) {
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
    
    UILabel *label = (UILabel *)[cell viewWithTag:0];
    if (label) {
        label.textColor = [UIColor labelColor];
        label.text = [self.names objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.textColor = [UIColor labelColor];
        cell.textLabel.text = [self.names objectAtIndex:indexPath.row];
    }
    
    UILabel *detailLabel = (UILabel *)[cell viewWithTag:1];
    if (detailLabel) {
        detailLabel.text = @"";
    }
    
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
        DBUser *currentUser = [DBUser currentUser];
        NSString *nameToDelete = self.names[indexPath.row];
        
        DBQuery *query = [DBQuery queryWithClassName:@"names"];
        [query whereKey:@"name" equalTo:nameToDelete];
        [query whereKey:@"userId" equalTo:[currentUser objectId]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error && objects) {
                for (DBObject *object in objects) {
                    [object deleteInBackground];
                }
            }
        }];
        
        [self.names removeObjectAtIndex:indexPath.row];
        [self.genders removeObjectAtIndex:indexPath.row];
        [self.namesTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (self.names.count == 0) {
            [self applyFilterAndReload];
        }
    }
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
    if (indexPath && indexPath.row < self.genders.count) {
        self.genderLetter = [self.genders objectAtIndex:indexPath.row];
    }
    
    NSString *fullString = (indexPath && indexPath.row < self.names.count) ? self.names[indexPath.row] : @"";
    NSString *prefix = nil;
    
    if ([fullString length] >= 1)
        prefix = [fullString substringToIndex:1];
    else
        prefix = fullString;
    
    if ([[segue identifier] isEqualToString:@"info"] || [[segue identifier] isEqualToString:@"home"]) {
        NSString *string = [NSString stringWithFormat:@"%@,%@,%@,%i", self.genderLetter, prefix, fullString, 5];
        [[segue destinationViewController] setDetailItem:string];
    }
}

- (void)lastPage {
    DBUser *currentUser = [DBUser currentUser];
    [currentUser setObject:@"MyNames" forKey:@"lastPage"];
    [currentUser saveInBackground];
}

@end
