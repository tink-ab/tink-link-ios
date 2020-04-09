Pod::Spec.new do |s|
  s.name     = 'TinkLink'
  s.summary  = 'With TinkLink you can connect to banks across Europe and easily access a wide range of financial data.'
  s.version  = '0.10.0'
  s.license  = { :type => "MIT", :file => "LICENSE" }
  s.authors  = { 'Tink AB' => 'mobile@tink.se' }
  s.homepage = 'https://tink.com'
  s.source = { :git => 'https://github.com/tink-ab/tink-link-ios.git' }

  s.ios.deployment_target = '11.0'

  s.source_files = "Sources/TinkLink/**/*.swift"
end
