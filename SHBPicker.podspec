
Pod::Spec.new do |s|

  s.name         = "SHBPicker"
  s.version      = "0.0.1"
  s.summary      = "图片选择器"

  s.description  = "我的第一个支持cocoaPods的项目"

  s.homepage     = "https://github.com/jiutianhuanpei/SHBPicker"

  s.license      = 'MIT'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "jiutianhuanpei" => "shenhongbang@163.com" }

  s.platform     = :ios

  s.source       = { :git => "https://github.com/jiutianhuanpei/SHBPicker.git", :tag => '0.0.1' }

  s.source_files = 'Classes/*.{h,m}'

  #s.framework    = 'AVFoundation', 'AudioToolbox', 'MediaPlayer'

  s.requires_arc = true

end
