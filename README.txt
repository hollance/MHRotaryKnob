MHRotaryKnob

This is a UIControl that acts like a rotary knob. In operation it is similar to 
a UISlider but it takes up less space on the screen (at least horizontally).

You have to provide the images for the knob and the background. The demo project
includes a few basic images but you probably want to use graphics that suit your
app's look-and-feel better.

If you want to do more fancy drawing, then you can easily modify the class. Its
-valueDidChange method is invoked whenever the value changes. In the default
implementation it simply rotates the knob image. You can change or override this
method to do custom drawing.
