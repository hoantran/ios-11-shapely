//
//  SYShapeView.h
//  Shapely
//
//  Created by Hoan Tran on 8/12/14.
//  Copyright (c) 2014 Bluepego Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kSquareShape = 1,
    kRectangleShape,
    kCircleShape,
    kOvalShape,
    kTriangleShape,
    kStarShape,
    kFernShape,
} ShapeSelector;

@interface SYShapeView : UIView

- (id)initWithShape:(ShapeSelector)theShape withStrokeWidth:(float)strokeWidth;
@property (strong,nonatomic) UIColor *color;

@end
