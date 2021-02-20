
platform :ios, '12.0'

target 'ZomatoTestApp' do
    use_frameworks!
    
    pod 'ZomatoFoundation', :path => 'Other/ZomatoFoundation/ZomatoFoundation.podspec'
    pod 'ZomatoUIKit', :path => 'Other/ZomatoUIKit/ZomatoUIKit.podspec'
    pod 'Zomato', :path => 'Other/Zomato/Zomato.podspec'
    
    pod 'Kingfisher', '6.0.1'
    pod 'RxSwift', '6.1.0'
    pod 'RxCocoa', '6.1.0'

    target 'ZomatoTestAppTests' do
        inherit! :search_paths
        
        pod 'RxBlocking', '6.1.0'
        pod 'RxTest', '6.1.0'
    end

    target 'ZomatoTestAppUITests' do
        inherit! :search_paths
        
        pod 'RxBlocking', '6.1.0'
        pod 'RxTest', '6.1.0'
    end

end

post_install do |pi|
   pi.pods_project.targets.each do |t|
       t.build_configurations.each do |bc|
           bc.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
       end
   end
end
