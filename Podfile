platform :ios, '5.0'

pod 'NXOAuth2Client', '1.2.4'
pod 'SVProgressHUD', '1.0'
pod 'Reachability', '3.1.1'
pod 'TSMessages', '0.9.4'
pod 'TDBadgedCell', '2.6'
pod 'iRate', '1.9.2'
pod 'iTellAFriend', '1.4.1'
pod 'EDSemver', '0.2.2'

#pod 'Analytics'
#pod 'iVersion'

pod 'GoogleAnalytics-iOS-SDK', '2.0beta4'
pod 'UIDevice-Hardware', '0.1.5'

#Beta-Testing
pod 'TestFlightSDK', '2.2.1-beta'
pod 'Fingertips', '0.3.0'
#pod 'Lookback'


post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Pods-Acknowledgements.plist', 'Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
