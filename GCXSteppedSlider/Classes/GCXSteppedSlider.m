//
//  GCXSteppedSlider.m
//
//  Created by Timo Josten on 02/06/16.
//  Copyright © 2016 grandcentrix. All rights reserved.
//

#import "GCXSteppedSlider.h"

@implementation GCXSteppedSliderImageView
@end

static CGSize GCXSteppedSliderImageViewDefaultStepSize;

@interface GCXSteppedSlider ()

@property (nonatomic, strong, nonnull) NSArray* stepValues;
@property (nonatomic, assign) NSUInteger previousIndex;
@property (nonatomic, weak, nullable) UIView* trackView;
@property (nonatomic, strong, nullable) NSArray<GCXSteppedSliderImageView*>* stepImageViews;

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
        for (NSUInteger i = 0; i < stepValues.count; i++) {
            GCXSteppedSliderImageView* stepImageView = [[GCXSteppedSliderImageView alloc] initWithImage:nil];
            stepImageView.contentMode = UIViewContentModeScaleAspectFit;
            stepImageView.clipsToBounds = YES;
            [self addSubview:stepImageView];
            [stepImageViews addObject:stepImageView];
        }

        self.stepImageViews = [stepImageViews copy];

        UIView* trackView = [[UIView alloc] initWithFrame:[self trackViewFrame]];
        [self addSubview:trackView];
        [self sendSubviewToBack:trackView];
        self.trackView = trackView;

        [self addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];

        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(trackTapped:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGestureRecognizer];
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

    for (UIView* view in self.subviews) {
        if ([view isKindOfClass:[GCXSteppedSliderImageView class]]) {
            view.tintColor = signatureColor;
        }
    }
    self.trackView.backgroundColor = signatureColor;

    _signatureColor = signatureColor;
}

# pragma mark Internals

- (void)setValue:(float)value animated:(BOOL)animated {
    NSUInteger index = [self indexFromValue:value];
    [self selectIndex:index];
}

- (CGRect)trackViewFrame {
    // the frame for the "track" of the slider needs to be slightly shorter than the slider view itself,
    // so it does not peak left and right from the first and last step image.
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    CGRect thumbRect = [self thumbRectForBounds:self.bounds trackRect:trackRect value:0];
    CGSize thumbSize = thumbRect.size;
    CGFloat padding = thumbSize.width * 0.5;
    return CGRectMake(padding, (self.frame.size.height * 0.5) - 1 /* we have to substract 1 to have the track exactly centered in the view */, self.frame.size.width - padding * 2, 2.0);
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect trackRect = [self trackRectForBounds:self.bounds];
    CGRect thumbRect = [self thumbRectForBounds:self.bounds trackRect:trackRect value:0];
    CGSize thumbSize = thumbRect.size;
    CGFloat spaceBetweenButtons = ((CGFloat)self.frame.size.width - thumbSize.width) / ((CGFloat)self.stepValues.count - 1);

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
            
            CGRect frame = CGRectZero;
            if ([self.delegate respondsToSelector:@selector(steppedSlider:sizeForStepImageOfValue:)]) {
                frame.size = [self.delegate steppedSlider:self sizeForStepImageOfValue:value];
            } else {
                frame.size = GCXSteppedSliderImageViewDefaultStepSize;
            }
            stepImageView.frame = frame;
            
            CGFloat x = (index * spaceBetweenButtons) + (thumbSize.width * 0.5);
            CGFloat y = self.frame.size.height * 0.5;
            CGPoint point = CGPointMake(x, y);
            stepImageView.center = point;
            [self bringSubviewToFront:stepImageView];
        }
    }

    for (UIView* view in self.subviews) {
        if ([view isMemberOfClass:[UIImageView class]]) {
            [self bringSubviewToFront:view]; // bring thumb view to front
        }
    }

    self.trackView.frame = [self trackViewFrame];
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
