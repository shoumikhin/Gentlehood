// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GHCategory.h instead.

#import <CoreData/CoreData.h>

extern const struct GHCategoryAttributes {
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *postCount;
} GHCategoryAttributes;

extern const struct GHCategoryRelationships {
	__unsafe_unretained NSString *posts;
} GHCategoryRelationships;

@class GHPost;

@interface GHCategoryID : NSManagedObjectID {}
@end

@interface _GHCategory : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) GHCategoryID* objectID;

@property (nonatomic, strong) NSNumber* identifier;

@property (atomic) int64_t identifierValue;
- (int64_t)identifierValue;
- (void)setIdentifierValue:(int64_t)value_;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* postCount;

@property (atomic) int64_t postCountValue;
- (int64_t)postCountValue;
- (void)setPostCountValue:(int64_t)value_;

//- (BOOL)validatePostCount:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *posts;

- (NSMutableSet*)postsSet;

@end

@interface _GHCategory (PostsCoreDataGeneratedAccessors)
- (void)addPosts:(NSSet*)value_;
- (void)removePosts:(NSSet*)value_;
- (void)addPostsObject:(GHPost*)value_;
- (void)removePostsObject:(GHPost*)value_;

@end

@interface _GHCategory (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSNumber*)value;

- (int64_t)primitiveIdentifierValue;
- (void)setPrimitiveIdentifierValue:(int64_t)value_;

- (NSNumber*)primitivePostCount;
- (void)setPrimitivePostCount:(NSNumber*)value;

- (int64_t)primitivePostCountValue;
- (void)setPrimitivePostCountValue:(int64_t)value_;

- (NSMutableSet*)primitivePosts;
- (void)setPrimitivePosts:(NSMutableSet*)value;

@end
