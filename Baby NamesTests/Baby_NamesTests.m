//
//  Baby_NamesTests.m
//  Baby NamesTests
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ViewController.h"
#import "NameController.h"
#import "InfoController.h"
#import "NamesController.h"
#import "Database.h"

@interface Baby_NamesTests : XCTestCase

@end

@implementation Baby_NamesTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSortSettersAndActionSheetHaveNoEmojis {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ViewController"];
    [vc view]; // Load view
    
    // Check sort button initial title has no emojis
    NSString *btnTitle = [vc.sortButton titleForState:UIControlStateNormal];
    XCTAssertTrue(btnTitle == nil || btnTitle.length == 0, @"Sort button title should be empty, was %@", btnTitle);
    
    // Call sort methods and verify button has no emojis
    [vc setPopular];
    XCTAssertEqualObjects([vc.sortButton titleForState:UIControlStateNormal], @"");
    [vc setUncommon];
    XCTAssertEqualObjects([vc.sortButton titleForState:UIControlStateNormal], @"");
    [vc setNamesAtoZ];
    XCTAssertEqualObjects([vc.sortButton titleForState:UIControlStateNormal], @"");
    [vc setNamesZtoA];
    XCTAssertEqualObjects([vc.sortButton titleForState:UIControlStateNormal], @"");
    [vc setNewest];
    XCTAssertEqualObjects([vc.sortButton titleForState:UIControlStateNormal], @"");
    [vc setOldest];
    XCTAssertEqualObjects([vc.sortButton titleForState:UIControlStateNormal], @"");
}

- (void)testNameControllerBoyPopularSortingAndFaceIcon {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NameController *nc = [sb instantiateViewControllerWithIdentifier:@"NameController"];
    nc.detailItem = @"M,ALL,👶,25";
    [nc view]; // Load view
    
    // Verify genderLabel has no emojis and is hidden
    XCTAssertEqualObjects(nc.genderLabel.text, @"", @"genderLabel text must be empty");
    XCTAssertTrue(nc.genderLabel.hidden, @"genderLabel must be hidden");
    
    // Verify genderImageView has face_boy
    XCTAssertNotNil(nc.genderImageView, @"genderImageView should exist");
    XCTAssertNotNil(nc.genderImageView.image, @"genderImageView should have image");
    
    nc.sortString = @"popular";
    [nc viewWillAppear:NO];
    
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return nc.names.count > 0;
    }];
    [self expectationForPredicate:pred evaluatedWithObject:nc handler:nil];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
    
    XCTAssertGreaterThan(nc.names.count, 0, @"Names should be loaded");
    NSLog(@"Loaded names for Boy Popular: %@", nc.names);
    
    XCTAssertTrue([nc.names containsObject:@"Noah"] || [nc.names containsObject:@"Liam"], @"Popular boy names should include top names like Noah or Liam");
    XCTAssertFalse([nc.names[0] isEqualToString:@"Aaden"], @"Top name should NOT be Aaden (alphabetical sorting bug)");
    XCTAssertFalse([nc.names[0] isEqualToString:@"Aaron"], @"Top name should NOT be Aaron (alphabetical sorting bug)");
}

- (void)testNameControllerGirlPopularSortingAndFaceIcon {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NameController *nc = [sb instantiateViewControllerWithIdentifier:@"NameController"];
    nc.detailItem = @"F,ALL,👶,25";
    [nc view];
    
    XCTAssertEqualObjects(nc.genderLabel.text, @"");
    XCTAssertTrue(nc.genderLabel.hidden);
    XCTAssertNotNil(nc.genderImageView.image);
    
    nc.sortString = @"popular";
    [nc viewWillAppear:NO];
    
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return nc.names.count > 0;
    }];
    [self expectationForPredicate:pred evaluatedWithObject:nc handler:nil];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
    
    XCTAssertGreaterThan(nc.names.count, 0, @"Names should be loaded");
    NSLog(@"Loaded names for Girl Popular: %@", nc.names);
    
    XCTAssertTrue([nc.names containsObject:@"Sophia"] || [nc.names containsObject:@"Emma"], @"Popular girl names should include Sophia or Emma");
    XCTAssertFalse([nc.names[0] isEqualToString:@"Aaliyah"], @"Top girl name should NOT be Aaliyah (alphabetical)");
}

- (void)testNameControllerLetterKPopularSorting {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NameController *nc = [sb instantiateViewControllerWithIdentifier:@"NameController"];
    nc.detailItem = @"M,K,👶,25";
    [nc view];
    
    nc.sortString = @"popular";
    [nc viewWillAppear:NO];
    
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return nc.names.count > 0;
    }];
    [self expectationForPredicate:pred evaluatedWithObject:nc handler:nil];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
    
    XCTAssertGreaterThan(nc.names.count, 0, @"Names should be loaded");
    NSLog(@"Loaded names for K Boy Popular: %@", nc.names);
    
    XCTAssertTrue([nc.names[0] isEqualToString:@"Kevin"], @"Most popular K boy name should be Kevin, got %@", nc.names[0]);
    XCTAssertTrue([nc.names containsObject:@"Kason"], @"K boy names should include Kason");
    XCTAssertFalse([nc.names[0] isEqualToString:@"Kade"], @"Kade is rank 418, should not be first!");
}

- (void)testNamesControllerGenderFilterSelection {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NamesController *namesVC = [sb instantiateViewControllerWithIdentifier:@"NamesController"];
    [namesVC loadViewIfNeeded];
    
    XCTAssertNotNil(namesVC.boyButton, @"Boy button should exist on favorites page");
    XCTAssertNotNil(namesVC.bothButton, @"Both button should exist on favorites page");
    XCTAssertNotNil(namesVC.girlButton, @"Girl button should exist on favorites page");
    XCTAssertNotNil(namesVC.genderStackView, @"Gender stack view should exist");
    
    // Test selecting Boy
    [namesVC filterBoy:nil];
    XCTAssertEqualObjects(namesVC.genderString, @"M", @"Selecting boy should set genderString to M");
    XCTAssertEqualWithAccuracy(namesVC.boyButton.alpha, 1.0, 0.01, @"Boy button alpha should be 1.0 when active");
    XCTAssertEqualWithAccuracy(namesVC.bothButton.alpha, 0.35, 0.01, @"Both button alpha should be 0.35 when inactive");
    XCTAssertEqualWithAccuracy(namesVC.girlButton.alpha, 0.35, 0.01, @"Girl button alpha should be 0.35 when inactive");
    
    // Test selecting Girl
    [namesVC filterGirl:nil];
    XCTAssertEqualObjects(namesVC.genderString, @"F", @"Selecting girl should set genderString to F");
    XCTAssertEqualWithAccuracy(namesVC.girlButton.alpha, 1.0, 0.01, @"Girl button alpha should be 1.0 when active");
    XCTAssertEqualWithAccuracy(namesVC.bothButton.alpha, 0.35, 0.01, @"Both button alpha should be 0.35 when inactive");
    XCTAssertEqualWithAccuracy(namesVC.boyButton.alpha, 0.35, 0.01, @"Boy button alpha should be 0.35 when inactive");
    
    // Test selecting Both
    [namesVC filterBoth:nil];
    XCTAssertEqualObjects(namesVC.genderString, @"All", @"Selecting both should set genderString to All");
    XCTAssertEqualWithAccuracy(namesVC.bothButton.alpha, 1.0, 0.01, @"Both button alpha should be 1.0 when active");
    XCTAssertEqualWithAccuracy(namesVC.boyButton.alpha, 0.35, 0.01, @"Boy button alpha should be 0.35 when inactive");
    XCTAssertEqualWithAccuracy(namesVC.girlButton.alpha, 0.35, 0.01, @"Girl button alpha should be 0.35 when inactive");
}

- (void)assertNoEmojisInViewHierarchy:(UIView *)rootView {
    NSArray *emojis = @[@"👦", @"👧", @"👶", @"👤", @"📝", @"▶️", @"🏡", @"🔀", @"💾", @"◀️", @"❤️", @"✖️"];
    NSMutableArray *viewsToVisit = [NSMutableArray arrayWithObject:rootView];
    while (viewsToVisit.count > 0) {
        UIView *v = viewsToVisit.firstObject;
        [viewsToVisit removeObjectAtIndex:0];
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)v;
            NSString *title = [btn titleForState:UIControlStateNormal];
            for (NSString *emoji in emojis) {
                if (title && [title containsString:emoji]) {
                    XCTFail(@"Found emoji '%@' in button title '%@'", emoji, title);
                }
            }
        } else if ([v isKindOfClass:[UILabel class]]) {
            UILabel *lbl = (UILabel *)v;
            NSString *text = lbl.text;
            for (NSString *emoji in emojis) {
                if (text && [text containsString:emoji]) {
                    XCTFail(@"Found emoji '%@' in label text '%@'", emoji, text);
                }
            }
        }
        [viewsToVisit addObjectsFromArray:v.subviews];
    }
}

- (void)testNoEmojiFlashesOnInitialInstantiation {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateInitialViewController];
    [vc loadViewIfNeeded];
    [self assertNoEmojisInViewHierarchy:vc.view];
    
    UIViewController *namesVC = [sb instantiateViewControllerWithIdentifier:@"NamesController"];
    [namesVC loadViewIfNeeded];
    [self assertNoEmojisInViewHierarchy:namesVC.view];
    
    UIViewController *nameVC = [sb instantiateViewControllerWithIdentifier:@"NameController"];
    [nameVC loadViewIfNeeded];
    [self assertNoEmojisInViewHierarchy:nameVC.view];
    
    UIViewController *infoVC = [sb instantiateViewControllerWithIdentifier:@"InfoController"];
    [infoVC loadViewIfNeeded];
    [self assertNoEmojisInViewHierarchy:infoVC.view];
}

@end
