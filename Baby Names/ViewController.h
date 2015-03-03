
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UIPickerView *alphabetPicker;
@property (weak, nonatomic) IBOutlet UITextField *limitTextField;
@property (weak, nonatomic) IBOutlet UIButton *sortButton;

@property NSMutableArray *alphabet;
@property int alphabetIndex;

@property NSString *genderString;
@property NSString *letterString;
@property NSString *sortString;
@property int limitNumber;

@end
