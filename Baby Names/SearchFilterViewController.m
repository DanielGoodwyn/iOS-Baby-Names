#import "SearchFilterViewController.h"
#import "NamesDatabase.h"
#import "Database.h"
#import "InfoController.h"

@interface SearchFilterViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISegmentedControl *limitControl;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *emptyStateLabel;

@property (nonatomic, strong) NSArray<NSDictionary *> *searchResults;
@property (nonatomic, strong) NSMutableSet<NSString *> *favoriteNames;
@property (nonatomic, strong) UIImpactFeedbackGenerator *feedbackGenerator;

@end

@implementation SearchFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"Search & Filter";
    self.favoriteNames = [NSMutableSet set];
    self.searchResults = @[];
    self.feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    
    [self setupNavigation];
    [self setupViews];
    [self loadFavorites];
}

- (void)setupNavigation {
    UINavigationBar *navBar = [[UINavigationBar alloc] init];
    navBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Search & Filter"];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self
                                                                             action:@selector(doneTapped)];
    item.rightBarButtonItem = doneBtn;
    [navBar setItems:@[item]];
    [self.view addSubview:navBar];
    
    [NSLayoutConstraint activateConstraints:@[
        [navBar.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [navBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [navBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];
}

- (void)setupViews {
    UIView *topContainer = [[UIView alloc] init];
    topContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topContainer];
    
    UILabel *limitLabel = [[UILabel alloc] init];
    limitLabel.text = @"EXPLORE LIMIT";
    limitLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    limitLabel.textColor = [UIColor secondaryLabelColor];
    limitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [topContainer addSubview:limitLabel];
    
    self.limitControl = [[UISegmentedControl alloc] initWithItems:@[@"25", @"50", @"100", @"All"]];
    self.limitControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self updateLimitSelection];
    [self.limitControl addTarget:self action:@selector(limitChanged:) forControlEvents:UIControlEventValueChanged];
    [topContainer addSubview:self.limitControl];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = @"Search SSA 2023 names (e.g. Liam, Emma)...";
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.delegate = self;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    [topContainer addSubview:self.searchBar];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    
    self.emptyStateLabel = [[UILabel alloc] init];
    self.emptyStateLabel.numberOfLines = 0;
    self.emptyStateLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyStateLabel.textColor = [UIColor secondaryLabelColor];
    self.emptyStateLabel.font = [UIFont systemFontOfSize:15];
    self.emptyStateLabel.text = @"Type a name above to search 31,830 official SSA names.\n\nSave any name directly to your Favorites.";
    self.tableView.backgroundView = self.emptyStateLabel;
    
    UINavigationBar *navBar = nil;
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[UINavigationBar class]]) {
            navBar = (UINavigationBar *)v;
            break;
        }
    }
    
    [NSLayoutConstraint activateConstraints:@[
        [topContainer.topAnchor constraintEqualToAnchor:navBar ? navBar.bottomAnchor : self.view.safeAreaLayoutGuide.topAnchor constant:8],
        [topContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [topContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        
        [limitLabel.topAnchor constraintEqualToAnchor:topContainer.topAnchor constant:4],
        [limitLabel.leadingAnchor constraintEqualToAnchor:topContainer.leadingAnchor constant:4],
        
        [self.limitControl.topAnchor constraintEqualToAnchor:limitLabel.bottomAnchor constant:6],
        [self.limitControl.leadingAnchor constraintEqualToAnchor:topContainer.leadingAnchor],
        [self.limitControl.trailingAnchor constraintEqualToAnchor:topContainer.trailingAnchor],
        [self.limitControl.heightAnchor constraintEqualToConstant:32],
        
        [self.searchBar.topAnchor constraintEqualToAnchor:self.limitControl.bottomAnchor constant:8],
        [self.searchBar.leadingAnchor constraintEqualToAnchor:topContainer.leadingAnchor constant:-8],
        [self.searchBar.trailingAnchor constraintEqualToAnchor:topContainer.trailingAnchor constant:8],
        [self.searchBar.bottomAnchor constraintEqualToAnchor:topContainer.bottomAnchor constant:-4],
        
        [self.tableView.topAnchor constraintEqualToAnchor:topContainer.bottomAnchor constant:4],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)updateLimitSelection {
    if (self.currentLimit <= 25) {
        self.limitControl.selectedSegmentIndex = 0;
    } else if (self.currentLimit <= 50) {
        self.limitControl.selectedSegmentIndex = 1;
    } else if (self.currentLimit <= 100) {
        self.limitControl.selectedSegmentIndex = 2;
    } else {
        self.limitControl.selectedSegmentIndex = 3;
    }
}

- (void)limitChanged:(UISegmentedControl *)sender {
    NSInteger newLimit = 25;
    switch (sender.selectedSegmentIndex) {
        case 0: newLimit = 25; break;
        case 1: newLimit = 50; break;
        case 2: newLimit = 100; break;
        case 3: newLimit = 10000; break;
        default: newLimit = 25; break;
    }
    self.currentLimit = newLimit;
    
    DBUser *currentUser = [DBUser currentUser];
    if (currentUser) {
        [currentUser setObject:@(newLimit) forKey:@"limit"];
        [currentUser saveInBackground];
    }
    
    if ([self.delegate respondsToSelector:@selector(searchFilterDidUpdateLimit:)]) {
        [self.delegate searchFilterDidUpdateLimit:newLimit];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BabyNamesLimitDidChangeNotification"
                                                        object:@(newLimit)];
}

- (void)loadFavorites {
    DBUser *currentUser = [DBUser currentUser];
    if (currentUser) {
        NSString *userId = [currentUser objectForKey:@"userId"] ?: currentUser.objectId;
        if (!userId) return;
        
        DBQuery *query = [DBQuery queryWithClassName:@"names"];
        [query whereKey:@"userId" equalTo:userId];
        [query setLimit:1000];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error && objects) {
                for (DBObject *obj in objects) {
                    NSString *n = [obj objectForKey:@"name"];
                    if (n) [self.favoriteNames addObject:n];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }];
    } else {
        NSArray *saved = [[NSUserDefaults standardUserDefaults] arrayForKey:@"guest_favorite_names"];
        if (saved) {
            [self.favoriteNames addObjectsFromArray:saved];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }
}

- (void)doneTapped {
    [self.searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *trimmed = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmed.length == 0) {
        self.searchResults = @[];
        self.emptyStateLabel.text = @"Type a name above to search 31,830 official SSA names.\n\nSave any name directly to your Favorites.";
        self.tableView.backgroundView = self.emptyStateLabel;
    } else {
        self.searchResults = [[NamesDatabase sharedDatabase] searchNamesWithQuery:trimmed limit:60];
        if (self.searchResults.count == 0) {
            self.emptyStateLabel.text = [NSString stringWithFormat:@"No matching names for \"%@\" in official 2023 SSA release.\n\nCustom names cannot be added.", trimmed];
            self.tableView.backgroundView = self.emptyStateLabel;
        } else {
            self.tableView.backgroundView = nil;
        }
    }
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - UITableViewDataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellId = @"SearchResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellId];
        
        UIButton *starBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        starBtn.frame = CGRectMake(0, 0, 44, 44);
        [starBtn addTarget:self action:@selector(starTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = starBtn;
    }
    
    NSDictionary *item = self.searchResults[indexPath.row];
    NSString *name = item[@"name"] ?: @"";
    NSString *gender = item[@"gender"] ?: @"";
    NSInteger rank = [item[@"rank"] integerValue];
    NSInteger count = [item[@"count"] integerValue];
    
    cell.textLabel.text = name;
    cell.textLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    
    BOOL isBoy = [gender isEqualToString:@"M"];
    NSString *genderStr = isBoy ? @"Boy" : @"Girl";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  •  #%ld (%,ld babies)", genderStr, (long)rank, (long)count];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    
    UIButton *starBtn = (UIButton *)cell.accessoryView;
    starBtn.tag = indexPath.row;
    
    BOOL isFav = [self.favoriteNames containsObject:name];
    if (isFav) {
        UIImage *img = [UIImage systemImageNamed:@"star.fill"];
        [starBtn setImage:img forState:UIControlStateNormal];
        starBtn.tintColor = [UIColor systemOrangeColor];
    } else {
        UIImage *img = [UIImage systemImageNamed:@"star"];
        [starBtn setImage:img forState:UIControlStateNormal];
        starBtn.tintColor = [UIColor tertiaryLabelColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= self.searchResults.count) return;
    
    NSDictionary *item = self.searchResults[indexPath.row];
    NSString *name = item[@"name"] ?: @"";
    NSString *gender = item[@"gender"] ?: @"";
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InfoController *infoVC = [storyboard instantiateViewControllerWithIdentifier:@"InfoController"];
    if (infoVC) {
        NSString *initial = name.length > 0 ? [name substringToIndex:1] : @"A";
        infoVC.detailItem = [NSString stringWithFormat:@"%@,%@,%@,%ld", gender, initial, name, (long)self.currentLimit];
        [self presentViewController:infoVC animated:YES completion:nil];
    }
}

- (void)starTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    if (index >= self.searchResults.count) return;
    
    NSDictionary *item = self.searchResults[index];
    NSString *name = item[@"name"];
    NSString *gender = item[@"gender"];
    if (!name || !gender) return;
    
    DBUser *currentUser = [DBUser currentUser];
    if (!currentUser) {
        [self.feedbackGenerator prepare];
        [self.feedbackGenerator impactOccurred];
        
        if ([self.favoriteNames containsObject:name]) {
            [self.favoriteNames removeObject:name];
        } else {
            [self.favoriteNames addObject:name];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[self.favoriteNames allObjects] forKey:@"guest_favorite_names"];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    
    NSString *userId = [currentUser objectForKey:@"userId"] ?: currentUser.objectId;
    if (!userId) return;
    
    [self.feedbackGenerator prepare];
    [self.feedbackGenerator impactOccurred];
    
    if ([self.favoriteNames containsObject:name]) {
        // Already favorited - remove from favorites
        [self.favoriteNames removeObject:name];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
        DBQuery *q = [DBQuery queryWithClassName:@"names"];
        [q whereKey:@"userId" equalTo:userId];
        [q whereKey:@"name" equalTo:name];
        [q setLimit:1];
        [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error && objects.count > 0) {
                [objects.firstObject deleteInBackground];
            }
        }];
    } else {
        // Add to favorites
        [self.favoriteNames addObject:name];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
        DBObject *nameObj = [DBObject objectWithClassName:@"names"];
        [nameObj setObject:name forKey:@"name"];
        [nameObj setObject:gender forKey:@"gender"];
        [nameObj setObject:userId forKey:@"userId"];
        [nameObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"[SearchFilter] Error saving favorite: %@", error);
            }
        }];
    }
}

@end
