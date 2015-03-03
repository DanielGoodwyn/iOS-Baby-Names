
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface InfoController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *letterLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property NSString *genderString;
@property NSString *letterString;
@property NSString *nameString;
@property int limitNumber;

@property NSString *urlString;
@property NSString *nameChosen;

@end
