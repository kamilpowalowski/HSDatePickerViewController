HSDatePickerViewController
==========================
`HSDatePickerViewController` is an iOS ViewController for date and time picking, based on awesome look&feel of Dropbox [Mailbox](http://www.mailboxapp.com/) application with some customization options.

![HSDatePickerViewController screen](https://raw.githubusercontent.com/EmilYo/HSDatePickerViewController/master/screen1.png)
![HSDatePickerViewController screen](https://raw.githubusercontent.com/EmilYo/HSDatePickerViewController/master/screen2.png)

Usage
=====
Use [CocoaPods](http://guides.cocoapods.org/using/using-cocoapods.html)
```
pod 'HSDatePickerViewController', '~> 1.0'
```
or add sources from `HSDatePickerViewControllerDemo/HSDatePickerViewController` subfolder to your project.



Import main header:

```objective-c
#import "HSDatePickerViewController.h"
```

When needed, create `HSDatePickerViewController` object:

```objective-c
HSDatePickerViewController *hsdpvc = [[HSDatePickerViewController alloc] init];
```

present it as modal view controller:
```objective-c
[self presentViewController:hsdpvc animated:YES completion:nil];
```

To get returning values, you must conform to the protocol `HSDatePickerViewControllerDelegate`:

```objective-c
@protocol HSDatePickerViewControllerDelegate <NSObject>
- (void)hsDatePickerPickedDate:(NSDate *)date;
@optional
- (void)hsDatePickerWillDismissWithQuitMethod:(HSDatePickerQuitMethod)method;
- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method;
@end
```

Also, **before** presenting `HSDatePickerViewController`, you can change default values of some properties (check `HSDatePickerViewController.h` file for longer description):

```objective-c
@property (nonatomic, assign, getter=shouldDismissOnCancelTouch) BOOL dismissOnCancelTouch;

@property (nonatomic, assign) HSDatePickerMinutesStep minuteStep;

@property (nonatomic, strong) UIColor *mainColor;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *minDate;
@property (nonatomic, strong) NSDate *maxDate;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *monthAndYearLabelDateFormater;

@property (nonatomic, strong) NSString *confirmButtonTitle;
@property (nonatomic, strong) NSString *backButtonTitle;
```

Licence (MIT)
=======
Copyright (c) 2015 Kamil Powałowski [@kamilpowalowski](https://twitter.com/kamilpowalowski)

For whole licence see LICENCE file.
