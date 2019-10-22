Pod::Spec.new do |s|
  s.name             = 'iOSCommon'
  s.version          = '0.4.0'
  s.swift_version    = '4.2'
  s.summary          = 'A library which stores common codes used for iOS App development'
  s.description      = <<-DESC
This a library which stores some common functionalities used for iOS app development
                       DESC
  s.homepage         = 'https://github.com/ricol/iOSCommon'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ricol Wang' => 'ricol@opensimsim.com' }
  s.source           = { :git => 'https://github.com/ricol/iOSCommon.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'iOSCommon/Classes/**/*'
  # s.resource_bundles = {
  #   'iOSCommon' => ['iOSCommon/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
