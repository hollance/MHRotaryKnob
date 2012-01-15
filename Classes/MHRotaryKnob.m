
#import <QuartzCore/QuartzCore.h>
#import "MHRotaryKnob.h"

/*
	For our purposes, it's more convenient if we put 0 degrees at the top, 
	negative degrees to the left (the minimum is -MAX_ANGLE), and positive
	to the right (the maximum is +MAX_ANGLE).
 */

const float MAX_ANGLE = 135.0f;
const float MIN_DISTANCE_SQUARED = 16.0f;

@implementation MHRotaryKnob

@synthesize interactionStyle;
@synthesize maximumValue;
@synthesize minimumValue;
@synthesize value;
@synthesize continuous;
@synthesize defaultValue;
@synthesize resetsToDefault;
@synthesize scalingFactor;

- (float)clampAngle:(float)theAngle
{
	if (theAngle < -MAX_ANGLE)
		theAngle = -MAX_ANGLE;
	else if (theAngle > MAX_ANGLE)
		theAngle = MAX_ANGLE;

	return theAngle;
}

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

	return [self clampAngle:theAngle];
}

- (float)squaredDistanceToCenter:(CGPoint)point
{
	CGPoint center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
	float dx = point.x - center.x;
	float dy = point.y - center.y;
	return dx*dx + dy*dy;
}

- (float)valueForPosition:(CGPoint)point
{
	float delta;
	if (self.interactionStyle == MHRotaryKnobInteractionStyleSliderVertical)
		delta = touchOrigin.y - point.y;
	else
		delta = point.x - touchOrigin.x;

	float newAngle = delta*self.scalingFactor + angle;
	newAngle = [self clampAngle:newAngle];
	return [self valueForAngle:newAngle];
}

- (void)showNormalKnobImage
{
	knobImageView.image = knobImageNormal;
}

- (void)showHighlighedKnobImage
{
	if (knobImageHighlighted != nil)
		knobImageView.image = knobImageHighlighted;
	else
		knobImageView.image = knobImageNormal;
}

- (void)showDisabledKnobImage
{
	if (knobImageDisabled != nil)
		knobImageView.image = knobImageDisabled;
	else
		knobImageView.image = knobImageNormal;
}

- (void)valueDidChangeFrom:(float)oldValue to:(float)newValue animated:(BOOL)animated
{
	// (If you want to do custom drawing, then this is the place to do so.)

	float newAngle = [self angleForValue:newValue];

	if (animated)
	{
		// We cannot simply use UIView's animations because they will take the
		// shortest path, but we always want to go the long way around. So we
		// set up a keyframe animation with three keyframes: the old angle, the
		// midpoint between the old and new angles, and the new angle.

		float oldAngle = [self angleForValue:oldValue];

		CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
		animation.duration = 0.2f;

		animation.values = [NSArray arrayWithObjects:
			[NSNumber numberWithFloat:oldAngle * M_PI/180.0f],
			[NSNumber numberWithFloat:(newAngle + oldAngle)/2.0f * M_PI/180.0f], 
			[NSNumber numberWithFloat:newAngle * M_PI/180.0f],
			nil];

		animation.keyTimes = [NSArray arrayWithObjects:
			[NSNumber numberWithFloat:0.0f], 
			[NSNumber numberWithFloat:0.5f], 
			[NSNumber numberWithFloat:1.0f],
			nil]; 

		animation.timingFunctions = [NSArray arrayWithObjects:
			[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
			[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
			nil];

		[knobImageView.layer addAnimation:animation forKey:nil];
	}

	knobImageView.transform = CGAffineTransformMakeRotation(newAngle * M_PI/180.0f);
}

- (void)commonInit
{
	interactionStyle = MHRotaryKnobInteractionStyleRotating;
	minimumValue = 0.0f;
	maximumValue = 1.0f;
	value = defaultValue = 0.5f;
	angle = 0.0f;
	continuous = YES;
	resetsToDefault = YES;
	scalingFactor = 1.0f;

	knobImageView = [[UIImageView alloc] initWithFrame:self.bounds];
	[self addSubview:knobImageView];

	[self valueDidChangeFrom:value to:value animated:NO];
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self commonInit];
	}
	return self;
}

- (void)dealloc
{
	[foregroundImageView release];
	[knobImageView release];
	[backgroundImageView release];
	[knobImageNormal release];
	[knobImageHighlighted release];
	[knobImageDisabled release];
	[super dealloc];
}

- (UIImage*)backgroundImage
{
	return backgroundImageView.image;
}

- (void)setBackgroundImage:(UIImage*)image
{
	if (backgroundImageView == nil)
	{
		backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		[self addSubview:backgroundImageView];
		[self sendSubviewToBack:backgroundImageView];
	}

	backgroundImageView.image = image;
}

- (UIImage*)foregroundImage
{
	return foregroundImageView.image;
}

- (void)setForegroundImage:(UIImage*)image
{
	if (foregroundImageView == nil)
	{
		foregroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		[self addSubview:foregroundImageView];
		[self bringSubviewToFront:foregroundImageView];
	}

	foregroundImageView.image = image;
}

- (UIImage*)currentKnobImage
{
	return knobImageView.image;
}

- (void)setKnobImage:(UIImage*)image forState:(UIControlState)theState
{
	if (theState == UIControlStateNormal)
	{
		if (image != knobImageNormal)
		{
			[knobImageNormal release];
			knobImageNormal = [image retain];

			if (self.state == UIControlStateNormal)
			{
				knobImageView.image = image;
				[knobImageView sizeToFit];
			}
		}
	}

	if (theState & UIControlStateHighlighted)
	{
		if (image != knobImageHighlighted)
		{
			[knobImageHighlighted release];
			knobImageHighlighted = [image retain];

			if (self.state & UIControlStateHighlighted)
				knobImageView.image = image;
		}
	}

	if (theState & UIControlStateDisabled)
	{
		if (image != knobImageDisabled)
		{
			[knobImageDisabled release];
			knobImageDisabled = [image retain];

			if (self.state & UIControlStateDisabled)
				knobImageView.image = image;
		}
	}
}

- (UIImage*)knobImageForState:(UIControlState)theState
{
	if (theState == UIControlStateNormal)
		return knobImageNormal;
	else if (theState & UIControlStateHighlighted)
		return knobImageHighlighted;
	else if (theState & UIControlStateDisabled)
		return knobImageDisabled;
	else
		return nil;
}

- (CGPoint)knobImageCenter
{
	return knobImageView.center;
}

- (void)setKnobImageCenter:(CGPoint)theCenter
{
	knobImageView.center = theCenter;
}

- (void)setValue:(float)newValue
{
	[self setValue:newValue animated:NO];
}

- (void)setValue:(float)newValue animated:(BOOL)animated
{
	float oldValue = value;

	if (newValue < minimumValue)
		value = minimumValue;
	else if (newValue > maximumValue)
		value = maximumValue;
	else
		value = newValue;

	[self valueDidChangeFrom:(float)oldValue to:(float)value animated:animated];
}

- (void)setEnabled:(BOOL)isEnabled
{
	[super setEnabled:isEnabled];

	if (!self.enabled)
		[self showDisabledKnobImage];
	else if (self.highlighted)
		[self showHighlighedKnobImage];
	else
		[self showNormalKnobImage];
}

- (BOOL)beginTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint point = [touch locationInView:self];

	if (self.interactionStyle == MHRotaryKnobInteractionStyleRotating)
	{
		// If the touch is too close to the center, we can't calculate a decent
		// angle and the knob becomes too jumpy.
		if ([self squaredDistanceToCenter:point] < MIN_DISTANCE_SQUARED)
			return NO;

		// Calculate starting angle between touch and center of control.
		angle = [self angleBetweenCenterAndPoint:point];
	}
	else
	{
		touchOrigin = point;
		angle = [self angleForValue:value];
	}

	self.highlighted = YES;
	[self showHighlighedKnobImage];
	canReset = NO;
	
	return YES;
}

- (BOOL)handleTouch:(UITouch*)touch
{
	if (touch.tapCount > 1 && resetsToDefault && canReset)
	{
		[self setValue:defaultValue animated:YES];
		return NO;
	}

	CGPoint point = [touch locationInView:self];

	if (self.interactionStyle == MHRotaryKnobInteractionStyleRotating)
	{
		if ([self squaredDistanceToCenter:point] < MIN_DISTANCE_SQUARED)
			return NO;

		// Calculate how much the angle has changed since the last event.
		float newAngle = [self angleBetweenCenterAndPoint:point];
		float delta = newAngle - angle;
		angle = newAngle;

		// We don't want the knob to jump from minimum to maximum or vice versa
		// so disallow huge changes.
		if (fabsf(delta) > 45.0f)
			return NO;

		self.value += (maximumValue - minimumValue) * delta / (MAX_ANGLE*2.0f);

		// Note that the above is equivalent to:
		//self.value += [self valueForAngle:newAngle] - [self valueForAngle:angle];
	}
	else
	{
		self.value = [self valueForPosition:point];
	}

	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
	if ([self handleTouch:touch] && continuous)
		[self sendActionsForControlEvents:UIControlEventValueChanged];

	return YES;
}

- (void)endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
	self.highlighted = NO;
	[self showNormalKnobImage];

	// You can only reset the knob's position if you immediately stop dragging
	// the knob after double-tapping it, i.e. when tracking ends.
	canReset = YES;

	[self handleTouch:touch];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)cancelTrackingWithEvent:(UIEvent*)event
{
	self.highlighted = NO;
	[self showNormalKnobImage];
}

@end
