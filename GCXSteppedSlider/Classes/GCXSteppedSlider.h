//
//  GCXSteppedSlider.h
//
//  Created by Timo Josten on 02/06/16.
//  Copyright © 2016 grandcentrix. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCXSteppedSlider;

@protocol GCXSteppedSliderDelegate <NSObject>

@optional
/**
 * Should be implemeneted by the delegate if it wants to be notified about value changes of the slider
 *
 * @param (GCXSteppedSlider*) slider instance
 * @param (id) selected value
 */
- (void)steppedSlider:(GCXSteppedSlider* __nonnull)slider valueChanged:(id __nullable)selectedValue;

@required
/**
 * Must be implemeneted by the delegate and return the UIImage for the stepImage of the given stepValue
 *
 * @return (UIImage*) designated UIImage for the given stepValue
 * @param (GCXSteppedSlider*) slider instance
 * @param (id) stepValue which stepImage needs to be returned
 */
- (UIImage* __nullable)steppedSlider:(GCXSteppedSlider* __nonnull)slider stepImageForValue:(id __nullable)stepValue;

@optional
/**
 * Should be implemeneted by the delegate if it wants to control the stepImages size at the given stepValue
 *
 * @return (CGSize) designated size of stepImage at stepValue
 * @param (GCXSteppedSlider*) slider instance
 * @param (id) stepValue which stepImage's frame can be returned
 */
- (CGSize)steppedSlider:(GCXSteppedSlider* __nonnull)slider sizeForStepImageOfValue:(id __nullable)stepValue;

@end

@interface GCXSteppedSlider : UISlider

/**
 * Signature color (track, step images) of the slider
 */
@property (nonatomic, strong, nullable) UIColor* signatureColor;

/**
 * See <GCXSteppedSliderDelegate>
 */
@property (nonatomic, weak, nullable) id<GCXSteppedSliderDelegate> delegate;

/**
 * Array of available, selectable values with this slider. May contain any objects.
 */
@property (nonatomic, strong, readonly, nonnull) NSArray<id>* stepValues;

/**
 * Array of disabled, non-selectable values with this slider. May contain any objects that exist in stepValues.
 */
@property (nonatomic, strong, nonnull) NSArray<id>* disabledStepValues;

/**
 * Designated initializer
 *
 * @param CGRect initial frame of slider
 * @param NSArray<id> Array of available, selectable values with this slider. May contain any objects.
 * @param id initially selected value, must exist in stepValues
 */
- (instancetype __nonnull)initWithFrame:(CGRect)frame stepValues:(NSArray<id>* __nonnull)stepValues initialStep:(id __nullable)initialStep;

/**
 * Unavailable initializer
 */
- (instancetype __nonnull)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

/**
 * Unavailable initializer
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end

@interface GCXSteppedSliderImageView : UIImageView
@end
