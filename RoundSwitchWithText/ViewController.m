//
//  ViewController.m
//  RoundSwitchWithText
//
//  Created by wenhua on 13-5-24.
//  Copyright (c) 2013年 wenhua. All rights reserved.
//

#import "ViewController.h"
#import "RCSwitchOnOff.h"

#define RGB(R,G,B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]

@interface ViewController ()

@end

@implementation ViewController

@synthesize roundSwitch;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	roundSwitch.onText.text       = @"当日有效";
	roundSwitch.offText.text      = @"永久有效";
	roundSwitch.onText.textColor  = RGB(62, 62, 62);
	roundSwitch.offText.textColor = RGB(62, 62, 62);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
	[roundSwitch release];
	[super dealloc];
}
@end
