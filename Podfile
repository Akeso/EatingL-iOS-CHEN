# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!

def shared_pods
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'ReachabilitySwift'
  pod 'SnapKit'
  pod 'SmartCodable'
  pod 'SmartCodable/Inherit'
  pod 'Disk'
  pod 'SDWebImage'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'RxGesture'
  pod 'Toast-Swift'
  pod 'lottie-ios'
  pod 'MJRefresh'
  pod 'SwiftDate'
  pod 'Masonry'
  pod 'iCarousel'
  pod 'PINCache', :git => 'https://github.com/SecretLisa/PINCache.git'

  pod 'ThinkingSDK'

  pod 'LookinServer', :subspecs => ['Swift'], :configurations => ['Debug']
end

abstract_target 'pod-libs' do
  shared_pods
  target 'EatingL-iOS'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
