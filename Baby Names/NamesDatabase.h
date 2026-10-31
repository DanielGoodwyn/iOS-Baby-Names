#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NamesDatabase : NSObject

+ (instancetype)sharedDatabase;

@property (nonatomic, readonly) NSArray<NSDictionary *> *allNames;

- (NSArray<NSDictionary *> *)namesForGender:(NSString *)gender
                                     letter:(NSString *)letter
                                       sort:(NSString *)sort
                                      limit:(NSInteger)limit;

- (NSArray<NSDictionary *> *)searchNamesWithQuery:(NSString *)query
                                            limit:(NSInteger)limit;

@end

NS_ASSUME_NONNULL_END
