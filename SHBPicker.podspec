
Pod::Spec.new do |s|
s.name         = "SHBPicker"
s.version      = "0.0.1"
s.summary      = "图片选择器"

s.description  = <<-DESC
我的第一个支持cocoaPods的项目
DESC

s.homepage     = "https://github.com/jiutianhuanpei/SHBPicker.git"



s.author   = { "jiutianhuanpei" => "shenhongbang@163.com" }

s.source       = { :git => "https://github.com/jiutianhuanpei/SHBPicker.git", :tag => s.version.to_s }

s.source_files = 'SHBPicker/*.{h,m}'

s.framework    = 'UIKit'
s.framework    = 'Photos'
s.requires_arc = true
s.ios.deployment_target = "8.1"
end