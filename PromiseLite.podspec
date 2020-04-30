Pod::Spec.new do |s|
  s.name             = 'PromiseLite'
  s.version          = '1.1.0'
  s.summary          = 'Lets chain asynchronous functions. Lightweight, 100% tested, no magic.'

  s.description      = <<-DESC
Lets chain asynchronous functions.
This is a lightweight implementation of Javascript Promise.
Easy to use, documented, tested.
                       DESC

  s.homepage         = 'https://github.com/frouo/promise-lite'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'François Rouault' => 'francois.rouault@cocoricostudio.com' }
  s.source           = { :git => 'https://github.com/frouo/promise-lite.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.swift_version = '5.1'

  s.source_files = 'PromiseLite/Classes/**/*'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.{swift}'
  end
end
