/*!
 * \file MHRotaryKnob.h
 *
 * \brief UIControl subclass that acts like a rotary knob.
 *
 * Copyright (c) 2010-2012 Matthijs Hollemans
 *
 * With contributions from Tim Kemp (slider-style tracking).
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <UIKit/UIKit.h>

/*!
 * Possible values for the rotary knob's interactionStyle property.
 */
typedef enum
{
	MHRotaryKnobInteractionStyleRotating,
	MHRotaryKnobInteractionStyleSliderHorizontal,  // left -, right +
	MHRotaryKnobInteractionStyleSliderVertical     // up +, down -
}
MHRotaryKnobInteractionStyle;

/*!
 * A rotary knob control.
 *
 * Operation of this control is similar to a UISlider. You can set a minimum,
 * maximum, and current value. When the knob is turned the control sends out
 * a \c UIControlEventValueChanged notification to its target-action.
 *
 * The \c interactionStyle property determines the way the control is operated.
 * It can be configured to act like a knob that must be turned, or to act like
 * a horizontal or vertical slider.
 *
 * The control uses two images, one for the background and one for the knob. 
 * The background image is optional but you must set at least the knob image
 * before you can use the control.
 *
 * When double-tapped, the control resets to its default value, typically the
 * the center or minimum position. This feature can be disabled with the \c
 * resetsToDefault property.
 *
 * Because users will want to see what happens under their fingers, you are 
 * advised not to make the knob smaller than 120x120 points. Because of this, 
 * rotary knob controls probably work best on an iPad.
 *
 * This class needs the QuartzCore framework.
 *
 * \author Matthijs Hollemans <mail@hollance.com>
 */
@interface MHRotaryKnob : UIControl
{
	UIImageView* backgroundImageView;  ///< shows the background image
	UIImageView* foregroundImageView;  ///< shows the foreground image
	UIImageView* knobImageView;        ///< shows the knob image
	UIImage* knobImageNormal;          ///< knob image for normal state
	UIImage* knobImageHighlighted;     ///< knob image for highlighted state
	UIImage* knobImageDisabled;        ///< knob image for disabled state
	float angle;                       ///< for tracking touches
	CGPoint touchOrigin;               ///< for horizontal/vertical tracking
	BOOL canReset;                     ///< prevents reset while still dragging
}

/*! How the user interacts with the control. */
@property (nonatomic, assign) MHRotaryKnobInteractionStyle interactionStyle;

/*! The image that is drawn behind the knob. May be nil. */
@property (nonatomic, retain) UIImage* backgroundImage;

/*!
 * The image that is drawn on top of the knob. May be nil. This is useful
 * for partially transparent overlays to make shadow or highlight effects.
 */
@property (nonatomic, strong) UIImage* foregroundImage;

/*! The image currently being used to draw the knob. */
@property (nonatomic, retain, readonly) UIImage* currentKnobImage;

/*! For positioning the knob image. */
@property (nonatomic, assign) CGPoint knobImageCenter;

/*! The maximum value of the control. Default is 1.0f. */
@property (nonatomic, assign) float maximumValue;

/*! The minimum value of the control. Default is 0.0f. */
@property (nonatomic, assign) float minimumValue;

/*! The control's current value. Default is 0.5f (center position). */
@property (nonatomic, assign) float value;

/*! The control's default value. Default is 0.5f (center position). */
@property (nonatomic, assign) float defaultValue;

/*!
 * Whether the control resets to the default value on a double tap.
 * Default is YES.
 */
@property (nonatomic, assign) BOOL resetsToDefault;

/*!
 * Whether changes in the knob's value generate continuous update events. 
 * If NO, the control only sends an action event when the user releases the 
 * knob. The default is YES.
 */
@property (nonatomic, assign) BOOL continuous;

/*!
 * How many points of movement result in a one degree rotation in the knob's
 * position. Only used in the horizontal/vertical slider modes. Default is 1.
 */
@property (nonatomic, assign) float scalingFactor;

/*!
 * Sets the controls’s current value, allowing you to animate the change
 * visually.
 */
- (void)setValue:(float)value animated:(BOOL)animated;

/*!
 * Assigns a knob image to the specified control states.
 * 
 * This image should have its position indicator at the top. The knob image is
 * rotated when the control's value changes, so it's best to make it perfectly
 * round.
 */
- (void)setKnobImage:(UIImage*)image forState:(UIControlState)state;

/*!
 * Returns the thumb image associated with the specified control state.
 */
- (UIImage*)knobImageForState:(UIControlState)state;

@end
