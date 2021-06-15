Pod::Spec.new do |spec|
  spec.name     = 'CombineCloudKit'
  spec.version  = '0.4.1'
  spec.summary  = '🌤 Swift Combine extensions for asynchronous CloudKit record processing'
  spec.description = <<-DESC
    CombineCloudKit exposes CloudKit operations as Combine publishers. Publishers can be used to process values over
    time, using Combine's declarative API.
  DESC
  spec.documentation_url = 'https://combinecloudkit.hiddenplace.dev'
  spec.homepage = 'https://github.com/chris-araman/CombineCloudKit'
  spec.source   = { :git => 'https://github.com/chris-araman/CombineCloudKit.git', :tag => "#{spec.version}" }
  spec.license  = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.author   = 'Chris Araman'
  spec.social_media_url = 'https://github.com/chris-araman'

  spec.ios.deployment_target      = '13.0'
  spec.osx.deployment_target      = '10.15'
  spec.tvos.deployment_target     = '13.0'
  spec.watchos.deployment_target  = '6.0'
  spec.swift_versions             = ['5.1', '5.2', '5.3', '5.4']

  spec.source_files   = 'Sources/**/*.swift'
  spec.test_spec 'Tests' do |test_spec|
    test_spec.compiler_flags = '-DCOCOAPODS'
    test_spec.source_files = 'Tests/**/*.swift'
    test_spec.dependency 'CombineExpectations', '~> 0.9'
    test_spec.ios.deployment_target      = '13.0'
    test_spec.osx.deployment_target      = '10.15'
    test_spec.tvos.deployment_target     = '13.0'
    # TODO: Enable this once we have access to Xcode 12.5 in GitHub Actions.
    # XCTest was not available until watchOS 7.4.
    # test_spec.watchos.deployment_target  = '7.4'
  end
end
