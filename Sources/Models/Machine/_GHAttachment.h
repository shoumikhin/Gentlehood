// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GHAttachment.h instead.

#import <CoreData/CoreData.h>



extern const struct GHAttachmentAttributes {
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *isLoaded;
	__unsafe_unretained NSString *mime;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *url;
} GHAttachmentAttributes;



extern const struct GHAttachmentRelationships {
	__unsafe_unretained NSString *post;
} GHAttachmentRelationships;






@class GHPost;












@interface GHAttachmentID : NSManagedObjectID {}
@end

@interface _GHAttachment : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (GHAttachmentID*)objectID;





@property (nonatomic, strong) NSNumber* identifier;




@property (atomic) int64_t identifierValue;
- (int64_t)identifierValue;
- (void)setIdentifierValue:(int64_t)value_;


//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isLoaded;




@property (atomic) BOOL isLoadedValue;
- (BOOL)isLoadedValue;
- (void)setIsLoadedValue:(BOOL)value_;


//- (BOOL)validateIsLoaded:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* mime;



//- (BOOL)validateMime:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) GHPost *post;

//- (BOOL)validatePost:(id*)value_ error:(NSError**)error_;





@end



@interface _GHAttachment (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSNumber*)value;

- (int64_t)primitiveIdentifierValue;
- (void)setPrimitiveIdentifierValue:(int64_t)value_;




- (NSNumber*)primitiveIsLoaded;
- (void)setPrimitiveIsLoaded:(NSNumber*)value;

- (BOOL)primitiveIsLoadedValue;
- (void)setPrimitiveIsLoadedValue:(BOOL)value_;




- (NSString*)primitiveMime;
- (void)setPrimitiveMime:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (GHPost*)primitivePost;
- (void)setPrimitivePost:(GHPost*)value;


@end
