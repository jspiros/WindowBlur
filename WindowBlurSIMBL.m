//
//  WindowBlurSIMBL.m
//  WindowBlur
//
//  Created by Joseph Spiros on 5/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WindowBlurSIMBL.h"
#import "CGSInternal.h"
#import <objc/objc-class.h>

void MethodSwizzle(Class aClass, SEL orig_sel, SEL alt_sel)
{
    Method orig_method = nil, alt_method = nil;
	
    // First, look for the methods
    orig_method = class_getInstanceMethod(aClass, orig_sel);
    alt_method = class_getInstanceMethod(aClass, alt_sel);
	
    // If both are found, swizzle them
    if ((orig_method != nil) && (alt_method != nil))
	{
        char *temp1;
        IMP temp2;
		
        temp1 = orig_method->method_types;
        orig_method->method_types = alt_method->method_types;
        alt_method->method_types = temp1;
		
        temp2 = orig_method->method_imp;
        orig_method->method_imp = alt_method->method_imp;
        alt_method->method_imp = temp2;
	}
}

static NSMutableDictionary *instanceIDToIvars = nil;
static BOOL needToSwizzleDealloc = YES;

@implementation WindowBlurWindowHack

- (id)PRE__instanceID
{
    return [NSValue valueWithPointer:self];
}

- (NSMutableDictionary *)PRE__ivars
{
    NSMutableDictionary *ivars;
    
    if (needToSwizzleDealloc)
    {
    	MethodSwizzle([NSWindow class], 
    	              @selector(dealloc), 
    	              @selector(PRE__deallocSwizzler));
    	needToSwizzleDealloc = NO;
    }
	
    if (instanceIDToIvars == nil)
    {
        instanceIDToIvars = [[NSMutableDictionary alloc] init];
    }
    
    ivars = [instanceIDToIvars objectForKey:[self PRE__instanceID]];
    if (ivars == nil)
    {
        ivars = [NSMutableDictionary dictionary];
        [instanceIDToIvars setObject:ivars forKey:[self PRE__instanceID]];
    }
    
    return ivars;
}

- (void)PRE__deallocSwizzler
{
    [instanceIDToIvars removeObjectForKey:[self PRE__instanceID]];
    if ([instanceIDToIvars count] == 0)
    {
        [instanceIDToIvars release];
        instanceIDToIvars = nil;
    }
    
    [self PRE__deallocSwizzler];
}

- (void)display {
	#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
	if (floor(NSAppKitVersionNumber) > 824) {
		NSString *filterName;
		if (!(filterName = [[NSUserDefaults standardUserDefaults] stringForKey:@"WindowBlurSIMBL-FilterName"])) {
			filterName = @"CIGaussianBlur";
		}
		NSDictionary *filterValues;
		if (!(filterValues = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"WindowBlurSIMBL-FilterValues"])) {
			filterValues = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:2.0] forKey:@"inputRadius"];
		}
		NSMutableDictionary *optionsDict = [NSMutableDictionary dictionaryWithDictionary:filterValues];
		if (![optionsDict objectForKey:@"inputCenter"]) {
			[optionsDict setObject:[CIVector vectorWithX:0.0 Y:0.0] forKey:@"inputCenter"];
		}
		CGSConnectionID con = CGSMainConnectionID();
		if (con) {
			NSNumber *filterNumber;
			int filter;
			if (filterNumber = [[self PRE__ivars] objectForKey:@"filter"]) {
				filter = [filterNumber intValue];
				CGSRemoveWindowFilter(con, [self windowNumber], filter);
			}
			if (noErr == CGSNewCIFilterByName(con, (CFStringRef)filterName, &filter)) {
				CGSSetCIFilterValuesFromDictionary(con, filter, (CFDictionaryRef)optionsDict);
				CGSAddWindowFilter(con, [self windowNumber], filter, kCGWindowFilterUnderlay);
				[[self PRE__ivars] setObject:[NSNumber numberWithInt:filter] forKey:@"filter"];
			}
		}			
	}
	#endif
	[super display];
}

@end

@implementation WindowBlurSIMBL

+ (void)load {
	[WindowBlurWindowHack poseAsClass:[NSWindow class]];
}

@end
