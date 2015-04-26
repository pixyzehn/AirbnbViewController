Pod::Spec.new do |s|
  s.name = "AirbnbViewController"
  s.version = "1.0.2"
  s.summary = "Airbnb 4.7's three-dimensional slide menu. Unfortunately, this menu was obsoleted in Airbnb 5.0. "
  s.homepage = 'https://github.com/pixyzehn/AirbnbViewController'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { "pixyzehn" => "civokjots0109@gmail.com" }

  s.requires_arc = true
  s.ios.deployment_target = "8.0"
  s.source = { :git => "https://github.com/pixyzehn/AirbnbViewController.git", :tag => "#{s.version}" }
  s.source_files = "AirbnbViewController/*.{h,m,swift}"
end
