Pod::Spec.new do |spec|
  spec.name     = 'CombineCloudKit'
  spec.version  = '1.0.2'
  spec.summary  = '🌤 Swift Combine extensions for reactive CloudKit record processing'
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
  spec.swift_versions             = ['5.1', '5.2', '5.3', '5.4', '5.5']

  spec.source_files   = 'Sources/**/*.swift'
end
