
Pod::Spec.new do |s|
  s.name             = 'SSNavigation'
  s.version          = '0.1.0'
  s.summary          = '导航控制器，可以比较方便的设置导航的颜色，比较适合跳往不同的页面导航颜色不一样的情况，过渡效果比较好'
  s.homepage         = 'https://github.com/zhtut/SSNavigation'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ztgtut' => 'ztgtut@github.com' }
  s.source           = { :git => 'https://github.com/zhtut/SSNavigation.git', :tag => s.version.to_s }

  s.swift_version = '5.0'
  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/**/*.swift'
  
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  
end
