#
# Be sure to run `pod lib lint QMLineUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QMLineUI'
  s.version          = '0.1.0'
  s.summary          = 'QMLineUI 界面'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "QMLineSDK UI 界面"

  s.homepage         = 'https://github.com/VE66/QMLineUI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'VE66' => '942914231@qq.com' }
  s.source           = { :git => 'https://github.com/VE66/QMLineUI.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'QMLineUI/Classes/**/*'
  
   s.resource_bundles = {
     'QMLineUIBundle' => ['QMLineUI/Assets/*.png']
   }

#   s.public_header_files = 'QMLineUI/Classes/**/*.h'
   s.frameworks = 'UIKit'
   s.dependency 'SDWebImage', '~> 5.11.1'
   s.dependency 'JSONModel', '~> 1.8.0'
   s.dependency 'Masonry', '~> 1.1.0'
   s.dependency 'MJRefresh', '~> 3.7.5'
   s.dependency 'QMLineSDK'
      s.static_framework = true
   s.dependency 'libmp3lame', '~> 3.99.5'
   
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
