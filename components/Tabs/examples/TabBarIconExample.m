/*
 Copyright 2016-present the Material Components for iOS authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <UIKit/UIKit.h>

#import "MaterialButtons.h"
#import "MaterialTabs.h"

@interface TabBarIconDemoViewController : UIViewController
@end

@implementation TabBarIconDemoViewController {
  MDCTabBar *_shortTabBar;
  MDCRaisedButton *_alignmentButton;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    UIBarButtonItem *badgeIncrementItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Increment"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(incrementBadges:)];
    self.navigationItem.rightBarButtonItem = badgeIncrementItem;
  }
  return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];

  // Button to change tab alignments.
  _alignmentButton = [[MDCRaisedButton alloc] init];
  [_alignmentButton setTitle:@"Change Alignment" forState:UIControlStateNormal];
  [_alignmentButton sizeToFit];
  _alignmentButton.center = CGPointMake(CGRectGetMidX(self.view.bounds), 100);
  _alignmentButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleBottomMargin |
                                      UIViewAutoresizingFlexibleRightMargin;
  [_alignmentButton addTarget:self
                       action:@selector(changeAlignment:)
             forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:_alignmentButton];

  self.view.tintColor = [UIColor purpleColor];

  [self loadShortTabBar];
}

#pragma mark - Action

- (void)incrementBadges:(id)sender {
  // Increment all numeric badge values to show cells updating when their item's properties are set.
  for (MDCTabBar *tabBar in @[ _shortTabBar ]) {
    for (UITabBarItem *item in tabBar.items) {
      NSString *badgeValue = item.badgeValue;
      if (badgeValue) {
        NSInteger badgeNumber = badgeValue.integerValue;
        if (badgeNumber > 0) {
          // Update badge value directly - the cell should update immediately.
          item.badgeValue = [NSNumberFormatter localizedStringFromNumber:@(badgeNumber + 1)
                                                             numberStyle:NSNumberFormatterNoStyle];
        }
      }
    }
  }
}

#pragma mark - Private

- (void)loadShortTabBar {
  const CGRect bounds = self.view.bounds;

  // Short tab bar with a small number of items.
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  UIImage *infoImage =
      [UIImage imageNamed:@"TabBarDemo_ic_info" inBundle:bundle compatibleWithTraitCollection:nil];
  UIImage *starImage =
      [UIImage imageNamed:@"TabBarDemo_ic_star" inBundle:bundle compatibleWithTraitCollection:nil];
  _shortTabBar =
      [[MDCTabBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bounds) - 20.0f, 0)];
  _shortTabBar.center = CGPointMake(CGRectGetMidX(self.view.bounds), 150);
  _shortTabBar.items = @[
    [[UITabBarItem alloc] initWithTitle:@"Two" image:infoImage tag:0],
    [[UITabBarItem alloc] initWithTitle:@"Tabs" image:starImage tag:1]
  ];

  // Give the last item a badge
  [[_shortTabBar.items lastObject] setBadgeValue:@"1"];

  _shortTabBar.barTintColor = [UIColor blueColor];
  _shortTabBar.tintColor = [UIColor whiteColor];
  _shortTabBar.itemAppearance = MDCTabBarItemAppearanceTitledImages;
  _shortTabBar.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
  [_shortTabBar sizeToFit];
  [self.view addSubview:_shortTabBar];
}

- (void)changeAlignment:(id)sender {
  UIAlertController *sheet =
      [UIAlertController alertControllerWithTitle:nil
                                          message:nil
                                   preferredStyle:UIAlertControllerStyleActionSheet];
  [sheet addAction:[UIAlertAction actionWithTitle:@"Leading"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction *_Nonnull action) {
                                            [self setAlignment:MDCTabBarAlignmentLeading];
                                          }]];
  [sheet addAction:[UIAlertAction actionWithTitle:@"Center"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction *_Nonnull action) {
                                            [self setAlignment:MDCTabBarAlignmentCenter];
                                          }]];
  [sheet addAction:[UIAlertAction actionWithTitle:@"Justified"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction *_Nonnull action) {
                                            [self setAlignment:MDCTabBarAlignmentJustified];
                                          }]];
  [sheet addAction:[UIAlertAction actionWithTitle:@"Selected Center"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction *_Nonnull action) {
                                            [self setAlignment:MDCTabBarAlignmentCenterSelected];
                                          }]];
  [self presentViewController:sheet animated:YES completion:nil];
}

- (void)setAlignment:(MDCTabBarAlignment)alignment {
  [_shortTabBar setAlignment:alignment animated:YES];
}

@end

@implementation TabBarIconDemoViewController (CatalogByConvention)

+ (NSArray *)catalogBreadcrumbs {
  return @[ @"Tab Bar", @"Tab Bar" ];
}

+ (BOOL)catalogIsPrimaryDemo {
  return YES;
}

+ (NSString *)catalogDescription {
  return @"The tab bar is a component for switching between views of grouped content.";
}

@end
