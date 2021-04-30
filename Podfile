# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

post_install do |installer|
　 installer.pods_project.targets.each do |target|
　　 target.build_configurations.each do |config|
　　　 config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
　　 end
　 end
end

target 'Precord' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for Precord
  
  pod 'NCMB', :git => 'https://github.com/NIFTYCloud-mbaas/ncmb_ios.git', :branch => 'develop'
  pod 'PKHUD', '~> 5.0'
  #時間とか簡単に扱える
  pod 'SwiftDate', '~> 6.1'
  #画像の圧縮
  pod 'NYXImagesKit'
  #キーボードで隠れないようにする
  pod 'IQKeyboardManagerSwift', '6.3.0'
  pod 'RealmSwift'

end
