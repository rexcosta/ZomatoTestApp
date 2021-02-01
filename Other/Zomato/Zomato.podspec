
Pod::Spec.new do |s|

  s.name          = "Zomato"
  s.version       = "0.0.1"
  s.summary       = "Zomato"
  s.description   = "Zomato"
  s.homepage      = "https://github.com/rexcosta"
  s.author        = { "david" => "https://github.com/rexcosta" }
  s.platforms     = { :ios => "12.0", :osx => "11.0" }
  s.source        = { :git => "https://github.com/rexcosta/ZomatoTestApp" }

  s.source_files  = "Zomato/Source/**/*.{swift}"

  s.dependency "ZomatoFoundation"
  s.dependency "RxSwift"

end
