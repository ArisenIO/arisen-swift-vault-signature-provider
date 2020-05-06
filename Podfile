using_local_pods = ENV['USE_LOCAL_PODS'] == 'true' || false

platform :ios, '11.3'

# ignore all warnings from all pods
inhibit_all_warnings!

if using_local_pods
  # Pull pods from sibling directories if using local pods
  target 'ArisenSwiftVaultSignatureProvider' do
    use_frameworks!

    pod 'ArisenSwift', :path => '../arisen-swift'
    pod 'ArisenSwiftEcc', :path => '../arisen-swift-ecc'
    pod 'ArisenSwiftVault', :path => '../arisen-swift-vault'
    pod 'SwiftLint'

    target 'ArisenSwiftVaultSignatureProviderTests' do
      inherit! :search_paths
      pod 'ArisenSwift', :path => '../arisen-swift'
      pod 'ArisenSwiftEcc', :path => '../arisen-swift-ecc'
      pod 'ArisenSwiftVault', :path => '../arisen-swift-vault'
    end
  end
else
  # Pull pods from sources above if not using local pods
  target 'ArisenSwiftVaultSignatureProvider' do
    use_frameworks!

    pod 'ArisenSwift', '~> 0.2.1'
    pod 'ArisenSwiftEcc', '~> 0.2.1'
    pod 'ArisenSwiftVault', '~> 0.2.1'
    pod 'SwiftLint'

    target 'ArisenSwiftVaultSignatureProviderTests' do
      use_frameworks!
      inherit! :search_paths
      pod 'ArisenSwift', '~> 0.2.1'
      pod 'ArisenSwiftEcc', '~> 0.2.1'
      pod 'ArisenSwiftVault', '~> 0.2.1'
    end
  end
end
