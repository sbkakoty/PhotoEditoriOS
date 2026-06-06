post_install do |installer|
  puts 'Removing static analyzer support'
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['OTHER_CFLAGS'] = "$(inherited) -Qunused-arguments -Xanalyzer -analyzer-disable-all-checks"
    end
  end
 end
target 'PhotoEditorFilterEffects' do
  use_frameworks!
  pod 'Mantis', '~> 2.1.1'
  pod 'IQLabelView', :path => 'IQLabelView'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Alamofire'
end
