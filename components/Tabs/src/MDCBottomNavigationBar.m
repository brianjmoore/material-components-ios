/*
 Copyright 2017-present the Material Components for iOS authors. All Rights Reserved.

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

#import "MDCBottomNavigationBar.h"

#import "MaterialInk.h"
#import "MaterialTypography.h"
#import "private/MDCItemBar.h"
#import "private/MDCItemBarAlignment.h"
#import "private/MDCItemBarStyle.h"

@interface MDCBottomNavigationBar () <MDCItemBarDelegate>
@end

@implementation MDCBottomNavigationBar {
  /// Item bar responsible for displaying the actual bottom navigation bar content.
  MDCItemBar *_itemBar;
}
// Inherit UIView's tintColor logic.
@dynamic tintColor;

#pragma mark - Initialization

+ (void)initialize {
  // Set default appearance
  [[[self class] appearance] setUnselectedItemTintColor:[UIColor colorWithWhite:1.0 alpha:0.7f]];
  [[[self class] appearance] setBarTintColor:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonMDCBottomNavigationBarInit];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonMDCBottomNavigationBarInit];
  }
  return self;
}

- (void)commonMDCBottomNavigationBarInit {
  // Create item bar.
  _itemBar = [[MDCItemBar alloc] initWithFrame:self.bounds];
  _itemBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  _itemBar.delegate = self;
  _itemBar.alignment = MDCItemBarAlignmentJustified;
  [self addSubview:_itemBar];

  [self updateItemBarStyle];
}

#pragma mark - Public

+ (CGFloat)defaultHeight {
  return [MDCItemBar defaultHeightForStyle:[self defaultStyle]];
}

- (NSArray<UITabBarItem *> *)items {
  return _itemBar.items;
}

- (void)setItems:(NSArray<UITabBarItem *> *)items {
  [_itemBar setItems:items];
}

- (UITabBarItem *)selectedItem {
  return _itemBar.selectedItem;
}

- (void)setSelectedItem:(UITabBarItem *)selectedItem {
  [_itemBar setSelectedItem:selectedItem];
}

- (void)setSelectedItem:(UITabBarItem *)selectedItem animated:(BOOL)animated {
  [_itemBar setSelectedItem:selectedItem animated:animated];
}

- (void)setBarTintColor:(UIColor *)barTintColor {
  if (_barTintColor != barTintColor && ![_barTintColor isEqual:barTintColor]) {
    _barTintColor = barTintColor;

    // Update background color.
    _itemBar.backgroundColor = barTintColor;
  }
}

- (void)setUnselectedItemTintColor:(UIColor *)unselectedItemTintColor {
  if (_unselectedItemTintColor != unselectedItemTintColor &&
      ![_unselectedItemTintColor isEqual:unselectedItemTintColor]) {
    _unselectedItemTintColor = unselectedItemTintColor;

    [self updateItemBarStyle];
  }
}

#pragma mark - MDCItemBarDelegate

- (void)itemBar:(MDCItemBar *)itemBar didSelectItem:(UITabBarItem *)item {
  id<MDCBottomNavigationBarDelegate> delegate = self.delegate;
  if ([delegate respondsToSelector:@selector(bottomNavigationBar:didSelectItem:)]) {
    [delegate bottomNavigationBar:self didSelectItem:item];
  }
}

- (void)itemBar:(MDCItemBar *)itemBar willSelectItem:(UITabBarItem *)item {
  id<MDCBottomNavigationBarDelegate> delegate = self.delegate;
  if ([delegate respondsToSelector:@selector(bottomNavigationBar:willSelectItem:)]) {
    [delegate bottomNavigationBar:self willSelectItem:item];
  }
}

#pragma mark - UIView

- (void)tintColorDidChange {
  [super tintColorDidChange];

  [self updateItemBarStyle];
}

- (CGSize)intrinsicContentSize {
  return _itemBar.intrinsicContentSize;
}

- (CGSize)sizeThatFits:(CGSize)size {
  return [_itemBar sizeThatFits:size];
}

#pragma mark - Private

+ (MDCItemBarStyle *)defaultStyle {
  MDCItemBarStyle *style = [[MDCItemBarStyle alloc] init];

  style.defaultHeight = 56;
  style.shouldDisplaySelectionIndicator = NO;
  style.selectionIndicatorColor = nil;
  style.maximumItemWidth = 168;
  style.shouldDisplayTitle = YES;
  style.shouldDisplayImage = YES;
  style.shouldDisplayBadge = YES;
  style.shouldGrowOnSelection = YES;
  style.titleFont = [[MDCTypography fontLoader] regularFontOfSize:12];
  style.inkStyle = MDCInkStyleUnbounded;
  style.titleImagePadding = 3;
  style.displaysUppercaseTitles = NO;

  return style;
}

- (void)updateItemBarStyle {
  MDCItemBarStyle *style = [[self class] defaultStyle];

  // Update colors
  style.selectedTitleColor = self.tintColor;
  style.titleColor = _unselectedItemTintColor;
  style.inkColor = [self.tintColor colorWithAlphaComponent:0.15];
  
  [_itemBar applyStyle:style];
}

@end
