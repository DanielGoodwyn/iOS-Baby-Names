#import "Database.h"
#import <UIKit/UIKit.h>
#import "SearchFilterViewController.h"

@interface ViewController : UIViewController <SearchFilterDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UIPickerView *alphabetPicker;
@property (weak, nonatomic) IBOutlet UITextField *limitTextField;
@property (weak, nonatomic) IBOutlet UIButton *sortButton;
@property (strong, nonatomic) UIButton *searchButton;

@property NSMutableArray *alphabet;
@property int alphabetIndex;

@property NSString *genderString;
@property NSString *letterString;
@property NSString *sortString;
@property int limitNumber;

- (IBAction)openSearchFilter:(id)sender;
- (void)setPopular;
- (void)setUncommon;
- (void)setNamesAtoZ;
- (void)setNamesZtoA;
- (void)setNewest;
- (void)setOldest;

@end
