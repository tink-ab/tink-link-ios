Pod::Spec.new do |s|
  s.name     = 'TinkLink'
  s.version  = '0.10.0'
  s.license  = { :type => "MIT", :file => "LICENSE" }
  s.authors  = { 'Tink AB' => 'mobile@tink.se' }
  s.homepage = 'https://tink.com'
  s.summary = 'Tink Link SDK.'
  s.source = { :git => 'https://github.com/tink-ab/tink-link-ios.git' }

  s.ios.deployment_target = '11.0'

  s.source_files = "Sources/TinkLink/**/*.swift"
end
