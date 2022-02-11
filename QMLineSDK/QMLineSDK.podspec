#
# Be sure to run `pod lib lint QMLineDemo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QMLineSDK'
  s.version          = '4.0.1'
  s.summary          = 'QMLineSDK'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'A short description of QMLineSDK'

  s.homepage         = 'https://github.com/VE66/QMLineSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'VE66' => '942914231@qq.com' }
  s.source           = { :git => 'https://github.com/VE66/QMLineSDK.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'QMLineSDK/Classes/**/*'
  
   s.resource_bundles = {
     'QMLineSDK' => ['QMLineSDK/Assets/*.png']
   }

   s.public_header_files = 'QMLineSDK/Classes/Publics/*.h'
  
   s.dependency 'FMDB', '~> 2.7.5'
   s.dependency 'SocketRocket', '~> 0.6.0'
   s.dependency 'Qiniu', '~> 8.4.0'
   s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
