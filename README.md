
# Install Cocopods (if not installed)
sudo gem install cocoapods

# In project, Initialize cocoapods
pod init
open Podfile

# Add Dependencies to Podfile
pod 'RxSwift'
pod 'RxCocoa'

# Install Pod dependencies
pod install

# Open workspace file