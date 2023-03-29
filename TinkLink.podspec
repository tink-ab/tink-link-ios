Pod::Spec.new do |spec|
    spec.name         = "TinkLink"
    spec.summary      = "Tink Link iOS SDK"
    spec.description  = <<-DESC
                      With TinkLink you can connect to banks across Europe and easily access a wide range of financial data.
                      DESC
    spec.version      = "2.0.0"
    spec.license      = { :type => "MIT", :file => "LICENSE" }
    spec.authors      = { "Tink AB" => "mobile@tink.se" }
    spec.homepage     = "https://github.com/tink-ab/tink-link-ios"
    spec.source       = { :git => "https://github.com/tink-ab/tink-link-ios.git", :tag => spec.version }
  
    spec.ios.deployment_target = "13.0"

    spec.vendored_frameworks = "TinkLink.xcframework"

    spec.swift_version = ["5.1", "5.2", "5.3", "5.4", "5.5", "5.6", "5.7"]
  end
