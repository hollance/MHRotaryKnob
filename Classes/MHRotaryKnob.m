
#import "MHRotaryKnob.h"

/*
	For our purposes, it's more convenient if we put 0 degrees at the top, 
	negative degrees to the left (the minimum is -MAX_ANGLE), and positive
	to the right (the maximum is +MAX_ANGLE).
 */

#define MAX_ANGLE 135.0f
#define MIN_DISTANCE_SQUARED 16.0f

@implementation MHRotaryKnob

@synthesize maximumValue, minimumValue, value;

- (float)angleForValue:(float)theValue
{
	return ((theValue - minimumValue)/(maximumValue - minimumValue) - 0.5f) * (MAX_ANGLE*2.0f);
}

- (float)valueForAngle:(float)theAngle
{
	return (theAngle/(MAX_ANGLE*2.0f) + 0.5f) * (maximumValue - minimumValue) + minimumValue;
}

- (float)angleBetweenCenterAndPoint:(CGPoint)point
{
	CGPoint center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);

	// Yes, the arguments to atan2() are in the wrong order. That's because our
	// coordinate system is turned upside down and rotated 90 degrees. :-)
	float theAngle = atan2(point.x - center.x, center.y - point.y) * 180.0f/M_PI;

	if (theAngle < -MAX_ANGLE)
		theAngle = -MAX_ANGLE;
	else if (theAngle > MAX_ANGLE)
		theAngle = MAX_ANGLE;

	return theAngle;
}

- (float)squaredDistanceToCenter:(CGPoint)point
{
	CGPoint center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
	float dx = point.x - center.x;
	float dy = point.y - center.y;
	return dx*dx + dy*dy;
}

- (void)setKnobRotationForValue:(float)theValue
{
	knobImageView.transform = CGAffineTransformMakeRotation([self angleForValue:theValue] * M_PI/180.0f);
}

- (void)valueDidChange
{
	// If you want to do custom drawing, then this is the place to do so.

	[self setKnobRotationForValue:value];
}

- (void)setUp
{
	minimumValue = 0.0f;
	maximumValue = 1.0f;
	value = 0.5f;
	angle = 0.0f;

	backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
	[self addSubview:backgroundImageView];

	knobImageView = [[UIImageView alloc] initWithFrame:self.bounds];
	[self addSubview:knobImageView];

	[self valueDidChange];
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self setUp];
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self setUp];
	}
	return self;
}

- (void)dealloc
{
	[knobImageView release];
	[backgroundImageView release];
	[super dealloc];
}

- (UIImage*)backgroundImage
{
	return backgroundImageView.image;
}

- (void)setBackgroundImage:(UIImage*)image
{
	backgroundImageView.image = image;
}

- (UIImage*)knobImage
{
	return knobImageView.image;
}

- (void)setKnobImage:(UIImage*)image
{
	knobImageView.image = image;
}

- (void)setValue:(float)newValue
{
	[self setValue:newValue animated:NO];
}

- (void)setValue:(float)newValue animated:(BOOL)animated
{
	if (newValue < minimumValue)
		value = minimumValue;
	else if (newValue > maximumValue)
		value = maximumValue;
	else
		value = newValue;

	if (animated)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationBeginsFromCurrentState:YES];
	}

	[self valueDidChange];

	if (animated)
	{
		[UIView commitAnimations];
	}
}

- (BOOL)beginTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint point = [touch locationInView:self];
	
	// If the touch is too close to the center, we can't calculate a decent
	// angle and the knob becomes too jumpy.
	if ([self squaredDistanceToCenter:point] < MIN_DISTANCE_SQUARED)
		return NO;

	// Calculate starting angle between touch and center of control.
	angle = [self angleBetweenCenterAndPoint:point];
	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint point = [touch locationInView:self];

	if ([self squaredDistanceToCenter:point] < MIN_DISTANCE_SQUARED)
		return YES;
	
	// Calculate how much the angle has changed since the last event.
	float newAngle = [self angleBetweenCenterAndPoint:point];
	float delta = newAngle - angle;
	angle = newAngle;

	// We don't want the knob to jump from minimum to maximum or vice versa
	// so disallow huge changes.
	if (fabsf(delta) > 45.0f)
		return YES;

	// Move the knob's value accordingly.
	self.value += (maximumValue - minimumValue) * delta / (MAX_ANGLE*2.0f);

	// Note that the above is equivalent to:
	//self.value += [self valueForAngle:newAngle] - [self valueForAngle:angle];

	[self sendActionsForControlEvents:UIControlEventValueChanged];
	return YES;
}

@end
