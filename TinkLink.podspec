Pod::Spec.new do |spec|
    spec.name         = "TinkLink"
    spec.summary      = "Tink Link iOS SDK"
    spec.description  = <<-DESC
                      Optimise open banking experiences for mobile apps with Tink Link iOS SDK.
                      DESC
    spec.version      = "3.1.1"
    spec.license      = { :type => "MIT", :file => "LICENSE" }
    spec.authors      = { "Tink AB" => "mobile@tink.se" }
    spec.homepage     = "https://github.com/tink-ab/tink-link-ios"
    spec.source       = { :git => "https://github.com/tink-ab/tink-link-ios.git", :tag => spec.version }
  
    spec.ios.deployment_target = "13.0"

    spec.vendored_frameworks = "TinkLink.xcframework"

    spec.swift_version = ["5.9"]
  end
