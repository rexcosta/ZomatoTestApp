
Pod::Spec.new do |s|

  s.name          = "ZomatoFoundation"
  s.version       = "0.0.1"
  s.summary       = "Zomato utils for Foundation"
  s.description   = "Zomato utils for Foundation"
  s.homepage      = "https://github.com/rexcosta"
  s.author        = { "david" => "https://github.com/rexcosta" }
  s.platforms     = { :ios => "12.0", :osx => "11.0" }
  s.source        = { :git => "https://github.com/rexcosta/ZomatoTestApp" }

  s.source_files  = "Sources/**/*.{swift}"

end
