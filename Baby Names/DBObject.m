#import "DBObject.h"
@import FirebaseFirestore;

@implementation DBObject

+ (instancetype)objectWithClassName:(NSString *)className {
    return [[self alloc] initWithClassName:className];
}

- (instancetype)initWithClassName:(NSString *)className {
    self = [super init];
    if (self) {
        _parseClassName = className;
        _data = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setObject:(id)object forKey:(NSString *)key {
    if (object) {
        self.data[key] = object;
    } else {
        [self.data removeObjectForKey:key];
    }
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key {
    [self setObject:object forKey:key];
}

- (id)objectForKey:(NSString *)key {
    return self.data[key];
}

- (id)objectForKeyedSubscript:(NSString *)key {
    return [self objectForKey:key];
}

- (void)removeObjectForKey:(NSString *)key {
    [self.data removeObjectForKey:key];
}

- (void)saveInBackground {
    [self saveInBackgroundWithBlock:nil];
}

- (void)saveInBackgroundWithBlock:(void (^)(BOOL, NSError *))block {
    FIRFirestore *db = [FIRFirestore firestore];
    if (self.objectId) {
        [[[db collectionWithPath:self.parseClassName] documentWithPath:self.objectId] setData:self.data completion:^(NSError * _Nullable error) {
            if (block) block(error == nil, error);
        }];
    } else {
        __block FIRDocumentReference *ref = [[db collectionWithPath:self.parseClassName] addDocumentWithData:self.data completion:^(NSError * _Nullable error) {
            if (!error) {
                self.objectId = ref.documentID;
            }
            if (block) block(error == nil, error);
        }];
    }
}

- (void)deleteInBackground {
    [self deleteInBackgroundWithBlock:nil];
}

- (void)deleteInBackgroundWithBlock:(void (^)(BOOL, NSError *))block {
    if (self.objectId) {
        [[[[FIRFirestore firestore] collectionWithPath:self.parseClassName] documentWithPath:self.objectId] deleteDocumentWithCompletion:^(NSError * _Nullable error) {
            if (block) block(error == nil, error);
        }];
    } else {
        if (block) block(YES, nil);
    }
}

- (void)fetchInBackgroundWithBlock:(void (^)(DBObject *, NSError *))block {
    if (self.objectId) {
        [[[[FIRFirestore firestore] collectionWithPath:self.parseClassName] documentWithPath:self.objectId] getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (snapshot.exists) {
                [self.data addEntriesFromDictionary:snapshot.data];
            }
            if (block) block(self, error);
        }];
    } else {
        if (block) block(nil, nil);
    }
}
@end
