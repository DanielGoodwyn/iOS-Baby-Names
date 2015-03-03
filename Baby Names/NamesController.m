
#import "NamesController.h"

@interface NamesController ()

@end

@implementation NamesController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.names = [[NSMutableArray alloc] init];
    self.genders = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [self getNameListWithGender:nil];
}

- (void)getNameListWithGender:(NSString*) gender {
    PFUser *currentUser = [PFUser currentUser];
    
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
    
    PFQuery *query = [PFQuery queryWithClassName:@"names"];
    [query whereKey:@"userId" equalTo:[currentUser objectId]];
    if (gender != nil) {
        if ([gender isEqualToString:@"F"]) {
            [query whereKey:@"gender" equalTo:@"F"];
        } if ([gender isEqualToString:@"M"]) {
            [query whereKey:@"gender" equalTo:@"M"];
        }
    }
    
    NSString *letterString =  @"";
    letterString = [currentUser objectForKey:@"letter"];
    NSString *sortString = [currentUser objectForKey:@"sort"];
    NSString *genderString = [currentUser objectForKey:@"gender"];
    int limitNumber = (int)[[currentUser objectForKey:@"limit"] integerValue];
    
    if ([sortString isEqualToString:@"oldest"]) {
        [query orderByAscending:@"createdAt"];
    } else if ([sortString isEqualToString:@"newest"]) {
        [query orderByDescending:@"createdAt"];
    } else if ([sortString isEqualToString:@"namesAtoZ"]) {
        [query orderByAscending:@"name"];
    } else if ([sortString isEqualToString:@"namesZtoA"]) {
        [query orderByDescending:@"name"];
    } else {
        [query orderByAscending:@"name"];
    }
    if (![genderString isEqualToString: @"All"]) {
        [query whereKey:@"gender" equalTo:genderString];
    }
    if ([letterString isEqualToString:@"ALL"]) {
    } else {
        [query whereKey:@"name" matchesRegex:[NSString stringWithFormat:@"%@.*", letterString ]];
    }
    query.limit = limitNumber;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [self.names addObject:[object valueForKey:@"name"]];
                [self.genders addObject:[object valueForKey:@"gender"]];
            }
        } else {
        }
        
        [self.names removeObjectAtIndex:0];
        [self.genders removeObjectAtIndex:0];
        
        [self.namesTable reloadData];
        [self.activityIndicator stopAnimating];
        [self random:nil];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [self setRandomName];
    [self.namesTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
    UIScreenEdgePanGestureRecognizer *left = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(leftEdge:)];
    UIScreenEdgePanGestureRecognizer *right = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(rightEdge:)];
    left.edges = UIRectEdgeLeft;
    right.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:left];
    [self.view addGestureRecognizer:right];
}

#pragma mark - random

- (void)setRandomName {
    int lo = 0;
    int hi = (int)[self.names count];
    if (hi < 1) {hi=1;} else if (hi > 200) {hi=200;}
    self.index = lo + arc4random() % (hi - lo);
    if (self.names!=nil) {
        [self.name setText:self.names[self.index]];
    }
}

#pragma mark - shake

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self setRandomName];
        [self.namesTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}

#pragma mark - edge pan gesture

- (void)leftEdge: (UIScreenEdgePanGestureRecognizer*)edgeRecognizer{
    [self lastPage];
    [self performSegueWithIdentifier:@"home" sender:edgeRecognizer];
}

- (void)rightEdge: (UIScreenEdgePanGestureRecognizer*)edgeRecognizer{
    [self lastPage];
    [self performSegueWithIdentifier:@"info" sender:edgeRecognizer];
}

#pragma mark - buttons

- (IBAction)random:(id)sender {
    [self setRandomName];
    [self.namesTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
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
        cell.backgroundColor = [UIColor colorWithRed:1 green:.8 blue:.85 alpha:1];
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:.8 green:.6 blue:.65 alpha:1];
    } else {
        genderEmoji = @"👦";
        cell.backgroundColor = [UIColor colorWithRed:.8 green:.85 blue:1 alpha:1];
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:.6 green:.65 blue:8 alpha:1];
    }
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:0];
    label.text = [self.names objectAtIndex:indexPath.row];
    label = (UILabel *)[cell viewWithTag:1];
    label.text = genderEmoji;

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
        
        PFQuery *query = [PFQuery queryWithClassName:@"names"];
        [query whereKey:@"name" containsString:self.names[indexPath.row]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *object in objects) {
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
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:@"MyNames" forKey:@"lastPage"];
    [currentUser saveInBackground];
}

@end
