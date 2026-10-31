#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SearchFilterDelegate <NSObject>
@optional
- (void)searchFilterDidUpdateLimit:(NSInteger)newLimit;
@end

@interface SearchFilterViewController : UIViewController

@property (nonatomic, weak) id<SearchFilterDelegate> delegate;
@property (nonatomic, assign) NSInteger currentLimit;

@end

NS_ASSUME_NONNULL_END
