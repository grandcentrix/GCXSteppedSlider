//
//  GCXViewController.m
//  GCXSteppedSlider
//
//  Created by Timo Josten on 06/03/2016.
//  Copyright (c) 2016 Timo Josten. All rights reserved.
//

#import "GCXViewController.h"
#import <GCXSteppedSlider/GCXSteppedSlider.h>
#import <Masonry/Masonry.h>

@interface GCXViewController () <GCXSteppedSliderDelegate>

@property (nonatomic, weak, nullable) GCXSteppedSlider* slider;
@property (nonatomic, strong, nullable) NSArray* values;

@end

@implementation GCXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.values = @[@"First", @"Second", @(3)];

    GCXSteppedSlider* slider = [[GCXSteppedSlider alloc] initWithFrame:CGRectZero stepValues:self.values initialStep:self.values[1]];
    //slider.disabledStepValues = @[self.values[2]];
    slider.delegate = self;
    slider.tintColor = [UIColor redColor];
    slider.signatureColor = [UIColor grayColor];
    [self.view addSubview:slider];
    self.slider = slider;

    {
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectZero];
        [button setTitle:@"Select Value #3" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(demoAction3:) forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit];
        button.center = CGPointMake(self.view.center.x, self.view.center.y);
        [self.view addSubview:button];
    }

    {
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectZero];
        [button setTitle:@"Select Value #4" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(demoAction4:) forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit];
        button.center = CGPointMake(self.view.center.x, self.view.center.y + 30.0);
        [self.view addSubview:button];
    }
}

- (void)updateViewConstraints {
    [self.slider mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.top.equalTo(self.view.mas_top).offset(25);
        make.height.equalTo(@(200));
    }];

    [super updateViewConstraints];
}

# pragma mark Demo

- (void)demoAction3:(id)sender {
    [self.slider setValue:2 animated:NO];
}

- (void)demoAction4:(id)sender {
    [self.slider setValue:3 animated:NO];
}

# pragma mark <GCXSteppedSliderDelegate>

- (void)steppedSlider:(GCXSteppedSlider *)slider label:(UILabel *__autoreleasing *)label forValue:(id)stepValue {
    [*label setTextColor:[UIColor redColor]];
}

- (NSString*)steppedSlider:(GCXSteppedSlider *)slider labelStringForValue:(id)stepValue {
    return [NSString stringWithFormat:@"No. %lu with a very long label", [self.values indexOfObject:stepValue]];
}

- (UIImage*)steppedSlider:(GCXSteppedSlider *)slider stepImageForValue:(id)stepValue {
    return [UIImage imageNamed:@"example"];
}

- (void)steppedSlider:(GCXSteppedSlider *)slider valueChanged:(id)selectedValue {
    NSLog(@"slider value: %@", selectedValue);
}

- (CGSize)steppedSlider:(GCXSteppedSlider *)slider sizeForStepImageOfValue:(id)stepValue {
    if (slider.disabledStepValues && [slider.disabledStepValues indexOfObject:stepValue] != NSNotFound) {
        return CGSizeMake(10.0, 10.0);
    } else if ([stepValue isEqual:self.values.firstObject]) {
        return CGSizeMake(10.0, 10.0);
    } else if ([stepValue isEqual:self.values.lastObject]) {
        return CGSizeMake(25.0, 25.0);
    }
    return CGSizeMake(15.0, 15.0);
}

@end
