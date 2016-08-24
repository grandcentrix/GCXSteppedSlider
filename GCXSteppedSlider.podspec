Pod::Spec.new do |s|
  s.name             = 'GCXSteppedSlider'
  s.version          = '0.3.0'
  s.summary          = 'A custom UISlider implementation with tappable intermediate steps.'

  s.description      = <<-DESC
A custom UISlider implementation with tappable intermediate steps.
                       DESC

  s.homepage         = 'https://github.com/grandcentrix/GCXSteppedSlider.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Timo Josten' => 'timo.josten@grandcentrix.net' }
  s.source           = { :git => 'https://github.com/grandcentrix/GCXSteppedSlider.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'GCXSteppedSlider/Classes/**/*'

  s.dependency  'Masonry'
end
