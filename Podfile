# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'weather-app' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for myWeather
  pod 'SwiftyJSON'
  pod 'Alamofire'
  pod 'SVProgressHUD', :git => 'https://github.com/SVProgressHUD/SVProgressHUD.git'

end

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
end
