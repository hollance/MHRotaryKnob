# MHRotaryKnob

This is a UIControl that acts like a rotary knob. In operation it is similar to a UISlider but its shape is square rather than long and narrow.

## How to use

Copy MHRotaryKnob.h and MHRotaryKnob.m into your project. Add QuartzCore to your target's frameworks.

You have to provide the images for the knob and the background. The demo project includes a few basic images but you probably want to use graphics that suit your app's look-and-feel better. 

(The demo project also includes Knob.xcf, which is the source GIMP file that I used to draw the knob image.)

If you want to do more fancy drawing, then you can easily modify the class. Its `-valueDidChangeFrom:to:animated:` method is invoked whenever the value changes. In the default implementation it simply rotates the knob image. You can change or override this method to do custom drawing.
