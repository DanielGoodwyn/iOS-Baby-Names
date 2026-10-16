#import "DBQuery.h"
@import FirebaseFirestore;

@interface DBQuery ()
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) FIRQuery *query;
@end

@implementation DBQuery
+ (instancetype)queryWithClassName:(NSString *)className {
    return [[self alloc] initWithClassName:className];
}

- (instancetype)initWithClassName:(NSString *)className {
    self = [super init];
    if (self) {
        _className = className;
        _query = [[FIRFirestore firestore] collectionWithPath:className];
    }
    return self;
}

- (void)whereKey:(NSString *)key equalTo:(id)object {
    self.query = [self.query queryWhereField:key isEqualTo:object];
}

- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex {
    NSString *prefix = [regex stringByReplacingOccurrencesOfString:@".*" withString:@""];
    self.query = [[self.query queryWhereField:key isGreaterThanOrEqualTo:prefix] queryWhereField:key isLessThan:[NSString stringWithFormat:@"%@\uf8ff", prefix]];
}

- (void)whereKey:(NSString *)key containsString:(NSString *)substring {
    self.query = [[self.query queryWhereField:key isGreaterThanOrEqualTo:substring] queryWhereField:key isLessThan:[NSString stringWithFormat:@"%@\uf8ff", substring]];
}

- (void)orderByAscending:(NSString *)key {
    self.query = [self.query queryOrderedByField:key descending:NO];
}

- (void)orderByDescending:(NSString *)key {
    self.query = [self.query queryOrderedByField:key descending:YES];
}

- (void)setLimit:(NSInteger)limit {
    _limit = limit;
    if (limit > 0) {
        self.query = [self.query queryLimitedTo:limit];
    }
}

- (void)findObjectsInBackgroundWithBlock:(void (^)(NSArray *, NSError *))block {
    [self.query getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (error) {
            if (block) block(nil, error);
        } else {
            NSMutableArray *results = [NSMutableArray array];
            for (FIRDocumentSnapshot *doc in snapshot.documents) {
                DBObject *obj = [DBObject objectWithClassName:self.className];
                obj.objectId = doc.documentID;
                [obj.data addEntriesFromDictionary:doc.data];
                [results addObject:obj];
            }
            if (block) block(results, nil);
        }
    }];
}
@end
