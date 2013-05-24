/*
 Copyright (c) 2010 Robert Chin
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "RCSwitchOnOff.h"


@implementation RCSwitchOnOff
@synthesize onText;
@synthesize offText;

- (void) initCommon
{
	[super initCommon];
	
	onText = [UILabel new];
	onText.text = @"On";
	onText.textColor = [UIColor blackColor];
	onText.font = [UIFont systemFontOfSize:15];
	//onText.shadowColor = [UIColor colorWithWhite:0.175 alpha:1.0];
	onText.textAlignment = UITextAlignmentCenter;
	onText.adjustsFontSizeToFitWidth = YES;
	onText.minimumFontSize = 10.0;
	
	offText = [UILabel new];
	offText.text = @"Off";
	offText.textColor = [UIColor blackColor];
	offText.font = [UIFont systemFontOfSize:15];
	offText.textAlignment = UITextAlignmentCenter;
	offText.adjustsFontSizeToFitWidth = YES;
	offText.minimumFontSize = 10.0;
}

- (void) dealloc
{
	[onText release];
	[offText release];
	[super dealloc];
}

- (void) drawUnderlayersInRect:(CGRect)aRect withOffset:(float)offset inTrackWidth:(float)trackWidth
{
	{
		CGRect textRect = aRect;
		textRect.origin.x += 6.0 + (offset - trackWidth);
		textRect.size.width = trackWidth - 6.0;
		[onText drawTextInRect:textRect];
	}
	
	{
		CGRect textRect = aRect;
		textRect.origin.x += knobWidth + offset + 3.0;
		textRect.size.width = trackWidth - 9.0;
		[offText drawTextInRect:textRect];
	}
}

@end
