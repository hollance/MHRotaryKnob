
#import "DemoViewController.h"
#import "MHRotaryKnob.h"

@implementation DemoViewController

@synthesize slider, label, rotaryKnob;

- (void)viewDidLoad
{
	[super viewDidLoad];

	rotaryKnob.maximumValue = slider.maximumValue;
	rotaryKnob.minimumValue = slider.minimumValue;
	rotaryKnob.value = slider.value;
	rotaryKnob.defaultValue = rotaryKnob.value;
	rotaryKnob.resetsToDefault = YES;
	rotaryKnob.backgroundColor = [UIColor clearColor];
	rotaryKnob.backgroundImage = [UIImage imageNamed:@"Knob Background.png"];
	[rotaryKnob setKnobImage:[UIImage imageNamed:@"Knob.png"] forState:UIControlStateNormal];
	[rotaryKnob setKnobImage:[UIImage imageNamed:@"Knob Highlighted.png"] forState:UIControlStateHighlighted];
	[rotaryKnob setKnobImage:[UIImage imageNamed:@"Knob Disabled.png"] forState:UIControlStateDisabled];
	rotaryKnob.knobImageCenter = CGPointMake(80.0f, 76.0f);
	[rotaryKnob addTarget:self action:@selector(rotaryKnobDidChange) forControlEvents:UIControlEventValueChanged];
}

- (void)releaseObjects
{
	[slider release], slider = nil;
	[label release], label = nil;
	[rotaryKnob release], rotaryKnob = nil;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	[self releaseObjects];
}

- (void)dealloc
{
	[self releaseObjects];
	[super dealloc];
}

- (IBAction)sliderDidChange
{
	label.text = [NSString stringWithFormat:@"%.3f", slider.value];
	rotaryKnob.value = slider.value;
}

- (IBAction)rotaryKnobDidChange
{
	label.text = [NSString stringWithFormat:@"%.3f", rotaryKnob.value];
	slider.value = rotaryKnob.value;
}

- (IBAction)toggleEnabled
{
	rotaryKnob.enabled = !rotaryKnob.enabled;
}

- (IBAction)toggleContinuous
{
	slider.continuous = !slider.continuous;
	rotaryKnob.continuous = !rotaryKnob.continuous;
}

- (IBAction)goToMinimum
{
	[slider setValue:slider.minimumValue animated:YES];
	[rotaryKnob setValue:rotaryKnob.minimumValue animated:YES];
}

- (IBAction)goToMaximum
{
	[slider setValue:slider.maximumValue animated:YES];
	[rotaryKnob setValue:rotaryKnob.maximumValue animated:YES];
}

@end
