project 'Example/PubNubSwiftConsole'
workspace 'SwiftConsole'
use_frameworks!

target 'PubNubSwiftConsole_Example' do
  pod 'PubNubSwiftConsole', :path => '.'

  target 'PubNubSwiftConsole_Tests' do
    inherit! :search_paths

    
  end
end

target 'ObjCSample' do
  pod 'PubNubSwiftConsole', :path => '.'

  target 'ObjCSampleTests' do
    inherit! :search_paths

    
  end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
