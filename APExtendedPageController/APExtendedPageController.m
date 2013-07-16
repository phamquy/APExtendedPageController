//
//  APExtendedPageController.m
//  APExtendedPageController
//
//  Created by Andrzej on 03.04.2013.
//  Copyright (c) 2013 apuczyk. All rights reserved.
//

#import "APExtendedPageController.h"

@interface APExtendedPageController () {
    BOOL _isScrolling;
    
    UIView * _leftView;
    UIView * _rightView;
    
    NSInteger _newIndex;
    APPageDirection _scrollDirection;
}

@end

#define indexLeft   -1
#define indexCenter  0
#define indexRight   1
//------------------------------------------------------------------------------
@implementation APExtendedPageController
@synthesize extendedPageControllerDelegate = _extendedPageControllerDelegate;
@synthesize mainView = _mainView;
//@synthesize actualIndex = _actualIndex;
@synthesize displayBorder = _displayBorder;

-               (id)initWithFrame: (CGRect)frame
                         mainView: (UIView *)mainView
   extendedPageControllerDelegate: (id)extendedPageControllerDelegate
{
   
    self = [super initWithFrame:frame];
    if (self) {
        _extendedPageControllerDelegate = extendedPageControllerDelegate;
        //        _actualIndex = 0;
        _mainView = mainView;
        _displayBorder = YES;
        
        self.delegate = self;
        self.scrollEnabled = YES;
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        
        _mainView.frame = [self _frameForViewWithIndex:indexLeft];
        _mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                     UIViewAutoresizingFlexibleHeight;
        _mainView.autoresizesSubviews = YES;
        [self addSubview:_mainView];
        
        if ([_extendedPageControllerDelegate
             respondsToSelector:@selector(extendedPageController:direction:)])
        {
            _rightView = [_extendedPageControllerDelegate
                          extendedPageController:self
                          direction:APPageDirectionNext];
            
            _rightView.frame = [self _frameForViewWithIndex:indexCenter];
            _rightView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                          UIViewAutoresizingFlexibleHeight;
            _rightView.autoresizesSubviews = YES;
            [self addSubview:_rightView];
        }
        
        self.contentSize = CGSizeMake(self.frame.size.width * ((_leftView ? 1 : 0) +
                                                               (_mainView ? 1 : 0) +
                                                               (_rightView ? 1 : 0)),
                                      self.frame.size.height);
    }
    return self;
}
//------------------------------------------------------------------------------
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (((int)self.contentSize.width % 320) != 0) {
        self.contentSize = CGSizeMake(self.frame.size.width * ((_leftView ? 1 : 0) +
                                                               (_mainView ? 1 : 0) +
                                                               (_rightView ? 1 : 0)),
                                      self.frame.size.height);
        self.contentOffset = CGPointMake(_leftView ? self.frame.size.width : 0, 0);
        
        
        [self _resetView:_mainView withScaleFactor:1.];
        [self _rearrangeViews];
        
        _mainView.frame = [self _frameForViewWithIndex:_leftView ? indexCenter : indexLeft];
    }
}

//------------------------------------------------------------------------------
#define maxScale        .85
#define vBorderWidth     4.

- (void)setContentOffset:(CGPoint)contentOffset {
    [super setContentOffset:contentOffset];
    
    if (contentOffset.x == (_leftView ? self.frame.size.width : 0)) {
        _isScrolling = NO;
    }
    else {
        
        if (!_isScrolling) {
            if ((int)contentOffset.x > (_leftView ? self.frame.size.width : 0)) {
                //_newIndex = _actualIndex + 1;
                _scrollDirection = APPageDirectionNext;
            }
            else if (_leftView && (int)contentOffset.x < self.frame.size.width) {
                //_newIndex = _actualIndex - 1;
                _scrollDirection = APPageDirectionPrevious;
            }else{
                _scrollDirection = APPageDirectionNone;
            }
        }
        
        _isScrolling = YES;
        
        int newX = abs(self.frame.size.width - contentOffset.x);
        float newScale = 1 - (newX > 0 ? (float)newX/self.frame.size.width : 1) *
                             (newX > 0 ? (float)newX/self.frame.size.width : 1) * 2;
        
        if (newScale < 0) {
            newScale = -newScale;
        }
        if (newScale < maxScale) {
            newScale = maxScale;
        }
        if (newScale > 1.) {
            newScale = 1.;
        }
        
        [self _resetView:_mainView
         withScaleFactor:newScale];
        
        if (_leftView) {
            [self _resetView:_leftView
             withScaleFactor:newScale];
        }
        if (_rightView) {
            [self _resetView:_rightView
             withScaleFactor:newScale];
        }
        
    }
}

//------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self _rearrangeViews];
}


//------------------------------------------------------------------------------
#pragma mark - private methods

- (void)_rearrangeViews {
    
    NSLog(@"Content offset x: %.2f , view width: %.2f", self.contentOffset.x, self.frame.size.width);
    _isScrolling = NO;
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    UIView* dumpedView = nil;
    NSInteger dumpIndex = -1;
    
    if (((int)self.contentOffset.x < self.frame.size.width && _leftView)) {
        
        dumpedView = _rightView;
        _rightView = _mainView;
        _mainView = _leftView;
        _leftView = nil;
        if ([_extendedPageControllerDelegate
             respondsToSelector:@selector(extendedPageController:didMoveDirection:)])
        {
            [_extendedPageControllerDelegate extendedPageController:self didMoveDirection:APPageDirectionPrevious];
        }
        
//        if (_actualIndex != _newIndex) {
//            _actualIndex = _newIndex;
//        }

        //dumpIndex = _actualIndex + 2 * indexRight;
        
        NSLog(@"DumpView: %@", dumpedView);
        if ([_extendedPageControllerDelegate
             respondsToSelector:@selector(extendedPageController:direction:)])
        {
//            _leftView = [_extendedPageControllerDelegate
//                         extendedPageController:self
//                         viewAtIndex:_actualIndex+indexLeft];
            _leftView = [_extendedPageControllerDelegate
                         extendedPageController:self
                         direction:(APPageDirectionPrevious)];
            
            _leftView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                         UIViewAutoresizingFlexibleHeight;
            _leftView.autoresizesSubviews = YES;
        }
    }
    else if (((int)self.contentOffset.x > self.frame.size.width && _rightView)) {
        dumpedView = _leftView;
        _leftView = _mainView;
        _mainView = _rightView;
        _rightView = nil;
        if ([_extendedPageControllerDelegate
             respondsToSelector:@selector(extendedPageController:didMoveDirection:)])
        {
            [_extendedPageControllerDelegate extendedPageController:self didMoveDirection:APPageDirectionNext];
        }
        

        
//        if (_actualIndex != _newIndex) {
//            _actualIndex = _newIndex;
//        }
//        dumpIndex = _actualIndex + 2 * indexLeft;
        
        NSLog(@"DumpView: %@, atIndex: %d", dumpedView, dumpIndex);
        if ([_extendedPageControllerDelegate
             respondsToSelector:@selector(extendedPageController:direction:)])
        {
            
            
//            _rightView = [_extendedPageControllerDelegate
//                          extendedPageController:self
//                          viewAtIndex:_actualIndex+indexRight];
            
            _rightView = [_extendedPageControllerDelegate
                          extendedPageController:self
                          direction:APPageDirectionNext];
            
            _rightView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                          UIViewAutoresizingFlexibleHeight;
            _rightView.autoresizesSubviews = YES;
        }
    }
    else if ((int)self.contentOffset.x == self.frame.size.width && !_leftView) {
//        dumpedView = _leftView;
//        _leftView = _mainView;
//        _mainView = _rightView;
//        
//        if (_actualIndex != _newIndex) {
//            _actualIndex = _newIndex;
//        }
//        dumpIndex = _actualIndex + 2 * indexLeft;
//        NSLog(@"DumpView: %@, atIndex: %d", dumpedView, dumpIndex);
//        if ([_extendedPageControllerDelegate
//             respondsToSelector:@selector(extendedPageController:viewAtIndex:)])
//        {
//            _rightView = [_extendedPageControllerDelegate
//                          extendedPageController:self
//                          viewAtIndex:_actualIndex+indexRight];
//            
//            _rightView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
//                                          UIViewAutoresizingFlexibleHeight;
//            _rightView.autoresizesSubviews = YES;
//        }
        dumpedView = _leftView;
        _leftView = _mainView;
        _mainView = _rightView;
        _rightView = nil;
        if ([_extendedPageControllerDelegate
             respondsToSelector:@selector(extendedPageController:didMoveDirection:)])
        {
            [_extendedPageControllerDelegate extendedPageController:self didMoveDirection:APPageDirectionNext];
        }
        
        
        
        //        if (_actualIndex != _newIndex) {
        //            _actualIndex = _newIndex;
        //        }
        //        dumpIndex = _actualIndex + 2 * indexLeft;
        
        NSLog(@"DumpView: %@, atIndex: %d", dumpedView, dumpIndex);
        if ([_extendedPageControllerDelegate
             respondsToSelector:@selector(extendedPageController:direction:)])
        {
            
            
            //            _rightView = [_extendedPageControllerDelegate
            //                          extendedPageController:self
            //                          viewAtIndex:_actualIndex+indexRight];
            
            _rightView = [_extendedPageControllerDelegate
                          extendedPageController:self
                          direction:APPageDirectionNext];
            
            _rightView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleHeight;
            _rightView.autoresizesSubviews = YES;
        }
    }
    
    
    
    self.contentOffset = CGPointMake(_leftView ? _mainView.frame.size.width : 0, 0);
    self.contentSize = CGSizeMake(self.frame.size.width * ((_leftView ? 1 : 0) +
                                                           (_mainView ? 1 : 0) +
                                                           (_rightView ? 1 : 0)),
                                  self.frame.size.height);
    
    if (_leftView) {
        _leftView.frame = [self _frameForViewWithIndex:indexLeft];
        _leftView.layer.borderColor = [UIColor colorWithWhite:1. alpha:0.].CGColor;
        [self addSubview:_leftView];
    }
    if (_mainView) {
        _mainView.frame = [self _frameForViewWithIndex:(_leftView ? indexCenter : indexLeft)];
        _mainView.layer.borderColor = [UIColor colorWithWhite:1. alpha:0.].CGColor;
        [self addSubview:_mainView];
    }
    if (_rightView) {
        _rightView.frame = [self _frameForViewWithIndex:(_leftView ? indexRight : indexCenter)];
        _rightView.layer.borderColor = [UIColor colorWithWhite:1. alpha:0.].CGColor;
        [self addSubview:_rightView];
    }
    
    // Give delegate chance to reuse view
    if (dumpedView &&
        [_extendedPageControllerDelegate
         respondsToSelector:@selector(extendedPageController:dumpView:atIndex:)])
    {
        [_extendedPageControllerDelegate
         extendedPageController:self
         dumpView:dumpedView];
    }
}
//------------------------------------------------------------------------------
- (CGRect)_frameForViewWithIndex: (int)index {
    switch (index) {
        case indexLeft:
            return CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            break;
        case indexCenter:
            return CGRectMake(self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            break;
        case indexRight:
            return CGRectMake(self.frame.size.width*2, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            break;
        default:
            return CGRectZero;
            break;
    }
}

//------------------------------------------------------------------------------
- (void)_resetView: (UIView *)view
   withScaleFactor: (float)scaleFactor
{
    view.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    
    if (_displayBorder) {
        float borderAlpha = 1. - (scaleFactor-maxScale) / (1. - maxScale);
        view.layer.borderColor = [UIColor colorWithWhite:1. alpha:borderAlpha].CGColor;
        view.layer.borderWidth = vBorderWidth;
    }
}

@end
