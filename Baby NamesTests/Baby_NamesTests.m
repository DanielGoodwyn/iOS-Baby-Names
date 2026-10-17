//
//  Baby_NamesTests.m
//  Baby NamesTests
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ViewController.h"
#import "NameController.h"
#import "InfoController.h"
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

@end
