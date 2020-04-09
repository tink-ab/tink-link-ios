Pod::Spec.new do |s|
  s.name     = 'TinkLinkUI'
  s.summary  = 'With TinkLinkUI you can connect to banks across Europe and easily access a wide range of financial data.'
  s.version  = '0.10.0'
  s.license  = { :type => "MIT", :file => "LICENSE" }
  s.authors  = { 'Tink AB' => 'mobile@tink.se' }
  s.homepage = 'https://tink.com'
  s.source = { :git => 'https://github.com/tink-ab/tink-link-ios.git' }

  s.ios.deployment_target = '11.0'

  s.source_files = "Sources/TinkLinkUI/**/*.swift"

  s.dependency "TinkLink"
  s.dependency "Down"
  s.dependency "Kingfisher"
end
