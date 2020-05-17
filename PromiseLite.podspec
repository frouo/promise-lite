Pod::Spec.new do |s|
  s.name             = 'PromiseLite'
  s.version          = '1.4.0'
  s.summary          = 'Lets chain asynchronous functions. Very lightweight 🌱, 100% tested 💯, pure Swift 🏎, no magic.'

  s.description      = <<-DESC
Lets chain asynchronous functions.
This is a lightweight implementation of Javascript Promise.
It is pure Swift, 100% tested, and very lightweight (~100 lines of code) #greentech 🌱
                       DESC

  s.homepage         = 'https://github.com/frouo/promise-lite'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'François Rouault' => 'francois.rouault@cocoricostudio.com' }
  s.source           = { :git => 'https://github.com/frouo/promise-lite.git', :tag => s.version.to_s }

  deployment_target_ios = '9.0'
  deployment_target_osx = '10.9'
  deployment_target_tvos = '9.0'
  s.ios.deployment_target = deployment_target_ios
  s.osx.deployment_target = deployment_target_osx
  s.tvos.deployment_target = deployment_target_tvos
  s.watchos.deployment_target = '2.0'

  s.swift_version = '5.1'

  s.source_files = 'PromiseLite/Classes/**/*'

  s.test_spec 'Tests' do |test_spec|
    test_spec.ios.deployment_target = deployment_target_ios
    test_spec.osx.deployment_target = deployment_target_osx
    test_spec.tvos.deployment_target = deployment_target_tvos
    test_spec.source_files = 'PromiseLite/Tests/**/*.{swift}'
  end
end
