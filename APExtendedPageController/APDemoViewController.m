//
//  APViewController.m
//  APExtendedPageController
//
//  Created by Andrzej on 03.04.2013.
//  Copyright (c) 2013 apuczyk. All rights reserved.
//

#import "APDemoViewController.h"
#define randomFloat ((float)(rand()%255))/255.
@interface APDemoViewController ()
{
    NSArray * _views;
    NSInteger _currentIdx;
}
@end

@implementation APDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray* mutableViews = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < 10; i++) {
    
        UIView * view = [[UIView alloc] initWithFrame:self.view.bounds];
        view.backgroundColor = [UIColor colorWithRed:randomFloat green:randomFloat blue:randomFloat alpha:1.];
        
        UILabel * lbl = [[UILabel alloc] initWithFrame:self.view.bounds];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textAlignment = UITextAlignmentCenter;
        lbl.textColor = [UIColor whiteColor];
        lbl.text = [NSString stringWithFormat:@"Page no. %d", i];
        lbl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:lbl];
        
        
        [mutableViews addObject:view];
    }
    
    _views = [NSArray arrayWithArray:mutableViews];
    
	_pageController = [[APExtendedPageController alloc] initWithFrame:self.view.bounds
                                                             mainView:_views[0]
                                       extendedPageControllerDelegate:self];
    _currentIdx = 0;
    [self.view addSubview:_pageController];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}



//- (UIView *)extendedPageController:(APExtendedPageController *)extendedPageController
//                       viewAtIndex:(NSInteger)index
//{
//    
//    if (index >= 0 && index <= 10) {
//        UIView * view = [[UIView alloc] initWithFrame:extendedPageController.frame];
//        view.backgroundColor = [UIColor colorWithRed:randomFloat green:randomFloat blue:randomFloat alpha:1.];
//        
//        UILabel * lbl = [[UILabel alloc] initWithFrame:extendedPageController.frame];
//        lbl.backgroundColor = [UIColor clearColor];
//        lbl.textAlignment = UITextAlignmentCenter;
//        lbl.textColor = [UIColor whiteColor];
//        lbl.text = [NSString stringWithFormat:@"Page no. %d", index];
//        lbl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        [view addSubview:lbl];
//        
//        
//        return view;
//    }
//    
//    return nil;
//}

- (UIView *)extendedPageController:(APExtendedPageController *)extendedPageController
                       direction:(APPageDirection)direction
{   NSInteger newidx = -1;
    if (direction == APPageDirectionNext)
    {
        newidx = _currentIdx+1;
    }
    else if(direction == APPageDirectionPrevious)
    {
        newidx = _currentIdx-1;
    }
    
    if ((newidx > 0) && (newidx < _views.count)) {
        return _views[newidx % 10];
    }
    return nil;
}

- (void) extendedPageController: (APExtendedPageController *) extendedPageController
               didMoveDirection: (APPageDirection)direction
{

    if (direction == APPageDirectionNext)
    {
        _currentIdx++;
        if(_currentIdx  > 9) _currentIdx = 0;
    }
    else if(direction == APPageDirectionPrevious)
    {
        _currentIdx--;
        if (_currentIdx < 0) {
            _currentIdx = 9;
        }
    }
}
@end
