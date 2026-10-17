
#import "Database.h"
#import <UIKit/UIKit.h>

@interface NamesController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UITableView *namesTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *name;

@property NSMutableArray *names;
@property NSMutableArray *genders;
@property NSString *genderLetter;
@property NSString *genderString;

@property (strong, nonatomic) UIButton *boyButton;
@property (strong, nonatomic) UIButton *bothButton;
@property (strong, nonatomic) UIButton *girlButton;
@property (strong, nonatomic) UIStackView *genderStackView;

@property int index;

- (IBAction)filterBoy:(id)sender;
- (IBAction)filterBoth:(id)sender;
- (IBAction)filterGirl:(id)sender;

@end
