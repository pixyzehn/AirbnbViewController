AirbnbViewController
====================

Airbnb version 4.7's three-dimensional slide menu in Swift. Unfortunately, the menu was obsoleted in Airbnb version 5.0. In order not to forget the legend menu, I developed it in Swift.

Inspired by https://github.com/TaPhuocHai/PHAirViewController.

Overview
## Description

Storyboard is not supported. You need to write code.
I have no choice but to use Objective-C in a part of whole.

## Demo

![AirbnbViewController](https://github.com/pixyzehn/AirbnbViewController/blob/master/Assets/demo.gif)

##Installation

The easiest way to get started is to use [CocoaPods](http://cocoapods.org/). Add the following line to your Podfile:

```ruby
use_frameworks!
pod 'AirbnbViewController'
```

And then, you need to have [project-name]-Bridging-Header.h because AirbnbViewController use Objective-C file.
The easiest way to create a bridging header file is to add an arbitrary Objective-C file to your project and let Xcode create the bridging header for you.
Delete the original Objective-C file as you no longer need it.

[project-name]-Bridging-Header.h

```objc
#import "AirbnbHelper.h"
```
Please refer to AirbnbViewController-Sample project. 

## Licence

[MIT](https://github.com/pixyzehn/AirbnbViewController/blob/master/LICENSE)

## Author

[pixyzehn](https://github.com/pixyzehn)
