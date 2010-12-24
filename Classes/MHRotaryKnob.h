
#import <UIKit/UIKit.h>

/*!
 * A rotary knob control.
 *
 * The control uses two images, one for the background and one for the knob. 
 * The background image is optional but you must set at least the knob image
 * before you can use the control. 
 * 
 * The knob image should have its position indicator at the top. This image is
 * rotated when the control's value changes, so it's best to make it perfectly
 * round.
 */
@interface MHRotaryKnob : UIControl
{
	UIImageView* backgroundImageView;  ///< shows the background image
	UIImageView* knobImageView;        ///< shows the knob image
	float angle;                       ///< for tracking touches
}

@property (nonatomic, retain) UIImage* knobImage;
@property (nonatomic, retain) UIImage* backgroundImage;

@property (nonatomic, assign) float maximumValue;
@property (nonatomic, assign) float minimumValue;
@property (nonatomic, assign) float value;

- (void)setValue:(float)value animated:(BOOL)animated;

@end
