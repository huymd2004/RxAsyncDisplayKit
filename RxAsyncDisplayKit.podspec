Pod::Spec.new do |s|
  s.name             = "RxAsyncDisplayKit"
  s.version          = "0.1.0"
  s.summary          = "RxSwift AsyncDisplayKit extension based on RxCocoa"
  s.description      = <<-DESC
* AsyncDisplayKit extension
                       DESC

  s.homepage         = "https://github.com/Hxucaa/RxAsyncDisplayKit"
  s.license          = 'MIT'
  s.author           = { "Lance Zhu" => "lancezhu77@gmail.com" }
  s.source           = { :git => "https://github.com/Hxucaa/RxAsyncDisplayKit.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'RxSwift', '~> 2.3.1'
  s.dependency 'RxCocoa', '~> 2.3.1'
  s.dependency 'RxDataSources', '~> 0.6.1'
  s.dependency 'AsyncDisplayKit', '= 1.9.6'
end
