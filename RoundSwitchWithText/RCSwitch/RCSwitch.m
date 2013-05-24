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

#import "RCSwitch.h"
#import <QuartzCore/QuartzCore.h>

@interface RCSwitch ()
- (void) regenerateImages;
- (void) performSwitchToPercent:(float)toPercent;
@end

@implementation RCSwitch

- (void) initCommon
{
    drawHeight = 31;
	/* It seems that the animation length was changed in iOS 4.0 to animate the switch slower. */
	if(kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_4_0){
		animationDuration = 0.25;
	} else {
		animationDuration = 0.175;
	}
	self.contentMode = UIViewContentModeRedraw;
	[self setKnobWidth:26];
	[self regenerateImages];
	sliderOff = [[[UIImage imageNamed:@"btn_slider_off.png"] stretchableImageWithLeftCapWidth:12.0
																				 topCapHeight:0.0] retain];
	if([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
		scale = [[UIScreen mainScreen] scale];
	else
		scale = 1.0;
	self.opaque = NO;
	MARGIN = 2;
}

- (id)initWithFrame:(CGRect)aRect
{
	if((self = [super initWithFrame:aRect])){
		[self initCommon];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super initWithCoder:aDecoder])){
		[self initCommon];
		percent = 1.0;
	}
	return self;
}

- (void) dealloc
{
	[knobImage release];
	[knobImagePressed release];
	[sliderOn release];
	[sliderOff release];
	[super dealloc];
}

- (void) setKnobWidth:(float)aFloat
{
	knobWidth = roundf(aFloat); // whole pixels only
	endcapWidth = roundf(knobWidth / 2.0);
	knobImage = [[UIImage imageNamed:@"btn_slider_thumb.png"] retain];
	knobImagePressed = [[UIImage imageNamed:@"btn_slider_thumb_pressed.png"] retain];
}

- (float)knobWidth
{
	return knobWidth;
}

- (void) regenerateImages
{
	CGRect boundsRect = self.bounds;
	UIImage *sliderOnBase = [[UIImage imageNamed:@"btn_slider_on.png"] stretchableImageWithLeftCapWidth:12.0
																						   topCapHeight:0.0];
	CGRect sliderOnRect = boundsRect;
	sliderOnRect.size.height = [sliderOnBase size].height;
	if(UIGraphicsBeginImageContextWithOptions != NULL)
		UIGraphicsBeginImageContextWithOptions(sliderOnRect.size, NO, scale);
	else
		UIGraphicsBeginImageContext(sliderOnRect.size);
	[sliderOnBase drawInRect:sliderOnRect];
	[sliderOn release];
	sliderOn = [UIGraphicsGetImageFromCurrentImageContext() retain];
	UIGraphicsEndImageContext();
}

- (void) drawUnderlayersInRect:(CGRect)aRect withOffset:(float)offset inTrackWidth:(float)trackWidth
{
}

- (void) drawRect:(CGRect)rect
{
	CGRect boundsRect = self.bounds;
    boundsRect.size.height = drawHeight;
	if(!CGSizeEqualToSize(boundsRect.size, lastBoundsSize)){
		[self regenerateImages];
		lastBoundsSize = boundsRect.size;
	}
	
	float width = boundsRect.size.width;
	float drawPercent = percent;
	if(((width - knobWidth) * drawPercent) < 3+MARGIN)
		drawPercent = 0.0;
	if(((width - knobWidth) * drawPercent) > (width - knobWidth - 3-MARGIN))
		drawPercent = 1.0;
	
	if(endDate){
		NSTimeInterval interval = [endDate timeIntervalSinceNow];
		if(interval < 0.0){
			[endDate release];
			endDate = nil;
		} else {
			if(percent == 1.0)
				drawPercent = cosf((interval / animationDuration) * (M_PI / 2.0));
			else
				drawPercent = 1.0 - cosf((interval / animationDuration) * (M_PI / 2.0));
			[self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0.0];
		}
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	{
		CGContextSaveGState(context);
		UIGraphicsPushContext(context);
		/*
		if(drawPercent == 0.0){
			CGRect insetClipRect = boundsRect;
			insetClipRect.origin.x += endcapWidth;
			insetClipRect.size.width -= endcapWidth;
			UIRectClip(insetClipRect);
		}
		
		if(drawPercent == 1.0){
			CGRect insetClipRect = boundsRect;
			insetClipRect.size.width -= endcapWidth;
			UIRectClip(insetClipRect);
		}
		*/
		{
			CGRect sliderOffRect = boundsRect;
			sliderOffRect.size.height = [sliderOff size].height;
			[sliderOff drawInRect:sliderOffRect];
		}
		
		if(drawPercent > 0.0){		
			float onWidth = knobWidth / 2 + ((width - knobWidth / 2) - knobWidth / 2) * drawPercent;
			CGRect sourceRect = CGRectMake(0, 0, onWidth * scale, [sliderOn size].height * scale);
			CGRect drawOnRect = CGRectMake(0, 0, onWidth, [sliderOn size].height);
			CGImageRef sliderOnSubImage = CGImageCreateWithImageInRect([sliderOn CGImage], sourceRect);
			CGContextSaveGState(context);
			CGContextScaleCTM(context, 1.0, -1.0);
			CGContextTranslateCTM(context, 0.0, -drawOnRect.size.height);	
			CGContextDrawImage(context, drawOnRect, sliderOnSubImage);
			CGContextRestoreGState(context);
            
			CGImageRelease(sliderOnSubImage);
		}
		
		{
			CGContextSaveGState(context);
			UIGraphicsPushContext(context);
			CGRect insetClipRect = CGRectInset(boundsRect, 4, 4);
			
			UIRectClip(insetClipRect);
						
			[self drawUnderlayersInRect:rect
							 withOffset:drawPercent * (boundsRect.size.width - knobWidth-MARGIN)
						   inTrackWidth:(boundsRect.size.width - knobWidth-2*MARGIN)];
			UIGraphicsPopContext();
			CGContextRestoreGState(context);
		}
		
		{
			CGContextScaleCTM(context, 1.0, -1.0);
			CGContextTranslateCTM(context, 0.0, -boundsRect.size.height);
			CGPoint location = boundsRect.origin;
			UIImage *imageToDraw = knobImage;
			if(self.highlighted)
				imageToDraw = knobImagePressed;
			
			CGRect drawOnRect = CGRectMake(location.x + roundf(drawPercent * (boundsRect.size.width - knobWidth)),
										   location.y + 2, knobWidth, [knobImage size].height);
			// add
			if(drawPercent == 0.0 ){
				drawOnRect = CGRectOffset(drawOnRect, MARGIN, 0);
			}
			else if (drawPercent == 1.0) {
				drawOnRect = CGRectOffset(drawOnRect, -MARGIN, 0);
			}
			else {
				drawOnRect.origin.x = MAX(MARGIN, drawOnRect.origin.x);
				drawOnRect.origin.x = MIN(boundsRect.size.width-MARGIN-knobWidth, drawOnRect.origin.x);
			}
			// end
			CGContextDrawImage(context, drawOnRect, [imageToDraw CGImage]);
		}
		UIGraphicsPopContext();
		CGContextRestoreGState(context);
	}
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	self.highlighted = YES;
	oldPercent = percent;
	[endDate release];
	endDate = nil;
	mustFlip = YES;
	[self setNeedsDisplay];
	[self sendActionsForControlEvents:UIControlEventTouchDown];
	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint point = [touch locationInView:self];
	percent = (point.x - knobWidth / 2.0) / (self.bounds.size.width - knobWidth-2*MARGIN);
	if(percent < 0.0)
		percent = 0.0;
	if(percent > 1.0)
		percent = 1.0;
	if((oldPercent < 0.25 && percent > 0.5) || (oldPercent > 0.75 && percent < 0.5))
		mustFlip = NO;
	[self setNeedsDisplay];
	[self sendActionsForControlEvents:UIControlEventTouchDragInside];
	return YES;
}

- (void) finishEvent
{
	self.highlighted = NO;
	[endDate release];
	endDate = nil;
	float toPercent = roundf(1.0 - oldPercent);
	if(!mustFlip){
		if(oldPercent < 0.25){
			if(percent > 0.5)
				toPercent = 1.0;
			else
				toPercent = 0.0;
		}
		if(oldPercent > 0.75){
			if(percent < 0.5)
				toPercent = 0.0;
			else
				toPercent = 1.0;
		}
	}
	[self performSwitchToPercent:toPercent];
}

- (void) cancelTrackingWithEvent:(UIEvent *)event
{
	[self finishEvent];
}

- (void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self finishEvent];
}

- (BOOL)isOn
{
	return percent > 0.5;
}

- (void) setOn:(BOOL)aBool
{
	[self setOn:aBool animated:NO];
}

- (void) setOn:(BOOL)aBool animated:(BOOL)animated
{
	if(animated){
		float toPercent = aBool ? 1.0 : 0.0;
		if((percent < 0.5 && aBool) || (percent > 0.5 && !aBool))
			[self performSwitchToPercent:toPercent];
	} else {
		percent = aBool ? 1.0 : 0.0;
		[self setNeedsDisplay];
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
}

- (void) performSwitchToPercent:(float)toPercent
{
	[endDate release];
	endDate = [[NSDate dateWithTimeIntervalSinceNow:fabsf(percent - toPercent) * animationDuration] retain];
	percent = toPercent;
	[self setNeedsDisplay];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	[self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end
