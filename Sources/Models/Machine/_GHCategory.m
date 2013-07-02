// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GHCategory.m instead.

#import "_GHCategory.h"


const struct GHCategoryAttributes GHCategoryAttributes = {
	.identifier = @"identifier",
	.postCount = @"postCount",
};



const struct GHCategoryRelationships GHCategoryRelationships = {
	.posts = @"posts",
};






@implementation GHCategoryID
@end

@implementation _GHCategory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"GHCategory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"GHCategory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"GHCategory" inManagedObjectContext:moc_];
}

- (GHCategoryID*)objectID {
	return (GHCategoryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"identifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"identifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"postCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"postCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
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





@dynamic postCount;



- (int64_t)postCountValue {
	NSNumber *result = [self postCount];
	return [result longLongValue];
}


- (void)setPostCountValue:(int64_t)value_ {
	[self setPostCount:@(value_)];
}


- (int64_t)primitivePostCountValue {
	NSNumber *result = [self primitivePostCount];
	return [result longLongValue];
}

- (void)setPrimitivePostCountValue:(int64_t)value_ {
	[self setPrimitivePostCount:@(value_)];
}





@dynamic posts;

	
- (NSMutableSet*)postsSet {
	[self willAccessValueForKey:@"posts"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"posts"];
  
	[self didAccessValueForKey:@"posts"];
	return result;
}
	






@end




