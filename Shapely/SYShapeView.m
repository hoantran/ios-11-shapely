//
//  SYShapeView.m
//  Shapely
//
//  Created by Hoan Tran on 8/12/14.
//  Copyright (c) 2014 Bluepego Consulting. All rights reserved.
//

#import "SYShapeView.h"


#define kInitialDimension       100.0f
#define kInitialAlternateHeight (kInitialDimension/2)
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

const int kSYShapeViewMaxLevels = 6;
const int kSYShapeViewInitBendAngle = 5;
const int kSYShapeViewInitBranchAngle = 42;
const float kSYShapeViewTrunkRatio = 0.05f;
const float kSYShapeViewBranchRatio = 0.5f;
const float kSYShapeViewHeightScale = 3.0f;


@interface SYShapeView ()
{
    ShapeSelector   shape;
    int             shapeStrokeWidth;
}
@property (readonly,nonatomic) UIBezierPath *path;
- (void) drawFern:(UIBezierPath*)path withLastPoint:(CGPoint)point withAngle:(float)angle withRandom:(float)randomNumber withLevel:(int)level;

@end


@implementation SYShapeView

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
//    NSLog(@"drawRect");
    UIBezierPath *path = self.path;
    [[[UIColor blackColor] colorWithAlphaComponent:0.3] setFill];
    [path fill];
    [self.color setStroke];
    [path stroke];
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    [self setNeedsDisplay];
}


- (id)initWithShape:(ShapeSelector)theShape withStrokeWidth:(float)strokeWidth
{
//    NSLog(@"initWithShape");
    shapeStrokeWidth = strokeWidth;
    CGRect initRect = CGRectMake(0,0,kInitialDimension,kInitialDimension);
    if (theShape==kRectangleShape || theShape==kOvalShape)
        initRect.size.height = kInitialAlternateHeight;
    
    self = [super initWithFrame:initRect];
    if (self!=nil)
    {
        shape = theShape;
        self.opaque = NO;
        self.backgroundColor = nil;
        self.clearsContextBeforeDrawing = YES;
    }
    return self;
}

- (UIBezierPath*)path
{
//    NSLog(@"path");
    CGRect bounds = self.bounds;
    CGRect rect = CGRectInset(bounds,shapeStrokeWidth/2+1,shapeStrokeWidth/2+1);
    
    UIBezierPath *path;
    switch (shape) {
        case kSquareShape:
        case kRectangleShape:
            path = [UIBezierPath bezierPathWithRect:rect];
            break;
            
        case kCircleShape:
        case kOvalShape:
            path = [UIBezierPath bezierPathWithOvalInRect:rect];
            break;
            
        case kTriangleShape:
            path = [UIBezierPath bezierPath];
            CGPoint point = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
            [path moveToPoint:point];
            point = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
            [path addLineToPoint:point];
            point = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
            [path addLineToPoint:point];
            [path closePath];
            break;
            
        case kStarShape:
            path = [UIBezierPath bezierPath];
            point = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
            float angle = M_PI*2/5;
            float distance = rect.size.width*0.38f;
            [path moveToPoint:point];
            for (NSUInteger arm=0; arm<5; arm++) {
                point.x += cosf(angle)*distance;
                point.y += sinf(angle)*distance;
                [path addLineToPoint:point];
                angle -= M_PI*2/5;
                point.x += cosf(angle)*distance;
                point.y += sinf(angle)*distance;
                [path addLineToPoint:point];
                angle += M_PI*4/5;
            }
            [path closePath];
            break;
            
        case kFernShape:
//            path = [self initiateDrawFern:path withRect:rect];

            path = [UIBezierPath bezierPath];
            point = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
            [path moveToPoint:point];
            [self drawFern:path withLastPoint:point withAngle:-M_PI_2 withRandom:CGRectGetMaxY(rect)*kSYShapeViewHeightScale withLevel:kSYShapeViewMaxLevels];
            break;
            
        default:
            // TODO: add cases for remaining shapes
            break;
    }
    path.lineWidth = shapeStrokeWidth;
    path.lineJoinStyle = kCGLineJoinRound;
    return path;
}

/*
 * algorithm for fractal fern from:
 * http://krazydad.com/bestiary/bestiary_fern.html
 */
- (void) drawFern:(UIBezierPath*)path withLastPoint:(CGPoint)point withAngle:(float)angle withRandom:(float)randomNumber withLevel:(int)level
{
    float trunkRatio = kSYShapeViewTrunkRatio;
    float bendAngle = DEGREES_TO_RADIANS(kSYShapeViewInitBendAngle);
    float branchAngle = DEGREES_TO_RADIANS(kSYShapeViewInitBranchAngle);
    float antiTrunkRatio = 1 - kSYShapeViewTrunkRatio;
    
    point.x = point.x + randomNumber * trunkRatio * cosf(angle);
    point.y = point.y + randomNumber * trunkRatio * sinf(angle);
//    graphics.lineStyle(level*trunkThick, colors[level], 100);
    [path addLineToPoint:point];
    if (level > 0) {
        angle += bendAngle;
        level--;
        [self        drawFern:path
                withLastPoint:point
                    withAngle:angle-branchAngle
                   withRandom:randomNumber*kSYShapeViewBranchRatio
                    withLevel:level];
        [path moveToPoint:point];
        [self       drawFern:path
               withLastPoint:point
                   withAngle:angle+branchAngle
                  withRandom:randomNumber*kSYShapeViewBranchRatio
                   withLevel:level];
        [path moveToPoint:point];
        [self       drawFern:path
               withLastPoint:point
                   withAngle:angle
                  withRandom:randomNumber*antiTrunkRatio
                   withLevel:level];
    }
}

@end
