
@class MHRotaryKnob;

@interface DemoViewController : UIViewController

@property (nonatomic, weak) IBOutlet UISlider *slider;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet MHRotaryKnob *rotaryKnob;

- (IBAction)sliderDidChange;
- (IBAction)rotaryKnobDidChange;
- (IBAction)toggleEnabled;
- (IBAction)toggleContinuous;
- (IBAction)goToMinimum;
- (IBAction)goToMaximum;
- (IBAction)toggleInteractionStyle:(id)sender;

@end
