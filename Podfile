platform :ios, '13.0'

target 'GrowIT' do
  use_frameworks!

  pod 'KakaoSDKCommon'
  pod 'KakaoSDKAuth'
  pod 'KakaoSDKUser'
  pod 'SwiftyToaster'
  pod 'EzPopup'
  pod 'DropDown'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
