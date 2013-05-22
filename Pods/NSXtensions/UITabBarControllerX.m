#import "UITabBarControllerX.h"

#import "UIApplicationX.h"

@implementation UITabBarController (X)

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (self.isTabBarHidden == hidden)
        return;

    CGFloat height = UIApplication.frame.size.height + UIApplication.sharedApplication.statusBarFrame.size.height;

    height -= hidden ? 0.0 : self.tabBar.frame.size.height;

    [UIView animateWithDuration:animated ? UINavigationControllerHideShowBarDuration : 0.0 animations:^
    {
        if (!hidden)
            self.tabBar.hidden = hidden;

        for(UIView *view in self.view.subviews)
            if ([view isKindOfClass:UITabBar.class])
                [view setFrame:CGRectMake(view.frame.origin.x, height, view.frame.size.width, view.frame.size.height)];
            else
                if (hidden)
                    [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, height)];
    }
    completion:^(BOOL finished)
    {
        self.tabBar.hidden = hidden;

        if (!hidden)
            [UIView animateWithDuration:animated ? UINavigationControllerHideShowBarDuration : 0.0 animations:^
            {
                for(UIView *view in self.view.subviews)
                    if (![view isKindOfClass:UITabBar.class])
                        [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, height)];
            }];
    }];
}

- (void)setTabBarHidden:(BOOL)tabBarHidden
{
    [self setTabBarHidden:tabBarHidden animated:NO];
}

- (BOOL)isTabBarHidden
{
    return self.tabBar.hidden;
}

@end
