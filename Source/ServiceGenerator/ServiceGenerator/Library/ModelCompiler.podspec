Pod::Spec.new do |s|
  s.name         = "ModelCompiler"
  s.version      = "1.2.0"
  s.summary      = "RedMadRobot Swift model compiler"
  s.description  = "Implements annotation parsing"
  s.homepage     = "https://git.redmadrobot.com/foundation-ios/ModelCompiler"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Egor Taflanidi" => "et@gredmadrobot.com" }
  s.platform     = :osx
  s.source       = { :git => "git@git.redmadrobot.com:foundation-ios/ModelCompiler.git", :tag => s.version, :branch => "master" }
  s.source_files = "Source/ModelCompiler/ModelCompiler/Classes/**/*"
  s.requires_arc = true
end
