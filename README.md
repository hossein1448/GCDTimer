# GCDTimer

An implementaiton of timer which supports GCD queue with some practical features such as
- fire and invalidatein
- pause
- resume
- remaining time

in Objective-C and Swift.

Why we use GCDTimer
============
* We love [Grand Central Dispatch!](https://developer.apple.com/documentation/dispatch).
* Apple has not announced any APIs for NSTimer/Timer which supports GCD properly.
* The API for using NSTimer/Timer which supports block/clousre just work for iOS 10+. It means we have to handle the iOS versions programatically and choose a proper way to use NSTimer/Timer.
* NSTimer retain cycle issue, NSTimer will maintain a strong reference to the target, which can cause (especially in repeating timers) strong reference cycles (a.k.a. retain cycles) 

## Requirements

- iOS 7.0+
- Swift 4.0+
- Objective-C

How to use
============
Create an GCDTimer object with the init method in Objective-C:
```objective-c
GCDTimer *timer =  [[GCDTimer alloc] initWithTimeout:2.0 repeat:true completion:^{
        <#code#>
    } queue:dispatch_get_main_queue()]
```
in Swift:
```swift
let timer = GCDTimer(timeout: 2.0, repeat: true, completion: {
            <#code#>
        }, queue: DispatchQueue.main)
```
Please Check out the code in the test targets for more.
