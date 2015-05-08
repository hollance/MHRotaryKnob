
@interface DemoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *circularZoneSwitch;

- (IBAction)circularZoneChanged:(UISwitch *)sender;
@end
