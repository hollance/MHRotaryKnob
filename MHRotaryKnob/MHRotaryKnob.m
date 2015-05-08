
#import <QuartzCore/QuartzCore.h>
#import "MHRotaryKnob.h"

/*
	For our purposes, it's more convenient if we put 0 degrees at the top, 
	negative degrees to the left (the minimum is -self.maxAngle), and positive
	to the right (the maximum is +self.maxAngle).
 */

@implementation MHRotaryKnob
{
	UIImageView *_backgroundImageView;  // shows the background image
	UIImageView *_foregroundImageView;  // shows the foreground image
	UIImageView *_knobImageView;        // shows the knob image
	UIImage *_knobImageNormal;          // knob image for normal state
	UIImage *_knobImageHighlighted;     // knob image for highlighted state
	UIImage *_knobImageDisabled;        // knob image for disabled state
	CGFloat _angle;                     // for tracking touches
	CGPoint _touchOrigin;               // for horizontal/vertical tracking
	BOOL _canReset;                     // prevents reset while still dragging
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	_interactionStyle = MHRotaryKnobInteractionStyleRotating;
	_minimumValue = 0.0;
	_maximumValue = 1.0;
	_value = _defaultValue = 0.5;
	_angle = 0.0;
	_continuous = YES;
	_resetsToDefault = YES;
	_scalingFactor = 1.0;
	_maxAngle = 135.0;
	_minRequiredDistanceFromKnobCenter = 4.0;

	_knobImageView = [[UIImageView alloc] initWithFrame:self.bounds];
	[self addSubview:_knobImageView];

	[self valueDidChangeFrom:_value to:_value animated:NO];
}

#pragma mark - Data Model

- (CGFloat)clampAngle:(CGFloat)angle
{
	if (angle < -self.maxAngle)
		return -self.maxAngle;
	else if (angle > self.maxAngle)
		return self.maxAngle;
	else
		return angle;
}

- (CGFloat)angleForValue:(CGFloat)value
{
	return ((value - self.minimumValue)/(self.maximumValue - self.minimumValue) - 0.5) * (self.maxAngle*2.0);
}

- (CGFloat)valueForAngle:(CGFloat)angle
{
	return (angle/(self.maxAngle*2.0) + 0.5) * (self.maximumValue - self.minimumValue) + self.minimumValue;
}

- (CGFloat)angleBetweenCenterAndPoint:(CGPoint)point
{
	CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

	// Yes, the arguments to atan2() are in the wrong order. That's because
	// our coordinate system is turned upside down and rotated 90 degrees.
	CGFloat angle = atan2(point.x - center.x, center.y - point.y) * 180.0/M_PI;

	return [self clampAngle:angle];
}

- (CGFloat)squaredDistanceToCenter:(CGPoint)point
{
	CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
	CGFloat dx = point.x - center.x;
	CGFloat dy = point.y - center.y;
	return dx*dx + dy*dy;
}

- (BOOL)shouldIgnoreTouchAtPoint:(CGPoint)point
{
	CGFloat minDistanceSquared = self.minRequiredDistanceFromKnobCenter*self.minRequiredDistanceFromKnobCenter;
    if( _circularTouchZone ) {
        CGFloat distanceToCenter = [self squaredDistanceToCenter:point];
        if (distanceToCenter < minDistanceSquared)
            return YES;
        
        CGFloat maxDistanceSquared = MIN(self.bounds.size.width, self.bounds.size.height) / 2.0f;
        maxDistanceSquared *= maxDistanceSquared;
        if( distanceToCenter > maxDistanceSquared ) {
            return YES;
        }
    } else {
      if( [self squaredDistanceToCenter:point] < minDistanceSquared )
          return YES;
    }
    return NO;
}

- (CGFloat)valueForPosition:(CGPoint)point
{
	CGFloat delta;
	if (self.interactionStyle == MHRotaryKnobInteractionStyleSliderVertical)
		delta = _touchOrigin.y - point.y;
	else
		delta = point.x - _touchOrigin.x;

	CGFloat newAngle = delta * self.scalingFactor + _angle;
	newAngle = [self clampAngle:newAngle];
	return [self valueForAngle:newAngle];
}

- (void)setValue:(CGFloat)newValue
{
	[self setValue:newValue animated:NO];
}

- (void)setValue:(CGFloat)newValue animated:(BOOL)animated
{
	CGFloat oldValue = _value;

	if (newValue < self.minimumValue)
		_value = self.minimumValue;
	else if (newValue > self.maximumValue)
		_value = self.maximumValue;
	else
		_value = newValue;

	[self valueDidChangeFrom:oldValue to:_value animated:animated];
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

#pragma mark - Touch Handling

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint point = [touch locationInView:self];

	if (self.interactionStyle == MHRotaryKnobInteractionStyleRotating)
	{
		// If the touch is too close to the center, we can't calculate a decent
		// angle and the knob becomes too jumpy.
		if ([self shouldIgnoreTouchAtPoint:point])
			return NO;

		// Calculate starting angle between touch and center of control.
		_angle = [self angleBetweenCenterAndPoint:point];
	}
	else
	{
		_touchOrigin = point;
		_angle = [self angleForValue:self.value];
	}

	self.highlighted = YES;
	[self showHighlighedKnobImage];
	_canReset = NO;
	
	return YES;
}

- (BOOL)handleTouch:(UITouch *)touch
{
	if (touch.tapCount > 1 && self.resetsToDefault && _canReset)
	{
		[self setValue:self.defaultValue animated:YES];
		return NO;
	}

	CGPoint point = [touch locationInView:self];

	if (self.interactionStyle == MHRotaryKnobInteractionStyleRotating)
	{
		if ([self shouldIgnoreTouchAtPoint:point])
			return NO;

		// Calculate how much the angle has changed since the last event.
		CGFloat newAngle = [self angleBetweenCenterAndPoint:point];
		CGFloat delta = newAngle - _angle;
		_angle = newAngle;

		// We don't want the knob to jump from minimum to maximum or vice versa
		// so disallow huge changes.
		if (fabs(delta) > 45.0)
			return NO;

		self.value += (self.maximumValue - self.minimumValue) * delta / (self.maxAngle*2.0);

		// Note that the above is equivalent to:
		//self.value += [self valueForAngle:newAngle] - [self valueForAngle:angle];
	}
	else
	{
		self.value = [self valueForPosition:point];
	}

	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ([self handleTouch:touch] && self.continuous)
		[self sendActionsForControlEvents:UIControlEventValueChanged];

	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	self.highlighted = NO;
	[self showNormalKnobImage];

	// You can only reset the knob's position if you immediately stop dragging
	// the knob after double-tapping it, i.e. when tracking ends.
	_canReset = YES;

	[self handleTouch:touch];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
	self.highlighted = NO;
	[self showNormalKnobImage];
}

#pragma mark - Visuals

- (void)valueDidChangeFrom:(CGFloat)oldValue to:(CGFloat)newValue animated:(BOOL)animated
{
	// (If you want to do custom drawing, then this is the place to do so.)

	CGFloat newAngle = [self angleForValue:newValue];

	if (animated)
	{
		// We cannot simply use UIView's animations because they will take the
		// shortest path, but we always want to go the long way around. So we
		// set up a keyframe animation with three keyframes: the old angle, the
		// midpoint between the old and new angles, and the new angle.

		CGFloat oldAngle = [self angleForValue:oldValue];

		CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
		animation.duration = 0.2;

		animation.values = @[
			@(oldAngle * M_PI/180.0),
			@((newAngle + oldAngle)/2.0 * M_PI/180.0),
			@(newAngle * M_PI/180.0)];

		animation.keyTimes = @[@0.0, @0.5, @1.0];

		animation.timingFunctions = @[
			[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
			[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];

		[_knobImageView.layer addAnimation:animation forKey:nil];
	}

	_knobImageView.transform = CGAffineTransformMakeRotation(newAngle * M_PI/180.0);
}

- (void)setBackgroundImage:(UIImage *)image
{
	if (_backgroundImageView == nil)
	{
		_backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		[self addSubview:_backgroundImageView];
		[self sendSubviewToBack:_backgroundImageView];
	}

	_backgroundImageView.image = image;
}

- (UIImage *)backgroundImage
{
	return _backgroundImageView.image;
}

- (void)setForegroundImage:(UIImage *)image
{
	if (_foregroundImageView == nil)
	{
		_foregroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		[self addSubview:_foregroundImageView];
		[self bringSubviewToFront:_foregroundImageView];
	}

	_foregroundImageView.image = image;
}

- (UIImage *)foregroundImage
{
	return _foregroundImageView.image;
}

- (void)setKnobImage:(UIImage *)image forState:(UIControlState)theState
{
	if (theState == UIControlStateNormal)
	{
		if (image != _knobImageNormal)
		{
			_knobImageNormal = image;

			if (self.state == UIControlStateNormal)
			{
				_knobImageView.image = image;
				[_knobImageView sizeToFit];
			}
		}
	}

	if (theState & UIControlStateHighlighted)
	{
		if (image != _knobImageHighlighted)
		{
			_knobImageHighlighted = image;

			if (self.state & UIControlStateHighlighted)
				_knobImageView.image = image;
		}
	}

	if (theState & UIControlStateDisabled)
	{
		if (image != _knobImageDisabled)
		{
			_knobImageDisabled = image;

			if (self.state & UIControlStateDisabled)
				_knobImageView.image = image;
		}
	}
}

- (UIImage *)knobImageForState:(UIControlState)theState
{
	if (theState == UIControlStateNormal)
		return _knobImageNormal;
	else if (theState & UIControlStateHighlighted)
		return _knobImageHighlighted;
	else if (theState & UIControlStateDisabled)
		return _knobImageDisabled;
	else
		return nil;
}

- (void)setKnobImageCenter:(CGPoint)theCenter
{
	_knobImageView.center = theCenter;
}

- (CGPoint)knobImageCenter
{
	return _knobImageView.center;
}

- (void)showNormalKnobImage
{
	_knobImageView.image = _knobImageNormal;
}

- (void)showHighlighedKnobImage
{
	if (_knobImageHighlighted != nil)
		_knobImageView.image = _knobImageHighlighted;
	else
		_knobImageView.image = _knobImageNormal;
}

- (void)showDisabledKnobImage
{
	if (_knobImageDisabled != nil)
		_knobImageView.image = _knobImageDisabled;
	else
		_knobImageView.image = _knobImageNormal;
}

- (UIImage *)currentKnobImage
{
	return _knobImageView.image;
}

@end
