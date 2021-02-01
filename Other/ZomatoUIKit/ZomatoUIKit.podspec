
Pod::Spec.new do |s|

  s.name          = "ZomatoUIKit"
  s.version       = "0.0.1"
  s.summary       = "Zomato utils for UIKit"
  s.description   = "Zomato utils for UIKit"
  s.homepage      = "https://github.com/rexcosta"
  s.author        = { "david" => "https://github.com/rexcosta" }
  s.platforms     = { :ios => "12.0", :osx => "11.0" }
  s.source        = { :git => "https://github.com/rexcosta/ZomatoTestApp" }

  s.source_files  = "Sources/**/*.{swift}"

  s.dependency "ZomatoFoundation"

end
