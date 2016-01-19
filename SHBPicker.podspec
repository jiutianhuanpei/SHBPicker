
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

  s.source       = { :git => "https://github.com/jiutianhuanpei/SHBPicker.git", :tag => s.version.to_s }

  s.source_files = 'SHBPicker/SHBPicker/*.{h,m}'

    s.resources = 'SHBPicker/SHBPicker/*.{png}'

  s.requires_arc = true

end
