// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GHPost.m instead.

#import "_GHPost.h"


const struct GHPostAttributes GHPostAttributes = {
	.content = @"content",
	.date = @"date",
	.favorite = @"favorite",
	.height = @"height",
	.identifier = @"identifier",
	.title = @"title",
	.url = @"url",
};



const struct GHPostRelationships GHPostRelationships = {
	.attachments = @"attachments",
	.categories = @"categories",
};






@implementation GHPostID
@end

@implementation _GHPost

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"GHPost" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"GHPost";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"GHPost" inManagedObjectContext:moc_];
}

- (GHPostID*)objectID {
	return (GHPostID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"favoriteValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"favorite"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"heightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"height"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"identifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"identifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic content;






@dynamic date;






@dynamic favorite;



- (BOOL)favoriteValue {
	NSNumber *result = [self favorite];
	return [result boolValue];
}


- (void)setFavoriteValue:(BOOL)value_ {
	[self setFavorite:@(value_)];
}


- (BOOL)primitiveFavoriteValue {
	NSNumber *result = [self primitiveFavorite];
	return [result boolValue];
}

- (void)setPrimitiveFavoriteValue:(BOOL)value_ {
	[self setPrimitiveFavorite:@(value_)];
}





@dynamic height;



- (float)heightValue {
	NSNumber *result = [self height];
	return [result floatValue];
}


- (void)setHeightValue:(float)value_ {
	[self setHeight:@(value_)];
}


- (float)primitiveHeightValue {
	NSNumber *result = [self primitiveHeight];
	return [result floatValue];
}

- (void)setPrimitiveHeightValue:(float)value_ {
	[self setPrimitiveHeight:@(value_)];
}





@dynamic identifier;



- (int64_t)identifierValue {
	NSNumber *result = [self identifier];
	return [result longLongValue];
}


- (void)setIdentifierValue:(int64_t)value_ {
	[self setIdentifier:@(value_)];
}


- (int64_t)primitiveIdentifierValue {
	NSNumber *result = [self primitiveIdentifier];
	return [result longLongValue];
}

- (void)setPrimitiveIdentifierValue:(int64_t)value_ {
	[self setPrimitiveIdentifier:@(value_)];
}





@dynamic title;






@dynamic url;






@dynamic attachments;

	
- (NSMutableSet*)attachmentsSet {
	[self willAccessValueForKey:@"attachments"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"attachments"];
  
	[self didAccessValueForKey:@"attachments"];
	return result;
}
	

@dynamic categories;

	
- (NSMutableSet*)categoriesSet {
	[self willAccessValueForKey:@"categories"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"categories"];
  
	[self didAccessValueForKey:@"categories"];
	return result;
}
	






@end




