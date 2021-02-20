//
//  UIView+LayoutHelper.h
//  gf_iphone
//
//  Created by Highway on 2017/8/31.
//  Copyright © 2017年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LayoutHelper)

/**
 * frame.origin.x
 */
@property (nonatomic) CGFloat x;

/**
 * frame.origin.y
 */
@property (nonatomic) CGFloat y;

/**
 * frame.size.width;
 */
@property (nonatomic) CGFloat width;

/**
 *  frame.size.height
 */
@property (nonatomic) CGFloat height;

/**
 *  center.x
 */
@property (nonatomic) CGFloat xCenter;

/**
 *  center.y
 */
@property (nonatomic) CGFloat yCenter;

/**
 *  frame.origin
 */
@property (nonatomic) CGPoint origin;

/**
 *  frame.size
 */
@property (nonatomic) CGSize size;

/**
 * CGRectGetMaxX
 */
@property (nonatomic, readonly) CGFloat maxX;

/**
 *  CGRectGetMaxY
 */
@property (nonatomic, readonly) CGFloat maxY;

@end
