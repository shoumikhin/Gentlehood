// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GHPost.h instead.

#import <CoreData/CoreData.h>

extern const struct GHPostAttributes {
	__unsafe_unretained NSString *content;
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *favorite;
	__unsafe_unretained NSString *height;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *url;
} GHPostAttributes;

extern const struct GHPostRelationships {
	__unsafe_unretained NSString *attachments;
	__unsafe_unretained NSString *categories;
} GHPostRelationships;

@class GHAttachment;
@class GHCategory;

@interface GHPostID : NSManagedObjectID {}
@end

@interface _GHPost : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) GHPostID* objectID;

@property (nonatomic, strong) NSString* content;

//- (BOOL)validateContent:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* favorite;

@property (atomic) BOOL favoriteValue;
- (BOOL)favoriteValue;
- (void)setFavoriteValue:(BOOL)value_;

//- (BOOL)validateFavorite:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* height;

@property (atomic) float heightValue;
- (float)heightValue;
- (void)setHeightValue:(float)value_;

//- (BOOL)validateHeight:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* identifier;

@property (atomic) int64_t identifierValue;
- (int64_t)identifierValue;
- (void)setIdentifierValue:(int64_t)value_;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* url;

//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *attachments;

- (NSMutableSet*)attachmentsSet;

@property (nonatomic, strong) NSSet *categories;

- (NSMutableSet*)categoriesSet;

@end

@interface _GHPost (AttachmentsCoreDataGeneratedAccessors)
- (void)addAttachments:(NSSet*)value_;
- (void)removeAttachments:(NSSet*)value_;
- (void)addAttachmentsObject:(GHAttachment*)value_;
- (void)removeAttachmentsObject:(GHAttachment*)value_;

@end

@interface _GHPost (CategoriesCoreDataGeneratedAccessors)
- (void)addCategories:(NSSet*)value_;
- (void)removeCategories:(NSSet*)value_;
- (void)addCategoriesObject:(GHCategory*)value_;
- (void)removeCategoriesObject:(GHCategory*)value_;

@end

@interface _GHPost (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveContent;
- (void)setPrimitiveContent:(NSString*)value;

- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;

- (NSNumber*)primitiveFavorite;
- (void)setPrimitiveFavorite:(NSNumber*)value;

- (BOOL)primitiveFavoriteValue;
- (void)setPrimitiveFavoriteValue:(BOOL)value_;

- (NSNumber*)primitiveHeight;
- (void)setPrimitiveHeight:(NSNumber*)value;

- (float)primitiveHeightValue;
- (void)setPrimitiveHeightValue:(float)value_;

- (NSNumber*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSNumber*)value;

- (int64_t)primitiveIdentifierValue;
- (void)setPrimitiveIdentifierValue:(int64_t)value_;

- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;

- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;

- (NSMutableSet*)primitiveAttachments;
- (void)setPrimitiveAttachments:(NSMutableSet*)value;

- (NSMutableSet*)primitiveCategories;
- (void)setPrimitiveCategories:(NSMutableSet*)value;

@end
