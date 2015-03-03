
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface NamesController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UITableView *namesTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *name;

@property NSMutableArray *names;
@property NSMutableArray *genders;
@property NSString *genderLetter;

@property int index;

@end
