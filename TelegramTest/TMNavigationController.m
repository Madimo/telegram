// DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
// Version 2, December 2004
//
// Copyright (C) 2013 Ilija Tovilo <support@ilijatovilo.ch>
//
// Everyone is permitted to copy and distribute verbatim or modified
// copies of this license document, and changing it is allowed as long
// as the name is changed.
//
// DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
// TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
//
// 0. You just DO WHAT THE FUCK YOU WANT TO.

//
//  ITNavigationView.m
//  ITNavigationView
//
//  Created by Ilija Tovilo on 2/27/13.
//  Copyright (c) 2013 Ilija Tovilo. All rights reserved.
//
#import "TMNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "ConnectionStatusViewControllerView.h"
#import "HackUtils.h"
#import "TGAnimationBlockDelegate.h"
#define kDefaultAnimationDuration 0.1
#define kSlowAnimationMultiplier 4
#define kDefaultTimingFunction [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]

@interface TMNavigationController ()

@property (nonatomic, strong) NSView *containerView;


@property (nonatomic, strong) NSView *animationView;
@property (strong) NSImageView *oldCachedImageView;
@property (strong) NSImageView *cachedImageView;
@property (nonatomic,strong) NSMutableArray *delegates;

@property (nonatomic,strong) TGAnimationBlockDelegate *odelegate;
@property (nonatomic,strong) TGAnimationBlockDelegate *ndelegate;

@end

@implementation TMNavigationController
@synthesize isLocked = _isLocked;

#pragma mark -
#pragma mark Initialise


- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initNavigationController];
    }
    return self;
}

static const int navigationHeight = 48;
static const int navigationOffset = 48;


- (void)initNavigationController {
    self.viewControllerStack = [[NSMutableArray alloc] init];
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    _delegates = [[NSMutableArray alloc] init];
}

- (void) loadView {
    [super loadView];
    
//    [self.view setWantsLayer:YES];
   // [self.view setBackgroundColor:[NSColor redColor]];
    
    
    
    
   
    
    self.containerView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.containerView setAutoresizesSubviews:YES];
    [self.containerView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.containerView setWantsLayer:YES];
    
    self.containerView.layer.backgroundColor = [NSColor clearColor].CGColor;
    [self.view addSubview:self.containerView];
    
    int connectingHeight = navigationOffset-navigationHeight;
    
    
    // [self.containerView addSubview:_connectionController];
    
    self.nagivationBarView = [[TMNavigationBar alloc] initWithFrame:NSMakeRect(0, self.view.bounds.size.height-navigationOffset, self.view.bounds.size.width, navigationHeight)];
    
//    [self.nagivationBarView setWantsLayer:YES];
//    [self.nagivationBarView.layer setBackgroundColor:NSColorFromRGBWithAlpha(0xffffff, 0.9).CGColor];
    [self.view addSubview:self.nagivationBarView];
}


-(void)addDelegate:(id<TMNavagationDelegate>)delegate {
    if([_delegates indexOfObject:delegate] == NSNotFound)
        [_delegates addObject:delegate];
}

-(void)removeDelegate:(id<TMNavagationDelegate>)delegate {
    [_delegates removeObject:delegate];
}

#pragma mark -
#pragma mark Setters & Getters


- (void)goBackWithAnimation:(BOOL)animated {
    if(self.viewControllerStack.count < 2 || _isLocked)
        return;
    
    TMViewController *controller = [self.viewControllerStack objectAtIndex:self.viewControllerStack.count-2];
    
    TMViewController *oc = [self.viewControllerStack lastObject];
    
    
    [self.viewControllerStack removeObject:oc];
    
    
    self.animationStyle = animated ? TMNavigationControllerStylePop : TMNavigationControllerStyleNone;
    self.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self setCurrentViewController:controller withAnimation:animated];
}

- (void)pushViewController:(TMViewController *)viewController animated:(BOOL)animated {
    if(_isLocked)
        return;
    
    
    if([self.viewControllerStack indexOfObject:viewController] == NSNotFound) {
        [self.viewControllerStack addObject:viewController];
        [viewController setNavigationViewController:self];
    } else {
        [self.viewControllerStack removeObjectAtIndex:[self.viewControllerStack indexOfObject:viewController]];
        [self.viewControllerStack addObject:viewController];
    }
    
    self.animationStyle = animated ? TMNavigationControllerStylePush : TMNavigationControllerStyleNone;
    self.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self setCurrentViewController:viewController withAnimation:animated];
}

- (void)clear {
    [self.viewControllerStack removeAllObjects];
}

- (TMViewController *)popViewControllerAnimated:(BOOL)animated {
    return nil;
    if(_isLocked)
        return nil;
    
    if(self.viewControllerStack.count) {
        TMViewController *viewController = [self.viewControllerStack objectAtIndex:0];
        [self.viewControllerStack removeAllObjects];
        [self.viewControllerStack addObject:viewController];
        
        self.animationStyle = animated ? TMNavigationControllerStylePop : TMNavigationControllerStyleNone;
        self.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [self setCurrentViewController:viewController withAnimation:animated];
        return viewController;
    }
    return nil;
}

- (BOOL)isLocked {
    return _isLocked;
}

- (NSTimeInterval)animationDuration {
    
    return 2.2;
    
    if (!_animationDuration) {
        return kDefaultAnimationDuration;
    }
    
    
    return _animationDuration;
}

- (CAMediaTimingFunction *)timingFunction {
    if (!_timingFunction) {
        return kDefaultTimingFunction;
    }
    
    return _timingFunction;
}

- (NSView *)animationView {
    if (!_animationView) {
        _animationView = [[NSView alloc] initWithFrame:self.containerView.bounds];
        
        self.oldCachedImageView = [[NSImageView alloc] initWithFrame:self.containerView.bounds];
        [_animationView addSubview:self.oldCachedImageView];
        self.oldCachedImageView.wantsLayer = YES;
        
        self.cachedImageView = [[NSImageView alloc] initWithFrame:self.containerView.bounds];
        [_animationView addSubview:self.cachedImageView];
        self.cachedImageView.wantsLayer = YES;
        
        self.animationView.wantsLayer = YES;
    }
    
    return _animationView;
}

- (void)pop_animationDidStart:(POPAnimation *)anim {
    NSView *view = [self.containerView.subviews lastObject];
    [view.layer setOpacity:1];
}

- (void)setCurrentViewController:(TMViewController *)newViewController withAnimation:(BOOL)animationFlag {
    if (_isLocked) {
        ELog(@"Navigtion Controller is locked");
        return;
    }
    
    [_delegates enumerateObjectsUsingBlock:^(id<TMNavagationDelegate> obj, NSUInteger idx, BOOL *stop) {
        if([obj respondsToSelector:@selector(willChangedController:)])
            [obj willChangedController:newViewController];
    }];
    
    BOOL isNavigationBarHiddenOld = self.nagivationBarView.isHidden;
    if(newViewController.isNavigationBarHidden != isNavigationBarHiddenOld) {
        if(newViewController.isNavigationBarHidden) {
            [self.nagivationBarView setHidden:YES];
        } else {
            [self.nagivationBarView setHidden:NO];
        }
    }
    
    __block TMViewController *oldViewController = self.currentController;
    
    
    NSArray *f = [HackUtils findElementsByClass:@"TMSearchTextField" inView:oldViewController.view];
    
    if(f.count > 0) {
        [f enumerateObjectsUsingBlock:^(TMSearchTextField *obj, NSUInteger idx, BOOL *stop) {
            [obj endEditing];
        }];
    }
    
    
    __block TMView *oldView = oldViewController.view;
    __block TMView *newView = newViewController.view;
    
    
    
    if(oldView == newView) {
        [oldViewController viewWillDisappear:NO];
        [newViewController viewWillAppear:NO];
        [oldViewController viewDidDisappear:NO];
        [newViewController viewWillAppear:NO];
        [newViewController becomeFirstResponder];
        
       return;
    }
    
    
    self.currentController = newViewController;
    
    // Make view resize properly
    newView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    BOOL isAnimate = !(!newView || !animationFlag);

    [self.nagivationBarView setLeftView:newViewController.leftNavigationBarView animated:NO];
    [self.nagivationBarView setCenterView:newViewController.centerNavigationBarView animated:NO];
    [self.nagivationBarView setRightView:newViewController.rightNavigationBarView animated:NO];
    
   // if(newView.superview) {
      //  [newView removeFromSuperview];
  //  }
    
    if(!newView.wantsLayer) {
        [newView setWantsLayer:YES];
        [newView.layer disableActions];
    }
    
    
    DLog(@"navigation controller isAnimate = %@", isAnimate ? @"YES" : @"NO");
    assert([NSThread isMainThread]);
    
    
    if(newViewController.isNavigationBarHidden) {
        [newView setFrameSize:NSMakeSize(self.view.bounds.size.width, self.view.bounds.size.height)];
    } else {
        [newView setFrameSize:NSMakeSize(self.view.bounds.size.width, self.view.bounds.size.height - navigationOffset)];
    }
//
    
    if (!isAnimate) {
        // Add the new view
        [oldView removeFromSuperview];
        [newView removeFromSuperview];
        [newView.layer setOpacity:1];
        
        [newView setHidden:NO];
        
        [oldViewController viewWillDisappear:NO];
        [newViewController viewWillAppear:NO];
        [self.containerView addSubview:newView];
        
        [oldViewController viewDidDisappear:NO];
        [newViewController viewDidAppear:NO];
        
        [newViewController becomeFirstResponder];
        
        [_delegates enumerateObjectsUsingBlock:^(id<TMNavagationDelegate> obj, NSUInteger idx, BOOL *stop) {
            if([obj respondsToSelector:@selector(didChangedController:)])
                [obj didChangedController:newViewController];
        }];
        
    } else {
        // Animate
        
        _isLocked = YES;
        
      //  [oldView.layer setOpacity:1];
      //  [newView.layer setOpacity:0];
        
     
        [newView.layer removeAllAnimations];
        [oldView.layer removeAllAnimations];
        
        
        [newView setHidden:NO];
        
        
        
       
        newView.layer.backgroundColor = [NSColor whiteColor].CGColor;
        
    
        float duration = 0.25;
        
        [oldViewController viewWillDisappear:NO];
        [newViewController viewWillAppear:NO];
        
        float animOldFrom,animOldTo,animNewTo,animNewFrom = 0;
        
        CAMediaTimingFunction *timingFunction;
        
        switch (self.animationStyle) {
            case TMNavigationControllerStylePush: {
                
                animNewFrom = self.containerView.bounds.size.width;
                animNewTo = 0;
                
                animOldFrom = 0;
                animOldTo = - roundf(self.containerView.bounds.size.width/3);
                
              //  anim2From = roundf(self.containerView.bounds.size.width );
                
                timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                
                [self.containerView addSubview:newView positioned:NSWindowAbove relativeTo:oldView];

            }
                break;
            case TMNavigationControllerStylePop: {
                
                
                animNewFrom = - roundf(self.containerView.bounds.size.width/3);
                animNewTo = 0;
                
                animOldFrom = 0;
                animOldTo = self.containerView.bounds.size.width;
                timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                
                [self.containerView addSubview:newView positioned:NSWindowBelow relativeTo:oldView];
                
                break;
            }
                
            default:
                break;
        }
        
        
        __block int two = 2;

        __block dispatch_block_t block = ^{
            
            two--;
            if(two > 0)
                return;
            
            
            
            _isLocked = NO;
            
            [_delegates enumerateObjectsUsingBlock:^(id<TMNavagationDelegate> obj, NSUInteger idx, BOOL *stop) {
                if([obj respondsToSelector:@selector(didChangedController:)])
                    [obj didChangedController:newViewController];
            }];
        };
        
        
        _odelegate = [[TGAnimationBlockDelegate alloc] initWithLayer:oldView.layer];
        
        _odelegate.removeLayerOnCompletion = YES;
        
        
        [_odelegate setCompletion:^(BOOL finished) {
            
            [oldView setHidden:YES];
            [oldView removeFromSuperview];
            [oldView setFrameOrigin:NSMakePoint(0, 0)];
            [oldViewController viewDidDisappear:NO];
            block();
            
        }];
        
        [CATransaction begin];
        
    
        
        
        if (floor(NSAppKitVersionNumber) <= 1187) {
            POPBasicAnimation *oldViewPositionAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
            
            oldViewPositionAnimation.fromValue = @(animOldFrom);
            oldViewPositionAnimation.toValue = @(animOldTo);
            oldViewPositionAnimation.duration = duration;
            oldViewPositionAnimation.delegate = _odelegate;
            oldViewPositionAnimation.timingFunction = timingFunction;
            oldViewPositionAnimation.removedOnCompletion = true;
            
            [oldView.layer pop_addAnimation:oldViewPositionAnimation forKey:@"position"];
            
            
        } else {
            CABasicAnimation *oldViewPositionAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
            oldViewPositionAnimation.fromValue = @(animOldFrom);
            oldViewPositionAnimation.toValue = @(animOldTo);
            oldViewPositionAnimation.duration = duration;
            oldViewPositionAnimation.delegate = _odelegate;
            oldViewPositionAnimation.timingFunction = timingFunction;
            oldViewPositionAnimation.removedOnCompletion = true;
            oldViewPositionAnimation.fillMode = kCAFillModeRemoved;
            
            [oldView.layer addAnimation:oldViewPositionAnimation forKey:@"position"];
            
            oldView.layer.position = CGPointMake(animOldTo, 0.0f);
        }
        
        _ndelegate = [[TGAnimationBlockDelegate alloc] initWithLayer:newView.layer];
    
        
        [_ndelegate setCompletion:^(BOOL finished) {
            [newView setFrameOrigin:NSMakePoint(0, 0)];
            [newViewController viewDidAppear:NO];
            block();
        }];
        
        
        
        
        if (floor(NSAppKitVersionNumber) <= 1187) {
            POPBasicAnimation *newViewPositionAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
            newViewPositionAnimation.fromValue = @(animNewFrom);
            newViewPositionAnimation.toValue = @(animNewTo);
            newViewPositionAnimation.duration = duration;
            newViewPositionAnimation.delegate = _ndelegate;
            newViewPositionAnimation.timingFunction = timingFunction;
            [newView.layer pop_addAnimation:newViewPositionAnimation forKey:@"position"];
        } else {
            CABasicAnimation *newViewPositionAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
            newViewPositionAnimation.fromValue = @(animNewFrom);
            newViewPositionAnimation.toValue = @(animNewTo);
            newViewPositionAnimation.duration = duration;
            newViewPositionAnimation.delegate = _ndelegate;
            newViewPositionAnimation.timingFunction = timingFunction;
            [newView.layer addAnimation:newViewPositionAnimation forKey:@"position"];
        }

        
        [CATransaction commit];
       
        
    }
}


- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished {
    
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag  {
    
}

- (BOOL)enableShiftModifier {
    return YES;
}


#pragma mark -
#pragma mark Helpers

- (NSRect)rectForViewWithAnimationStyle:(TMNavigationControllerAnimationStyle)animationStyle oldView:(BOOL)oldRect{
    NSRect modifiedRect = self.containerView.bounds;
    int reverser = (oldRect)?-1:1;
    
    switch (animationStyle) {
        case TMNavigationControllerStylePush:
            modifiedRect.origin.x = modifiedRect.size.width * reverser;
            break;
        case TMNavigationControllerStylePop:
            modifiedRect.origin.x = -modifiedRect.size.width * reverser;
            break;
        default:
            break;
    }
    
//    NSString *str = [[NSString alloc] init]
    
    return modifiedRect;
}

- (NSImage *)imageOfView:(NSView *)view {
    if(!view.wantsLayer)
        view.wantsLayer = YES;
    
    int width = view.bounds.size.width;
    int height = view.bounds.size.height;

    CGContextRef imageContextRef =  CGBitmapContextCreate(0, width, height, 8, width * 4, [NSColorSpace genericRGBColorSpace].CGColorSpace, kCGBitmapAlphaInfoMask);
    
    [view.layer renderInContext:imageContextRef];

    CGImageRef imageRef = CGBitmapContextCreateImage(imageContextRef);
    NSImage *image = [[NSImage alloc] initWithCGImage:imageRef size:NSMakeSize(width, height)];
    CFRelease(imageRef);
    CFRelease(imageContextRef);
    view.wantsLayer = NO;
    
    return image;
    
    NSBitmapImageRep *rep = [view bitmapImageRepForCachingDisplayInRect:self.containerView.bounds];
    [view cacheDisplayInRect:self.containerView.bounds toBitmapImageRep:rep];
    return [[NSImage alloc] initWithCGImage:[rep CGImage] size:view.bounds.size];
}




//_isLocked = YES;
//TMView *oldView = self.currentView;
//TMView *newView = currentView;
//self.currentView = newView;
//
//[oldView setWantsLayer:YES];
//[newView setWantsLayer:YES];
//
//[newView.layer setOpaque:YES];
//[newView.layer setDrawsAsynchronously:YES];
//[oldView.layer setOpaque:YES];
//[oldView.layer setDrawsAsynchronously:YES];
//
//
//if(currentController.isNavigationBarHidden) {
//    [newView setFrameSize:NSMakeSize(self.view.bounds.size.width, self.view.bounds.size.height)];
//} else {
//    [newView setFrameSize:NSMakeSize(self.view.bounds.size.width, self.view.bounds.size.height - self.nagivationBarView.bounds.size.height)];
//}
//
//[self.containerView addSubview:newView];
//
//CGImageRef oldImage = [self imageOfView:oldView];
//CGImageRef newImage = [self imageOfView:newView];
//
//[newView setHidden:YES];
//
//dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    
//    NSImage *image;
//    NSSize size;
//    
//    if(oldImage && newImage) {
//        size = NSMakeSize(self.view.bounds.size.width * 2, self.view.bounds.size.height);
//        CGContextRef ctx = CGBitmapContextCreate(NULL, size.width, size.height,
//                                                 8, size.width * 4, CGImageGetColorSpace(oldImage),
//                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
//        
//        CGContextDrawImage(ctx, oldView.bounds, oldImage);
//        CGContextDrawImage(ctx, CGRectMake(self.view.bounds.size.width, 0, newView.bounds.size.width, newView.bounds.size.height), newImage);
//        
//        CGImageRef result = CGBitmapContextCreateImage(ctx);
//        
//        image = [[NSImage alloc] initWithCGImage:result size:size];
//        CGContextRelease(ctx);
//        CGImageRelease(result);
//    }
//    
//    if(oldImage)
//        CGImageRelease(oldImage);
//    
//    
//    if(newImage)
//        CGImageRelease(newImage);
//    
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.cacheImageView setFrameSize:size];
//        self.cacheImageView.image = image;
//        [self.cacheImageView setHidden:NO];
//        [newView setHidden:NO];
//        
//        [oldView removeFromSuperview];
//        float duration = 0.3;
//        
//        POPBasicAnimation *positionAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
//        positionAnimation.toValue = @(0);
//        positionAnimation.duration = duration;
//        positionAnimation.toValue = @(-self.view.frame.size.width);
//        positionAnimation.completionBlock = ^(POPAnimation *anim, BOOL finish) {
//            [self.cacheImageView setHidden:YES];
//            self.cacheImageView.image = nil;
//            
//            [oldController viewDidDisappear:NO];
//            [self.currentController viewDidAppear:NO];
//            
//            _isLocked = NO;
//        };
//        
//        [self.cacheImageView.layer pop_addAnimation:positionAnimation forKey:@"position"];
//    });
//    
//});
@end
