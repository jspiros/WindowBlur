//
//  WindowBlurWindowHack.m
//  WindowBlur
//
//  Created by Joseph Spiros on 5/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WindowBlurSIMBL.h"
#import "WindowBlurWindowHack.h"
#import "CGSInternal.h"

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

- (void)update {
	if ([[[self PRE__ivars] objectForKey:@"blurred"] boolValue] != YES) {
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
		if (floor(NSAppKitVersionNumber) > 824) {
			NSLog(@"AppKit Check Confirmed");
			CGSConnectionID con = CGSMainConnectionID();
			if (con) {
				NSLog(@"CGSConnection Confirmed");
				int blurFilter;
				if (noErr == CGSNewCIFilterByName(con, (CFStringRef)@"CIGaussianBlur", &blurFilter)) {
					NSLog(@"Should work!");
					NSDictionary *optionsDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:2.0] forKey:@"inputRadius"];
					CGSSetCIFilterValuesFromDictionary(con, blurFilter, (CFDictionaryRef)optionsDict);
					CGSAddWindowFilter(con, [self windowNumber], blurFilter, kCGWindowFilterUnderlay);
					[[self PRE__ivars] setObject:[NSNumber numberWithBool:YES] forKey:@"blurred"];
				}
			}			
		}
#endif
	}
}

@end
