
@class MHRotaryKnob;

@interface DemoViewController : UIViewController

@property (nonatomic, retain) IBOutlet UISlider* slider;
@property (nonatomic, retain) IBOutlet UILabel* label;
@property (nonatomic, retain) IBOutlet MHRotaryKnob* rotaryKnob;

- (IBAction)sliderDidChange;
- (IBAction)rotaryKnobDidChange;
- (IBAction)toggleEnabled;
- (IBAction)toggleContinuous;
- (IBAction)goToMinimum;
- (IBAction)goToMaximum;
- (IBAction)toggleInteractionStyle:(id)sender;

@end
