
#import "NameController.h"

@interface NameController ()

@end

@implementation NameController

#pragma mark - view

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameChosen = @"NO";

    self.names = [[NSMutableArray alloc] init];
    NSArray *parsed = [_detailItem componentsSeparatedByString:@","];
    self.genderString = parsed[0];
    self.letterString = parsed[1];
    self.limitNumber = [parsed[3] intValue];
    
    PFUser *currentUser = [PFUser currentUser];

    self.genderString = [currentUser objectForKey:@"gender"];

    self.letterString = [currentUser objectForKey:@"letter"];
    
    self.limitNumber = (int)[[currentUser objectForKey:@"limit"] integerValue];
    
    self.sortString = [currentUser objectForKey:@"sort"];
    
    if ([self.genderString isEqual:@"M"]) {
        self.genderString =@"👦";
    } else if ([self.genderString isEqual:@"F"]) {
        self.genderString =@"👧";
    } else {
        self.genderString =@"👶";
    }
        
    self.genderLabel.text = self.genderString;
    if ([self.letterString isEqualToString:@"ALL"]) {
        self.letterLabel.text = @"*";
    } else {
        self.letterLabel.text = self.letterString;
    }
    
    if ([self.genderString isEqual:@"👦"]) {
        [self.view setBackgroundColor:[UIColor colorWithRed:.8 green:.85 blue:1 alpha:1]];
    } if ([self.genderString isEqual:@"👧"]) {
        [self.view setBackgroundColor:[UIColor colorWithRed:1 green:.8 blue:.85 alpha:1]];
    } if ([self.genderString isEqual:@"👶"]) {
        [self.view setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    }
    
    UIScreenEdgePanGestureRecognizer *left = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(leftEdge:)];
    UIScreenEdgePanGestureRecognizer *right = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(rightEdge:)];
    left.edges = UIRectEdgeLeft;
    right.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:left];
    [self.view addGestureRecognizer:right];}

- (void)viewWillAppear:(BOOL)animated {
    PFUser *currentUser = [PFUser currentUser];
    [self.names removeAllObjects];
    // query to populate array
    // https://parse.com/docs/ios_guide#queries/iOS
    
    NSString *genderLetter;
    if ([self.genderString isEqual:@"👦"]) {
        genderLetter =@"M";
    } if ([self.genderString isEqual:@"👧"]) {
        genderLetter =@"F";
    } if ([self.genderString isEqual:@"👶"]) {
        genderLetter =@"All";
    }
    [self.activityIndicator startAnimating];
    PFQuery *query = [PFQuery queryWithClassName:@"name"];
    
    NSString *genderString = [currentUser objectForKey:@"gender"];
    if (![genderString isEqualToString:@"All"]) {
        [query whereKey:@"gender" equalTo:genderLetter];
    }
    if (![self.letterString isEqualToString:@"ALL"]) {
        [query whereKey:@"name" matchesRegex:[NSString stringWithFormat:@"%@.*", self.letterString ]];
    }
    if ([self.sortString isEqualToString:@"popular"]) {
        [query orderByAscending:@"rank"];
    } else if ([self.sortString isEqualToString:@"uncommon"]) {
        [query orderByDescending:@"rank"];
    } else if ([self.sortString isEqualToString:@"namesAtoZ"]) {
        [query orderByAscending:@"name"];
    } else if ([self.sortString isEqualToString:@"namesZtoA"]) {
        [query orderByDescending:@"name"];
    } else {
        [query orderByAscending:@"rank"];
    }
    query.limit = self.limitNumber;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [self.names addObject:[object valueForKey:@"name"]];
            }
        } else {
        }
        [self.namesTable reloadData];
        [self setRandomName];
        [self.activityIndicator stopAnimating];
        [self.namesTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        [self setNameToUser];
    }];
}

#pragma mark - set name to user

- (void) setNameToUser {
    PFUser *currentUser = [PFUser currentUser];
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
        
        PFQuery *query = [PFQuery queryWithClassName:@"names"];
        [query whereKey:@"name" equalTo:self.names[indexPath.row]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count>0){
                self.nameChosen = @"YES";
            } else {
                self.nameChosen = @"NO";
            }
            if ([self.nameChosen isEqualToString:@"NO"]) {
                PFUser *currentUser = [PFUser currentUser];
                
                PFObject *object = [PFObject objectWithClassName:@"names"];
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
    [self performSegueWithIdentifier:@"home" sender:edgeRecognizer];
}

- (void)rightEdge: (UIScreenEdgePanGestureRecognizer*)edgeRecognizer{
    [self lastPage];
    [self performSegueWithIdentifier:@"info" sender:edgeRecognizer];
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
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
        name = self.names[indexPath.row];
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
    [self.namesTable reloadData];
}

- (void)lastPage {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:@"NewNames" forKey:@"lastPage"];
    [currentUser saveInBackground];
}

@end
