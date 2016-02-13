//
//  HSDatePickerViewController.m
//
//  Created by Kamil Powałowski on 10.01.2015.
//  Copyright (c) 2015 Hydra Softworks.
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "HSDatePickerViewController.h"

typedef enum : NSUInteger {
    DayPicker = 0,
    HourPicker = 1,
    MinutePicker = 2,
} HSDatePickerType;

static NSInteger kRowsMultiplier = 200;
static NSInteger kBufforRows = 30; //Number of rows that are prevent by scroll picker to end

@interface HSDatePickerViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *pickerBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *separator1View;
@property (weak, nonatomic) IBOutlet UIView *separator2View;
@property (weak, nonatomic) IBOutlet UIView *separator3View;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (weak, nonatomic) IBOutlet UILabel *monthAndYearLabel;

@property (weak, nonatomic) IBOutlet UIButton *monthPreviousButton;
@property (weak, nonatomic) IBOutlet UIButton *monthNextButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (nonatomic, assign) NSInteger maxRowIndex;
@property (nonatomic, assign) NSInteger minRowIndex;

@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;
@end

@implementation HSDatePickerViewController
@synthesize minDate = _minDate;
@synthesize maxDate = _maxDate;

#pragma mark - Controller lifecycle

-(instancetype)init {
    if ( self = [super init] ) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        //Set minRowIndex and maxRowIndex to -1, so in property getter we will know that to set it to proper values
        self.minRowIndex = self.maxRowIndex = -1;
        
        self.dismissOnCancelTouch = YES;
        self.minuteStep = StepFiveMinutes;
        
        //Min and max data test
        //self.minDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24*-60 + 3*60*60];
        //self.maxDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24*60 - 3*60*60];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSBundle *podbundle = [NSBundle bundleForClass:[self class]];
    self = [super initWithNibName:nibNameOrNil bundle:podbundle];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set deafult values for pickers
    for (NSUInteger i = 0; i < 3; i++) {
        [self.pickerView selectRow:[self defaultRowValueForComponent:i] inComponent:i animated:NO];
    }
    //Before call of this all parameters must be setted
    [self pickerView:self.pickerView didSelectRow:[self defaultRowValueForComponent:DayPicker] inComponent:DayPicker];
    
    self.pickerBackgroundView.layer.cornerRadius = 10.0;
    self.pickerBackgroundView.layer.borderColor = self.mainColor.CGColor;
    self.pickerBackgroundView.layer.borderWidth = 1.0;
    
    self.separator1View.backgroundColor = self.separator2View.backgroundColor = self.separator3View.backgroundColor = self.mainColor;
    
    self.monthAndYearLabel.textColor = self.mainColor;
    
    [self.monthNextButton setTitleColor:self.mainColor forState:UIControlStateNormal];
    [self.monthNextButton setTitleColor:[self.mainColor colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
    [self.monthNextButton setTitleColor:[self.mainColor colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
    
    [self.monthPreviousButton setTitleColor:self.mainColor forState:UIControlStateNormal];
    [self.monthPreviousButton setTitleColor:[self.mainColor colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
    [self.monthPreviousButton setTitleColor:[self.mainColor colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
    
    [self.confirmButton setTitle:self.confirmButtonTitle forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:self.mainColor forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[self.mainColor colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
    
    [self.backButton setTitle:self.backButtonTitle forState:UIControlStateNormal];
    [self.backButton setTitleColor:self.mainColor forState:UIControlStateNormal];
    [self.backButton setTitleColor:[self.mainColor colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
    
    //Add gesture recognizer to superview...
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelTapGesture:)];
    [self.pickerBackgroundView.superview addGestureRecognizer:gestureRecognizer];
    //...but turn off gesture recognition on lower views
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    [self.pickerBackgroundView addGestureRecognizer:gestureRecognizer];

    //Set hours and minutes to selected values
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:self.date];
    [self setPickerView:self.pickerView rowInComponent:HourPicker toIntagerValue:[components hour] decrementing:NO animated:NO];
    [self setPickerView:self.pickerView rowInComponent:MinutePicker toIntagerValue:[components minute]  decrementing:NO animated:NO];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //This option only works when "View controller-based status bar appearance" in .plist is set to NO
    self.previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:self.previousStatusBarStyle animated:YES];
}

#pragma mark - Properties
- (UIColor *)mainColor {
    if (!_mainColor) {
        _mainColor = [UIColor whiteColor];
    }
    return _mainColor;
}

- (NSDate *)date {
    if (!_date) {
        _date = [NSDate date];
    }
    return _date;
}

- (void)setMinDate:(NSDate *)minDate {
    if ([minDate compare:self.date] == NSOrderedDescending) {
        NSLog(@"minDate=%@ is after date=%@. Value will not be set.", minDate, self.date);
    } else {
        _minDate = minDate;
    }
}

- (NSDate *)minDate {
    if (!_minDate) {
        _minDate = [self dateForRow:kBufforRows];
    }
    return _minDate;
}

- (void)setMaxDate:(NSDate *)maxDate {
    if ([maxDate compare:self.date] == NSOrderedAscending) {
        NSLog(@"maxDate=%@ is before date=%@. Value will not be set.", maxDate, self.date);
    } else {
        _maxDate = maxDate;
    }
}

- (NSDate *)maxDate {
    if (!_maxDate) {
        _maxDate = [self dateForRow:[self pickerView:self.pickerView numberOfRowsInComponent:DayPicker] - kBufforRows];
    }
    return _maxDate;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.dateFormat = @"ccc d MMM";
    }
    return _dateFormatter;
}

- (NSDateFormatter *)monthAndYearLabelDateFormater {
    if (!_monthAndYearLabelDateFormater) {
        _monthAndYearLabelDateFormater = [NSDateFormatter new];
        _monthAndYearLabelDateFormater.dateFormat = @"MMMM yyyy";
    }
    return _monthAndYearLabelDateFormater;
}

- (NSString *)confirmButtonTitle {
    if (!_confirmButtonTitle) {
        _confirmButtonTitle = NSLocalizedString(@"Set date", @"HSDatePicker confirm button title");
    }
    return _confirmButtonTitle;
}

- (NSString *)backButtonTitle {
    if (!_backButtonTitle) {
        _backButtonTitle = NSLocalizedString(@"Back", @"HSDatePicker back button");
    }
    return _backButtonTitle;
}

- (NSInteger)maxRowIndex {
    if (_maxRowIndex == -1) {
        if ([self.maxDate compare:[self dateForRow:[self pickerView:self.pickerView numberOfRowsInComponent:DayPicker] - kBufforRows]] == NSOrderedAscending) {
            _maxRowIndex = [self defaultRowValueForComponent:DayPicker] + [self daysBetweenDate:self.date andDate:self.maxDate];
        }
        else {
            _maxRowIndex = [self pickerView:self.pickerView numberOfRowsInComponent:DayPicker] - kBufforRows;
        }
    }
    return _maxRowIndex;
}

- (NSInteger)minRowIndex {
    if (_minRowIndex == -1) {
        if ([self.minDate compare:[self dateForRow:kBufforRows]] == NSOrderedDescending) {
            _minRowIndex = [self defaultRowValueForComponent:DayPicker] + [self daysBetweenDate:self.date andDate:self.minDate];
        }
        else {
            _minRowIndex = kBufforRows;
        }
    }
    return _minRowIndex;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    //To implement wrap around effect for components we return big number.
    //Real number of components you can get from realNumberOfRowsInComponent
    return [self realNumberOfRowsInComponent:component] * kRowsMultiplier;
}

- (NSInteger)realNumberOfRowsInComponent:(NSInteger)component {
    NSInteger numberOfRows = 0;
    switch (component) {
        case DayPicker:
            numberOfRows = 30;
            break;
        case HourPicker:
            numberOfRows = 24;
            break;
        case MinutePicker:
            numberOfRows = 60 / self.minuteStep;
            break;
    }
    
    return numberOfRows;
}

- (NSInteger)defaultRowValueForComponent:(NSInteger)component {
    return [self realNumberOfRowsInComponent:component] * kRowsMultiplier / 2;
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    CGFloat width = 0.0;
    switch (component) {
        case DayPicker:
            width = 140;
            break;
        case HourPicker:
            width = 40;
            break;
        case MinutePicker:
            width = 40;
            break;
    }
    
    return width;
}


- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = @"";
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    
    switch (component) {
        case DayPicker:
            title = [self stringDateForRow:row];
            [paragraphStyle setAlignment:NSTextAlignmentRight];
            break;
        case HourPicker:
            title = [NSString stringWithFormat:@"%02ld", row % [self realNumberOfRowsInComponent:component]];
            [paragraphStyle setAlignment:NSTextAlignmentCenter];

            break;
        case MinutePicker:
            title = [NSString stringWithFormat:@"%02lu", row % [self realNumberOfRowsInComponent:component] * self.minuteStep];
            [paragraphStyle setAlignment:NSTextAlignmentLeft];

            break;
    }
    
    
     return [[NSAttributedString alloc] initWithString:title attributes:
             @{NSForegroundColorAttributeName: self.mainColor,
                NSParagraphStyleAttributeName: paragraphStyle}];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == DayPicker) {
        self.monthAndYearLabel.text = [self.monthAndYearLabelDateFormater stringFromDate:[self dateForRow:row]];
        
        //If picker values are to close to bufforValue scroll it back
        if (row < self.minRowIndex) {
            [self.pickerView selectRow:self.minRowIndex inComponent:component animated:YES];
            [self pickerView:self.pickerView didSelectRow:self.minRowIndex inComponent:component];
        }
        if (row > self.maxRowIndex) {
            [self.pickerView selectRow:self.maxRowIndex inComponent:component animated:YES];
            [self pickerView:self.pickerView didSelectRow:self.maxRowIndex inComponent:component];
        }
        
        //Disable month change buttons
        self.monthNextButton.enabled = YES;
        self.monthPreviousButton.enabled = YES;
        if (row <= self.minRowIndex) {
            self.monthPreviousButton.enabled = NO;
        }
        if (row >= self.maxRowIndex) {
            self.monthNextButton.enabled = NO;
        }
    }
    
    NSInteger firstComponentRowValue = [pickerView selectedRowInComponent:DayPicker];
    //If picker values are to close to bufforValue scroll it back
    if (firstComponentRowValue <= self.minRowIndex) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:self.minDate];
        [self setPickerView:self.pickerView rowInComponent:HourPicker toIntagerValue:[components hour] decrementing:NO animated:YES];
        if ([pickerView selectedRowInComponent:HourPicker] <= [self defaultRowValueForComponent:HourPicker] + [components hour]) {
            [self setPickerView:self.pickerView rowInComponent:MinutePicker toIntagerValue:[components minute]  decrementing:NO animated:YES];
        }
    }
    if (firstComponentRowValue >= self.maxRowIndex) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:self.maxDate];
        [self setPickerView:self.pickerView rowInComponent:HourPicker toIntagerValue:[components hour] decrementing:YES animated:YES];
        if ([pickerView selectedRowInComponent:HourPicker] >= [self defaultRowValueForComponent:HourPicker] + [components hour]) {
            [self setPickerView:self.pickerView rowInComponent:MinutePicker toIntagerValue:[components minute]  decrementing:YES animated:YES];
        }
    }
}

- (void)setPickerView:(UIPickerView *)pickerView rowInComponent:(NSInteger)component toIntagerValue:(NSInteger)value decrementing:(BOOL)decrementing animated:(BOOL)animated {
    if (decrementing) {
        BOOL valueSetted = NO;
        for (NSInteger i = 0; i < [self realNumberOfRowsInComponent:component]; i++) {
            if ([[self pickerView:pickerView attributedTitleForRow:[pickerView selectedRowInComponent:component] - i forComponent:component].string integerValue] <= value) {
                [pickerView selectRow:[pickerView selectedRowInComponent:component] - i inComponent:component animated:animated];
                valueSetted = YES;
                break;
            }
        }
        if (!valueSetted && component == MinutePicker) {
            [pickerView selectRow:[pickerView selectedRowInComponent:HourPicker] - 1 inComponent:HourPicker animated:animated];
            if ([[self pickerView:pickerView attributedTitleForRow:[pickerView selectedRowInComponent:HourPicker] forComponent:HourPicker].string integerValue] == 0) {
                [pickerView selectRow:[pickerView selectedRowInComponent:DayPicker] - 1 inComponent:DayPicker animated:animated];
            }
        }
    } else {
        BOOL valueSetted = NO;
        for (NSInteger i = 0; i < [self realNumberOfRowsInComponent:component]; i++) {
            if ([[self pickerView:pickerView attributedTitleForRow:[pickerView selectedRowInComponent:component] + i forComponent:component].string integerValue] >= value) {
                [pickerView selectRow:[pickerView selectedRowInComponent:component] + i inComponent:component animated:animated];
                valueSetted = YES;
                break;
            }
        }
        if (!valueSetted && component == MinutePicker) {
            [pickerView selectRow:[pickerView selectedRowInComponent:HourPicker] + 1 inComponent:HourPicker animated:animated];
            if ([[self pickerView:pickerView attributedTitleForRow:[pickerView selectedRowInComponent:HourPicker] forComponent:HourPicker].string integerValue] == 0) {
                [pickerView selectRow:[pickerView selectedRowInComponent:DayPicker] + 1 inComponent:DayPicker animated:animated];
            }
        }
    }
}

#pragma mark - NSDate operations
-(BOOL)isDate:(NSDate*)date1 sameDayAsDate:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

- (NSInteger)daysInMonth:(NSDate *)date {
    return [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay
                                             inUnit:NSCalendarUnitMonth
                                            forDate:date].length;
}

- (NSDate *)dateForRow:(NSInteger)row {
    row = row - [self defaultRowValueForComponent:DayPicker];
    NSDate * date = [self.date dateByAddingTimeInterval:60 * 60 * 24 * row];
    return [[NSCalendar currentCalendar] dateBySettingHour:0 minute:0 second:0 ofDate:date options:0];
}

- (NSString *)stringDateForRow:(NSUInteger)row {
    NSDate *date = [self dateForRow:row];
    if ([self isDate:date sameDayAsDate:[NSDate date]]) {
        return NSLocalizedString(@"Today", @"Current day indicator");
    }
    return [self.dateFormatter stringFromDate:date];
}


//http://stackoverflow.com/questions/4739483/number-of-days-between-two-nsdates
- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

- (NSDate *)dateWithSelectedTime {
    NSDate *date = [self dateForRow:[self.pickerView selectedRowInComponent:DayPicker]];
    NSInteger hour = [[self pickerView:self.pickerView attributedTitleForRow:[self.pickerView selectedRowInComponent:HourPicker] forComponent:HourPicker].string integerValue];
    NSInteger minute = [[self pickerView:self.pickerView attributedTitleForRow:[self.pickerView selectedRowInComponent:MinutePicker] forComponent:MinutePicker].string integerValue];
    return [[NSCalendar currentCalendar] dateBySettingHour:hour minute:minute second:0 ofDate:date options:0];
}

#pragma mark - Actions
- (IBAction)jumpToPreviousMonth:(id)sender {
    NSDate *date = [self dateForRow:[self.pickerView selectedRowInComponent:DayPicker]];
    NSInteger row = [self.pickerView selectedRowInComponent:DayPicker] - [self daysInMonth:date];
    [self.pickerView selectRow:row inComponent:DayPicker animated:YES];
    [self pickerView:self.pickerView didSelectRow:row inComponent:DayPicker];
}

- (IBAction)jumpToNextMonth:(id)sender {
    NSDate *date = [self dateForRow:[self.pickerView selectedRowInComponent:DayPicker]];
    NSInteger row = [self.pickerView selectedRowInComponent:DayPicker] + [self daysInMonth:date];
    [self.pickerView selectRow:row inComponent:DayPicker animated:YES];
    [self pickerView:self.pickerView didSelectRow:row inComponent:DayPicker];
}

- (IBAction)confirmDate:(id)sender {
    //TODO: Set date
    if ([self.delegate respondsToSelector:@selector(hsDatePickerPickedDate:)]) {
        [self.delegate hsDatePickerPickedDate:[self dateWithSelectedTime]];
    }
    
    if ([self.delegate respondsToSelector:@selector(hsDatePickerWillDismissWithQuitMethod:)]) {
        [self.delegate hsDatePickerWillDismissWithQuitMethod:QuitWithResult];
    }
    void (^success)(void) = nil;
    if ([self.delegate respondsToSelector:@selector(hsDatePickerDidDismissWithQuitMethod:)]) {
        success = ^{
            [self.delegate hsDatePickerDidDismissWithQuitMethod:QuitWithResult];
        };
    }
    [self dismissViewControllerAnimated:YES completion:success];
}

- (IBAction)quitPicking:(id)sender {
    if ([self.delegate respondsToSelector:@selector(hsDatePickerWillDismissWithQuitMethod:)]) {
        [self.delegate hsDatePickerWillDismissWithQuitMethod:QuitWithBackButton];
    }
    void (^success)(void) = nil;
    if ([self.delegate respondsToSelector:@selector(hsDatePickerDidDismissWithQuitMethod:)]) {
        success = ^{
            [self.delegate hsDatePickerDidDismissWithQuitMethod:QuitWithBackButton];
        };
    }
    [self dismissViewControllerAnimated:YES completion:success];
}

- (void)cancelTapGesture:(UITapGestureRecognizer *)sender {
    if (self.shouldDismissOnCancelTouch) {
        if ([self.delegate respondsToSelector:@selector(hsDatePickerWillDismissWithQuitMethod:)]) {
            [self.delegate hsDatePickerWillDismissWithQuitMethod:QuitWithCancel];
        }
        void (^success)(void) = nil;
        if ([self.delegate respondsToSelector:@selector(hsDatePickerDidDismissWithQuitMethod:)]) {
            success = ^{
                [self.delegate hsDatePickerDidDismissWithQuitMethod:QuitWithCancel];
            };
        }
        [self dismissViewControllerAnimated:YES completion:success];
    }
}

@end
