// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GHAttachment.m instead.

#import "_GHAttachment.h"

const struct GHAttachmentAttributes GHAttachmentAttributes = {
	.identifier = @"identifier",
	.isLoaded = @"isLoaded",
	.mime = @"mime",
	.title = @"title",
	.url = @"url",
};

const struct GHAttachmentRelationships GHAttachmentRelationships = {
	.post = @"post",
};

@implementation GHAttachmentID
@end

@implementation _GHAttachment

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"GHAttachment" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"GHAttachment";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"GHAttachment" inManagedObjectContext:moc_];
}

- (GHAttachmentID*)objectID {
	return (GHAttachmentID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"identifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"identifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isLoadedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isLoaded"];
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
	[self setIdentifier:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveIdentifierValue {
	NSNumber *result = [self primitiveIdentifier];
	return [result longLongValue];
}

- (void)setPrimitiveIdentifierValue:(int64_t)value_ {
	[self setPrimitiveIdentifier:[NSNumber numberWithLongLong:value_]];
}

@dynamic isLoaded;

- (BOOL)isLoadedValue {
	NSNumber *result = [self isLoaded];
	return [result boolValue];
}

- (void)setIsLoadedValue:(BOOL)value_ {
	[self setIsLoaded:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsLoadedValue {
	NSNumber *result = [self primitiveIsLoaded];
	return [result boolValue];
}

- (void)setPrimitiveIsLoadedValue:(BOOL)value_ {
	[self setPrimitiveIsLoaded:[NSNumber numberWithBool:value_]];
}

@dynamic mime;

@dynamic title;

@dynamic url;

@dynamic post;

@end

