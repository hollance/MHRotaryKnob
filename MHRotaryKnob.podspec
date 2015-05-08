#
# Be sure to run `pod lib lint DSPaths.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MHRotaryKnob"
  s.version          = "0.1.0"
  s.summary          = "A UIControl that acts like a rotary knob."
  s.description      = <<-DESC
                        In operation it is similar to a `UISlider` but its shape is square rather than long and narrow.
                       DESC
  s.homepage         = "https://github.com/dannys42/MHRotaryKnob"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Matthijs Hollemans" => "" }
  s.source           = { :git => "https://github.com/dannys42/MHRotaryKnob.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'MHRotaryKnob/**/*'
  s.resource_bundles = {
    'DSPaths' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'MHRotaryKnob/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
