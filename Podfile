# Uncomment the next line to define a global platform for your project
platform :ios, '15.6'

target 'GrowIT' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GrowIT
  pod 'Then'
  pod 'SnapKit', '~> 5.7.0'
  pod 'Alamofire'
  pod 'KakaoSDKCommon'
  pod 'KakaoSDKAuth'
  pod 'KakaoSDKUser'
  pod 'lottie-ios'
  pod 'NVActivityIndicatorView'
  pod 'SwiftyToaster'
  pod 'Moya'
  pod 'EzPopup'
  pod 'Kingfisher', '8.2.0'
  pod 'DropDown'
end

# Modify build settings after installing pods
post_install do |installer|
  # Ensure iOS deployment target is consistent across all targets
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end

  # Remove problematic COMPILER_FLAGS from BoringSSL-GRPC
  installer.pods_project.targets.each do |target|
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
  end
end
