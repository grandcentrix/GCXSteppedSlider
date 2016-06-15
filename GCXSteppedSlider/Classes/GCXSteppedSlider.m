//
//  GCXSteppedSlider.m
//
//  Created by Timo Josten on 02/06/16.
//  Copyright © 2016 grandcentrix. All rights reserved.
//

#import "GCXSteppedSlider.h"
#import <Masonry/Masonry.h>
#import <Masonry/NSLayoutConstraint+MASDebugAdditions.h>

@implementation GCXSteppedSliderImageView
@end

static CGSize GCXSteppedSliderImageViewDefaultStepSize;
static CGFloat const GCXSteppedSliderStepLabelDefaultTopMargin = 15.0;

@interface GCXSteppedSlider ()

@property (nonatomic, strong, nullable) id currentValue;
@property (nonatomic, strong, nonnull) NSArray* stepValues;
@property (nonatomic, assign) NSUInteger previousIndex;
@property (nonatomic, weak, nullable) UIView* trackView;
@property (nonatomic, strong, nullable) NSArray<GCXSteppedSliderImageView*>* stepImageViews;
@property (nonatomic, strong, nullable) NSArray<UIView*>* stepImageSpacerViews;
@property (nonatomic, strong, nullable) NSMutableDictionary<NSNumber*, UILabel*>* stepLabelViews;

@end

@implementation GCXSteppedSlider

+ (void)initialize {
    GCXSteppedSliderImageViewDefaultStepSize = CGSizeMake(15.0, 15.0);
}

- (instancetype __nonnull)initWithFrame:(CGRect)frame stepValues:(NSArray<id>* __nonnull)stepValues initialStep:(id __nullable)initialStep {
    if (self = [super initWithFrame:frame]) {
        if (!stepValues) {
            stepValues = @[];
        }
        self.stepValues = stepValues;
        self.stepLabelViews = [NSMutableDictionary dictionary];

        NSUInteger numberOfSteps = self.stepValues.count - 1;
        self.maximumValue = numberOfSteps;
        self.minimumValue = 0;
        self.maximumTrackTintColor = [UIColor clearColor];
        self.minimumTrackTintColor = [UIColor clearColor];
        self.thumbTintColor = self.tintColor;
        self.continuous = YES;

        NSUInteger initialIndex = [self.stepValues indexOfObject:initialStep];
        if (initialIndex != NSNotFound) {
            [self setValue:initialIndex animated:NO];
            self.previousIndex = initialIndex;
        }

        NSMutableArray* stepImageViews = [NSMutableArray array];
        NSMutableArray* stepImageSpacerViews = [NSMutableArray array];
        for (NSUInteger i = 0; i < stepValues.count; i++) {
            GCXSteppedSliderImageView* stepImageView = [[GCXSteppedSliderImageView alloc] initWithImage:nil];
            stepImageView.contentMode = UIViewContentModeScaleAspectFit;
            stepImageView.clipsToBounds = YES;
            stepImageView.mas_key = [NSString stringWithFormat:@"StepImageView %lu", i];

            UIView* containerView = [[UIView alloc] initWithFrame:CGRectZero];
            containerView.userInteractionEnabled = NO;
            containerView.clipsToBounds = YES;
            containerView.mas_key = [NSString stringWithFormat:@"ContainerView for StepImageView %lu", i];
            [containerView addSubview:stepImageView];

            [self addSubview:containerView];
            [stepImageViews addObject:stepImageView];

            if (i < stepValues.count - 1) {
                UIView* spacerView = [[UIView alloc] initWithFrame:CGRectZero];
                [self addSubview:spacerView];
                [stepImageSpacerViews addObject:spacerView];
            }
        }

        self.stepImageViews = [stepImageViews copy];
        self.stepImageSpacerViews = [stepImageSpacerViews copy];

        UIView* trackView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:trackView];
        [self sendSubviewToBack:trackView];
        self.trackView = trackView;
        self.trackView.mas_key = @"TrackView";

        [self addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];

        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(trackTapped:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGestureRecognizer];

        self.clipsToBounds = YES;
    }

    return self;
}

# pragma mark Setters

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    self.thumbTintColor = tintColor;
}

- (void)setSignatureColor:(UIColor *)signatureColor {
    if (!signatureColor) {
        signatureColor = self.tintColor;
    }

    for (GCXSteppedSliderImageView* view in self.stepImageViews) {
        view.tintColor = signatureColor;
    }

    self.trackView.backgroundColor = signatureColor;

    _signatureColor = signatureColor;
}

# pragma mark Internals

- (void)setValue:(float)value animated:(BOOL)animated {
    NSUInteger index = [self indexFromValue:value];
    [self selectIndex:index];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];

    for (id value in self.stepValues) {
        NSUInteger index = [self.stepValues indexOfObject:value];
        if (index < self.stepImageViews.count) {
            GCXSteppedSliderImageView* stepImageView = [self.stepImageViews objectAtIndex:index];

            if (stepImageView.image == nil) {
                UIImage* image = nil;
                if ([self.delegate respondsToSelector:@selector(steppedSlider:stepImageForValue:)]) {
                    image = [self.delegate steppedSlider:self stepImageForValue:value];
                    if (image) {
                        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        stepImageView.image = image;
                    }
                }
            }

            [self bringSubviewToFront:stepImageView.superview];
        }
    }

    // set up labels if neccessary
    if ([self.delegate respondsToSelector:@selector(steppedSlider:labelStringForValue:)]) {
        for (id value in self.stepValues) {
            NSUInteger index = [self.stepValues indexOfObject:value];
            NSString* labelString = [self.delegate steppedSlider:self labelStringForValue:value];

            if (labelString.length) {
                NSNumber* labelIndex = @(index);
                UILabel* label = self.stepLabelViews[labelIndex];

                if (!label) {
                    label = [[UILabel alloc] initWithFrame:CGRectZero];
                    self.stepLabelViews[labelIndex] = label;

                    label.numberOfLines = 1;
                    label.lineBreakMode = NSLineBreakByTruncatingTail;
                    label.textAlignment = NSTextAlignmentCenter;
                }

                label.text = labelString;
                [self addSubview:label];
            }
        }

    }

    for (UIView* view in self.subviews) {
        if ([view isMemberOfClass:[UIImageView class]]) {
            [self bringSubviewToFront:view]; // bring thumb view to front
        }
    }

    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    CGRect thumbRect = [self thumbRectForBounds:self.bounds trackRect:trackRect value:0];
    CGSize thumbSize = thumbRect.size;

    UIView* firstSpacerView = self.stepImageSpacerViews.firstObject;
    GCXSteppedSliderImageView* firstStepImageView = self.stepImageViews.firstObject;
    GCXSteppedSliderImageView* lastStepImageView = self.stepImageViews.lastObject;
    [firstSpacerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.greaterThanOrEqualTo(@(1));
        make.left.equalTo(firstStepImageView.superview.mas_right).with.priority(1000);
    }];

    UIView* lastSpacerView = self.stepImageSpacerViews.lastObject;
    [lastSpacerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(lastStepImageView.superview.mas_left).with.priority(1000);
    }];

    for (UIView* spacerView in self.stepImageSpacerViews) {
        NSUInteger index = [self.stepImageSpacerViews indexOfObject:spacerView];
        [spacerView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (index > 0) {
                make.width.equalTo(firstSpacerView.mas_width);
            }
            make.top.equalTo(self.mas_top);
            make.height.equalTo(@(1));
        }];
    }

    for (GCXSteppedSliderImageView* stepImageView in self.stepImageViews) {
        NSUInteger index = [self.stepImageViews indexOfObject:stepImageView];

        [stepImageView.superview mas_updateConstraints:^(MASConstraintMaker *make) {

            [stepImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                CGSize size = CGSizeZero;
                if ([self.delegate respondsToSelector:@selector(steppedSlider:sizeForStepImageOfValue:)]) {
                    size = [self.delegate steppedSlider:self sizeForStepImageOfValue:[self.stepValues objectAtIndex:index]];
                } else {
                    size = GCXSteppedSliderImageViewDefaultStepSize;
                }
                make.width.equalTo(@(size.width));
                make.height.equalTo(@(size.height));
                make.centerX.equalTo(stepImageView.superview.mas_centerX);
                make.centerY.equalTo(stepImageView.superview.mas_centerY);
            }];

            if (index == 0) {
                make.left.equalTo(self.mas_left);//.offset(thumbSize.width/2);
            } else if (index == self.stepImageViews.count - 1) {
                make.right.equalTo(self.mas_right);//.offset(-(thumbSize.width / 4));
            } else {
                UIView* leftSpacerView = [self.stepImageSpacerViews objectAtIndex:index - 1];
                UIView* rightSpacerView = [self.stepImageSpacerViews objectAtIndex:index];
                make.left.lessThanOrEqualTo(leftSpacerView.mas_right).with.priority(999);
                make.right.lessThanOrEqualTo(rightSpacerView.mas_left).with.priority(999);
            }

            make.centerY.equalTo(self.mas_centerY);

            make.width.equalTo(@(thumbSize.width));
            make.height.equalTo(@(thumbSize.height));

            if ([self.delegate respondsToSelector:@selector(steppedSlider:labelStringForValue:)]) {
                NSNumber* labelIndex = @(index);
                UILabel* label = self.stepLabelViews[labelIndex];

                [label mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.lessThanOrEqualTo(self.mas_width).dividedBy(self.stepValues.count);

                    if (labelIndex.integerValue == 0) {
                        make.left.equalTo(self.mas_left);
                    } else if (labelIndex.integerValue == self.stepLabelViews.count - 1) {
                        make.right.equalTo(self.mas_right);
                    } else {
                        make.centerX.equalTo(stepImageView.superview.mas_centerX);
                    }
                    make.bottom.equalTo(self.mas_bottom);
                }];
            }
        }];
    }

    [self.trackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(2.0));
        make.left.equalTo(firstStepImageView.superview.mas_centerX).with.priorityLow();
        make.right.equalTo(lastStepImageView.superview.mas_centerX).with.priorityLow();
        make.centerY.equalTo(firstSpacerView.superview.mas_centerY);
    }];

    [super updateConstraints];
}

- (void)trackTapped:(UITapGestureRecognizer*)gestureRecognizer {
    CGPoint touchPoint = [gestureRecognizer locationInView:self];
    CGFloat width = self.frame.size.width;
    CGFloat value = touchPoint.x / width;
    NSUInteger index = (NSUInteger)(self.stepValues.count * value);
    [self selectIndex:index];
}

- (NSUInteger)indexFromValue:(CGFloat)value {
    return (NSUInteger)(value + 0.5);
}

- (void)valueChanged:(GCXSteppedSlider*)slider {
    NSUInteger index = [self indexFromValue:slider.value];
    [self selectIndex:index];
}

- (void)selectIndex:(NSUInteger)index {
    id value = nil;
    if (index < self.stepValues.count) {
        value = self.stepValues[index];
    } else {
        return;
    }

    if ([value isEqual:self.currentValue]) {
        return;
    }

    self.currentValue = value;

    if (self.disabledStepValues.count == 0 || [self.disabledStepValues indexOfObject:value] == NSNotFound) {
        [super setValue:index animated:NO];
        if (self.delegate && [self.delegate respondsToSelector:@selector(steppedSlider:valueChanged:)]) {
            [self.delegate steppedSlider:self valueChanged:value];
        }
        self.previousIndex = index;
    } else {
        [super setValue:self.previousIndex animated:NO];
    }
}

@end
