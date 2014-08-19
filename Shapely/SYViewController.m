//
//  SYViewController.m
//  Shapely
//
//  Created by Hoan Tran on 8/12/14.
//  Copyright (c) 2014 Bluepego Consulting. All rights reserved.
//

#import "SYViewController.h"
#import "SYShapeView.h"

#define kStrokeWidth            1.0f

@interface SYViewController ()
{
    SYShapeView *lastView;
    NSArray *colors;
    NSArray *strokeWidths;
}
@property (readonly, nonatomic) NSArray *colors;
@property (readonly, nonatomic) NSArray *strokeWidths;

- (IBAction)moveShape:(UIPanGestureRecognizer *)gesture;
- (IBAction)resizeShape:(UIPinchGestureRecognizer *)gesture;
@end

@implementation SYViewController

- (IBAction)moveShape:(UIPanGestureRecognizer *)gesture
{
    SYShapeView *shapeView = (SYShapeView *)gesture.view;
    CGPoint dragDelta = [gesture translationInView:shapeView.superview];
    CGAffineTransform move;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            move = CGAffineTransformMakeTranslation(dragDelta.x, dragDelta.y);
            shapeView.transform = move;
            break;
            
        case UIGestureRecognizerStateEnded:
            shapeView.transform = CGAffineTransformIdentity;
            shapeView.frame = CGRectOffset(shapeView.frame, dragDelta.x, dragDelta.y);
            break;
            
        default:
            shapeView.transform = CGAffineTransformIdentity;
            break;
    }
}

- (IBAction)resizeShape:(UIPinchGestureRecognizer *)gesture
{
    SYShapeView *shapeView = (SYShapeView *)gesture.view;
    CGFloat pinchScale = gesture.scale;
    CGAffineTransform zoom;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            zoom = CGAffineTransformMakeScale(pinchScale, pinchScale);
            shapeView.transform = zoom;
            break;
            
        case UIGestureRecognizerStateEnded:
            shapeView.transform = CGAffineTransformIdentity;
            CGRect frame = shapeView.frame;
            CGFloat xDelta = frame.size.width * pinchScale - frame.size.width;
            CGFloat yDelta = frame.size.height * pinchScale - frame.size.height;
            frame.size.width += xDelta;
            frame.size.height += yDelta;
            frame.origin.x -= xDelta/2;
            frame.origin.y -= yDelta/2;
            shapeView.frame = frame;
            [shapeView setNeedsDisplay];
            break;
            
        default:
            shapeView.transform = CGAffineTransformIdentity;
            break;
    }
}

- (NSArray*) colors
{
    if (colors == nil) {
        colors = @[ UIColor.redColor, UIColor.greenColor,
                    UIColor.blueColor, UIColor.yellowColor,
                    UIColor.purpleColor, UIColor.orangeColor,
                    UIColor.grayColor, UIColor.brownColor ];
    }
    return colors;
}

- (NSArray*) strokeWidths
{
    if (strokeWidths == nil) {
        strokeWidths = @[@(kStrokeWidth*1), // skip
                         @(kStrokeWidth*2), // square
                         @(kStrokeWidth*9), // rect
                         @(kStrokeWidth*2), // circle
                         @(kStrokeWidth*1), // oval
                         @(kStrokeWidth*2), // triangle
                         @(kStrokeWidth*5), // star
                         @(kStrokeWidth*1)  // fractal
                         ];
    }
    
    return strokeWidths;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    NSLog(@"viewDidLoad");
    lastView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addShape:(id)sender
{
//    NSLog(@"addShape");
    NSLog(@"%@ whatever", NSStringFromSelector(_cmd));
    
//    if (lastView != nil) {
//        [lastView removeFromSuperview];
//        lastView = nil;
//    }
    
    SYShapeView *shapeView = [[SYShapeView alloc]
                                initWithShape:[sender tag]
                              withStrokeWidth:[[self.strokeWidths objectAtIndex:[sender tag]] floatValue]];
    
    shapeView.color = [self.colors objectAtIndex:arc4random_uniform(self.colors.count)];
    [self.view addSubview:shapeView];
    lastView = shapeView;
    
    CGRect shapeFrame = shapeView.frame;
    CGRect safeRect = CGRectInset(self.view.bounds,
                                  shapeFrame.size.width,
                                  shapeFrame.size.height);
    CGPoint newLoc = CGPointMake(safeRect.origin.x
                                 +arc4random_uniform(safeRect.size.width),
                                 safeRect.origin.y
                                 +arc4random_uniform(safeRect.size.height));
    shapeView.center = newLoc;
    
    // adding pan gesture
    UIPanGestureRecognizer *panRecognizer;
    panRecognizer = [[ UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveShape:)];
    panRecognizer.maximumNumberOfTouches = 1;
    [shapeView addGestureRecognizer:panRecognizer];
    
    // adding pinch gesture
    UIPinchGestureRecognizer *pinchGesture;
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(resizeShape:)];
    [shapeView addGestureRecognizer:pinchGesture];
    
    // adding animation
    shapeFrame = shapeView.frame;
    CGRect buttonFrame = ((UIView*)sender).frame;
    shapeView.frame = buttonFrame;
    [UIView     animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{shapeView.frame = shapeFrame; }
                         completion:nil];
    
}
@end
