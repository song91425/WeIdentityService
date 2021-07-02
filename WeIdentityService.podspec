#
# Be sure to run `pod lib lint WeIdentityService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WeIdentityService'
  s.version          = '0.2.0'
  s.summary          = 'A short description of WeIdentityService.'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://github.com/shoutanxie@gmail.com/WeIdentityService'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'shoutanxie@gmail.com' => 'shoutanxie@gmail.com' }
  s.source           = { :git => 'git@github.com:openchopstick/WeIdentityService.git',:branch => 'master'}
#  s.source           = { :git => 'git@github.com:openchopstick/WeIdentityService.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.ios.deployment_target = '9.0'
  s.subspec 'Base' do |base|

      base.source_files = 'WeIdentityService/Classes/Code/Base/**/*','WeIdentityService/Classes/Code/Suite/**/*'
      base.public_header_files ='WeIdentityService/Classes/Code/Base/**/*.h','WeIdentityService/Classes/Code/Suite/**/*.h'
      base.dependency 'AFNetworking','~> 4.0'
      base.dependency 'YYModel'
      base.dependency 'CocoaSecurity'
      base.dependency 'WCDB'
      base.library = "c++"
      base.compiler_flags = '-fno-modules'
  end
  
  s.subspec 'WI' do |wi|
      wi.source_files        = 'WeIdentityService/Classes/Code/WI/**/*'
      wi.public_header_files = 'WeIdentityService/Classes/Code/WI/**/*.h'
#      wi.resource_bundles = {
#          'WeIdentityService' => ['WeIdentityService/Assets/*.xcdatamodeld']
#      }
      wi.dependency 'WeIdentityService/Base'
      
      
      wi.subspec 'BinaryLib' do |bin|
        bin.vendored_libraries = 'WeIdentityService/Classes/Lib/WeID/**/*.a'
        bin.source_files       = 'WeIdentityService/Classes/Lib/WeID/**/*.h'
      end
      
      wi.library = 'c++'
      wi.pod_target_xcconfig = {
        'ENABLE_BITCODE' => 'NO'
      }
  end
  
  s.subspec 'Payment' do |payment|
      payment.dependency 'WeIdentityService/Base'
      payment.source_files = 'WeIdentityService/Classes/Code/Payment/**/*'
      payment.public_header_files = 'WeIdentityService/Classes/Code/Payment/**/*.h'
  end
  
  s.subspec 'Restoration' do |restoration|
      
      # restoration.dependency "Protobuf",' ~> 3.11.3'
      restoration.dependency "Protobuf"
      
      restoration.dependency 'WeIdentityService/Base'
      restoration.source_files = 'WeIdentityService/Classes/Code/Restoration/**/*'
      
      restoration.subspec 'BinaryLib' do |bin|
        bin.vendored_libraries = 'WeIdentityService/Classes/Lib/HDWallet/**/*.a'
        bin.source_files       = 'WeIdentityService/Classes/Lib/HDWallet/**/*.h'
      end
      
      restoration.library = 'c++'
      restoration.pod_target_xcconfig = {
        'ENABLE_BITCODE' => 'NO',
        'GCC_PREPROCESSOR_DEFINITIONS' =>
              'GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1 '
      }
  end
 
end


#pod package WeIdentityService.podspec --force --subspecs=Base,WI,Payment

#pod package WeIdentityService.podspec --force --subspecs=Base,WI,Payment --spec-sources='https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

