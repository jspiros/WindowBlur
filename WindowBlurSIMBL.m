//
//  WindowBlurSIMBL.m
//  WindowBlur
//
//  Created by Joseph Spiros on 5/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WindowBlurSIMBL.h"
#import "WindowBlurWindowHack.h"
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

@implementation WindowBlurSIMBL

+ (void)load {
	[WindowBlurWindowHack poseAsClass:[NSWindow class]];
}

@end
