//
//  WindowBlurSIMBL.h
//  WindowBlur
//
//  Created by Joseph Spiros on 5/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

void MethodSwizzle(Class aClass, SEL orig_sel, SEL alt_sel);

@interface WindowBlurWindowHack : NSWindow
@end

@interface WindowBlurSIMBL : NSObject {}
@end