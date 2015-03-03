
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NameController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *letterLabel;
@property (weak, nonatomic) IBOutlet UITableView *namesTable;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property NSString *genderString;
@property NSString *letterString;
@property NSString *sortString;
@property int limitNumber;

@property NSMutableArray *names;
@property int index;

@property NSString *nameChosen;

@end
