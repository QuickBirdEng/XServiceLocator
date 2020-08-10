Pod::Spec.new do |spec|
  spec.name         = 'XServiceLocator'
  spec.homepage     = 'https://github.com/quickbirdstudios/XServiceLocator'
  spec.version      = '1.0.0'
  spec.summary      = 'XServiceLocator is a light-weight library for dynamically providing objects with the dependencies they need.'
  spec.license      = { :type => 'MIT' }
  spec.author       = { 'Stefan Kofler' => 'stefan.kofler@quickbirdstudios.com', 'Mathias Quintero' => 'mathias.quintero@quickbirdstudios.com', 'Ghulam Nasir' => 'ghulam.nasir@quickbirdstudios.com' }
  spec.source       = { :git => 'https://github.com/quickbirdstudios/xservicelocator.git', :tag => spec.version }
  spec.source_files  = 'Sources/XServiceLocator/**/*.swift'
  spec.framework  = 'Foundation'
  spec.swift_version = '5.1'
  spec.ios.deployment_target = '8.0'
  spec.osx.deployment_target = '10.9'
end
