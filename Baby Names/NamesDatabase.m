#import "NamesDatabase.h"

@interface NamesDatabase ()
@property (nonatomic, strong) NSArray<NSDictionary *> *namesArray;
@property (nonatomic, strong) NSArray<NSDictionary *> *boysArray;
@property (nonatomic, strong) NSArray<NSDictionary *> *girlsArray;
@end

@implementation NamesDatabase

+ (instancetype)sharedDatabase {
    static NamesDatabase *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadDatabase];
    }
    return self;
}

- (void)loadDatabase {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"names" ofType:@"json"];
    if (!path) {
        NSLog(@"[NamesDatabase] Error: names.json not found in main bundle!");
        self.namesArray = @[];
        self.boysArray = @[];
        self.girlsArray = @[];
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        NSLog(@"[NamesDatabase] Error reading names.json data");
        self.namesArray = @[];
        self.boysArray = @[];
        self.girlsArray = @[];
        return;
    }
    
    NSError *error = nil;
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || ![json isKindOfClass:[NSArray class]]) {
        NSLog(@"[NamesDatabase] JSON parsing error: %@", error);
        self.namesArray = @[];
        self.boysArray = @[];
        self.girlsArray = @[];
        return;
    }
    
    self.namesArray = json;
    NSMutableArray *boys = [NSMutableArray arrayWithCapacity:14000];
    NSMutableArray *girls = [NSMutableArray arrayWithCapacity:19000];
    for (NSDictionary *item in json) {
        NSString *g = item[@"gender"];
        if ([g isEqualToString:@"M"]) {
            [boys addObject:item];
        } else if ([g isEqualToString:@"F"]) {
            [girls addObject:item];
        }
    }
    self.boysArray = [boys copy];
    self.girlsArray = [girls copy];
    NSLog(@"[NamesDatabase] Loaded %lu total names (%lu boys, %lu girls)",
          (unsigned long)self.namesArray.count,
          (unsigned long)self.boysArray.count,
          (unsigned long)self.girlsArray.count);
}

- (NSArray<NSDictionary *> *)allNames {
    return self.namesArray;
}

- (NSArray<NSDictionary *> *)namesForGender:(NSString *)gender
                                     letter:(NSString *)letter
                                       sort:(NSString *)sort
                                      limit:(NSInteger)limit {
    NSArray *sourceList = self.namesArray;
    if ([gender isEqualToString:@"M"] || [gender isEqualToString:@"👦"]) {
        sourceList = self.boysArray;
    } else if ([gender isEqualToString:@"F"] || [gender isEqualToString:@"👧"]) {
        sourceList = self.girlsArray;
    }
    
    BOOL hasLetter = (letter != nil && letter.length > 0 &&
                      ![letter isEqualToString:@"ALL"] &&
                      ![letter isEqualToString:@"*"]);
    NSString *prefix = hasLetter ? [letter lowercaseString] : nil;
    
    NSMutableArray *filtered = [NSMutableArray arrayWithCapacity:limit > 0 && limit < 1000 ? limit * 2 : 1000];
    for (NSDictionary *item in sourceList) {
        NSString *name = item[@"name"];
        if (!name) continue;
        if (hasLetter) {
            if (![[name lowercaseString] hasPrefix:prefix]) {
                continue;
            }
        }
        [filtered addObject:item];
    }
    
    // Sort
    if ([sort isEqualToString:@"uncommon"]) {
        [filtered sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
            NSInteger rA = [a[@"rank"] integerValue];
            NSInteger rB = [b[@"rank"] integerValue];
            if (rA != rB) return rA > rB ? NSOrderedAscending : NSOrderedDescending;
            return [a[@"name"] compare:b[@"name"] options:NSCaseInsensitiveSearch];
        }];
    } else if ([sort isEqualToString:@"popular"]) {
        [filtered sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
            NSInteger rA = [a[@"rank"] integerValue];
            NSInteger rB = [b[@"rank"] integerValue];
            if (rA == 0) rA = 999999;
            if (rB == 0) rB = 999999;
            if (rA != rB) return rA < rB ? NSOrderedAscending : NSOrderedDescending;
            return [a[@"name"] compare:b[@"name"] options:NSCaseInsensitiveSearch];
        }];
    } else if ([sort isEqualToString:@"namesZtoA"]) {
        [filtered sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
            return [b[@"name"] compare:a[@"name"] options:NSCaseInsensitiveSearch];
        }];
    } else { // namesAtoZ or default
        [filtered sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
            return [a[@"name"] compare:b[@"name"] options:NSCaseInsensitiveSearch];
        }];
    }
    
    if (limit > 0 && limit < filtered.count) {
        return [filtered subarrayWithRange:NSMakeRange(0, limit)];
    }
    return [filtered copy];
}

- (NSArray<NSDictionary *> *)searchNamesWithQuery:(NSString *)query
                                            limit:(NSInteger)limit {
    NSString *trimmed = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
    if (trimmed.length == 0) {
        return @[];
    }
    
    if (limit <= 0) limit = 50;
    
    NSMutableArray *prefixMatches = [NSMutableArray array];
    NSMutableArray *containsMatches = [NSMutableArray array];
    
    for (NSDictionary *item in self.namesArray) {
        NSString *name = item[@"name"];
        if (!name) continue;
        NSString *lower = [name lowercaseString];
        if ([lower hasPrefix:trimmed]) {
            [prefixMatches addObject:item];
            if (prefixMatches.count >= limit) break;
        } else if ([lower containsString:trimmed]) {
            if (containsMatches.count < limit) {
                [containsMatches addObject:item];
            }
        }
    }
    
    NSMutableArray *result = [NSMutableArray arrayWithArray:prefixMatches];
    for (NSDictionary *item in containsMatches) {
        if (result.count >= limit) break;
        if (![result containsObject:item]) {
            [result addObject:item];
        }
    }
    return result;
}

@end
