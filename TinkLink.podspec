Pod::Spec.new do |spec|
  spec.name     = "TinkLink"
  spec.summary  = "With TinkLink you can connect to banks across Europe and easily access a wide range of financial data."
  spec.version  = "0.10.0"
  spec.license  = { :type => "MIT", :file => "LICENSE" }
  spec.authors  = { "Tink AB" => "mobile@tink.se" }
  spec.homepage = "https://tink.com"
  spec.source = { :git => "https://github.com/tink-ab/tink-link-ios.git", :tag => spec.version }

  spec.ios.deployment_target = "11.0"

  spec.source_files = "Sources/TinkLink/**/*.swift"
end
