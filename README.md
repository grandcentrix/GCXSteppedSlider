# GCXSteppedSlider
A custom UISlider implementation with tappable intermediate steps.

![Demo](https://dropshare-gcx-de.s3-eu-central-1.amazonaws.com/Screen-Recording-2016-06-03-11-32-59-lQ6zu/Screen-Recording-2016-06-03-11-32-59.gif)

## Installation

### From CocoaPods

```ruby
pod 'GCXSteppedSlider'
```

## Usage

(Find sample project with integration in `/Example`)

`GCXSteppedSlider` is a custom UISlider implementation with intermediate steps that is nicely configurable.

```objective-c
- (void)viewDidLoad {
  [super viewDidLoad];

  NSArray* stepValues = @[@"First", @"Second", @(3), @(4), @(5)];
  self.stepValues = stepValues;
  UIImage* stepImage = [UIImage imageNamed:@"example"];
  GCXSteppedSlider* slider = [[GCXSteppedSlider alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 25.0) stepValues:stepValues initialStep:stepValues[2]];
  slider.disabledStepValues = @[@(3)];
  slider.delegate = self;
  slider.tintColor = [UIColor redColor];
  slider.signatureColor = [UIColor grayColor];
  [self.view addSubview:slider];
}

# pragma mark <GCXSteppedSliderDelegate>

- (UIImage*)steppedSlider:(GCXSteppedSlider *)slider stepImageForValue:(id)stepValue {
  return [UIImage imageNamed:@"example"];
}

- (void)steppedSlider:(GCXSteppedSlider *)slider valueChanged:(id)selectedValue {
  NSLog(@"slider value: %@", selectedValue);
}

- (CGSize)steppedSlider:(GCXSteppedSlider *)slider sizeForStepImageOfValue:(id)stepValue {
  if ([slider.disabledStepValues indexOfObject:stepValue] != NSNotFound) {
    return CGSizeMake(5.0, 5.0);
  } else if ([stepValue isEqual:self.stepValues.firstObject]) {
    return CGSizeMake(25.0, 25.0);
  } else if ([stepValue isEqual:self.stepValues.lastObject]) {
    return CGSizeMake(25.0, 25.0);
  }
  return CGSizeMake(15.0, 15.0);
}
```

## Documentation

* [GCXSteppedSlider.h](https://github.com/grandcentrix/GCXSteppedSlider/blob/master/GCXSteppedSlider/Classes/GCXSteppedSlider.h)

## Maintainer

* [tjosten](https://github.com/tjosten/)

Please file [Issues](https://github.com/grandcentrix/GCXSteppedSlider/issues/) and do not contact maintainers directly. Thank you!
