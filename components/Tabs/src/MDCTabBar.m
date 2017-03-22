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

#import "MDCTabBar.h"

#import "MaterialInk.h"
#import "MaterialTypography.h"
#import "private/MDCItemBar.h"
#import "private/MDCItemBarAlignment.h"
#import "private/MDCItemBarStyle.h"

/// Padding between image and title in points, according to the spec.
static const CGFloat kImageTitleSpecPadding = 10;

/// Adjustment added to spec measurements to compensate for internal paddings.
static const CGFloat kImageTitlePaddingAdjustment = -3;

// Heights based on the spec: https://www.google.com/design/spec/components/tabs.html

/// Height for image-only tab bars, in points.
static const CGFloat kImageOnlyBarHeight = 48;

/// Height for image-only tab bars, in points.
static const CGFloat kTitleOnlyBarHeight = 48;

/// Height for image-and-title tab bars, in points.
static const CGFloat kTitledImageBarHeight = 72;

static MDCTabBarAlignment MDCTabBarAlignmentForItemBarAlignment(MDCItemBarAlignment alignment) {
  switch (alignment) {
    case MDCItemBarAlignmentCenter:
      return MDCTabBarAlignmentCenter;

    case MDCItemBarAlignmentLeading:
      return MDCTabBarAlignmentLeading;

    case MDCItemBarAlignmentJustified:
      return MDCTabBarAlignmentJustified;

    case MDCItemBarAlignmentCenterSelected:
      return MDCTabBarAlignmentCenterSelected;
  }

  NSCAssert(0, @"Invalid alignment value %zd", alignment);
  return MDCTabBarAlignmentLeading;
}

static MDCItemBarAlignment MDCItemBarAlignmentForTabBarAlignment(MDCTabBarAlignment alignment) {
  switch (alignment) {
    case MDCTabBarAlignmentCenter:
      return MDCItemBarAlignmentCenter;

    case MDCTabBarAlignmentLeading:
      return MDCItemBarAlignmentLeading;

    case MDCTabBarAlignmentJustified:
      return MDCItemBarAlignmentJustified;

    case MDCTabBarAlignmentCenterSelected:
      return MDCItemBarAlignmentCenterSelected;
  }

  NSCAssert(0, @"Invalid alignment value %zd", alignment);
  return MDCItemBarAlignmentLeading;
}

@interface MDCTabBarConfiguration ()

/// Fixed item bar style, upon which the tab bar generates the underlying item bar style.
@property(nonatomic, copy) MDCItemBarStyle *baseItemBarStyle;

/// A mapping from MDCTabBarItemAppearance to the default height to use with that appearance.
@property(nonatomic, nonnull, copy) NSDictionary<NSNumber *, NSNumber *> *heightByItemAppearance;

@end

@interface MDCTabBar () <MDCItemBarDelegate>
@end

@implementation MDCTabBar {
  /// Item bar responsible for displaying the actual tab bar content.
  MDCItemBar *_itemBar;
}
// Inherit UIView's tintColor logic.
@dynamic tintColor;

#pragma mark - Initialization

+ (void)initialize {
  [[[self class] appearance] setSelectedItemTintColor:[UIColor whiteColor]];
  [[[self class] appearance] setUnselectedItemTintColor:[UIColor colorWithWhite:1.0 alpha:0.7f]];
  [[[self class] appearance] setInkColor:[UIColor colorWithWhite:1.0 alpha:0.7f]];
  [[[self class] appearance] setBarTintColor:nil];
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(MDCTabBarConfiguration *)configuration {
  self = [super initWithFrame:frame];
  if (self) {
    _configuration = [configuration copy];
    [self commonMDCTabBarInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    _configuration = [MDCTabBarConfiguration topTabsConfiguration];
    [self commonMDCTabBarInit];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  return [self initWithFrame:frame configuration:[MDCTabBarConfiguration topTabsConfiguration]];
}

- (void)commonMDCTabBarInit {
  _displaysUppercaseTitles = _configuration.displaysUppercaseTitlesByDefault;
  _itemAppearance = _configuration.defaultItemAppearance;

  // Create item bar.
  _itemBar = [[MDCItemBar alloc] initWithFrame:self.bounds];
  _itemBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  _itemBar.delegate = self;
  _itemBar.alignment = MDCItemBarAlignmentForTabBarAlignment(_configuration.defaultAlignment);
  [self addSubview:_itemBar];

  [self updateItemBarStyle];
}

#pragma mark - Public

+ (CGFloat)defaultHeightForItemAppearance:(MDCTabBarItemAppearance)appearance {
  return [self defaultHeightForConfiguration:[MDCTabBarConfiguration topTabsConfiguration]
                              itemAppearance:appearance];
}

+ (CGFloat)defaultHeightForConfiguration:(nonnull MDCTabBarConfiguration *)configuration
                          itemAppearance:(MDCTabBarItemAppearance)appearance {
  return [MDCItemBar defaultHeightForStyle:[self defaultStyleWithConfiguration:configuration
                                                                itemAppearance:appearance]];
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

- (void)setInkColor:(UIColor *)inkColor {
  if (_inkColor != inkColor && ![_inkColor isEqual:inkColor]) {
    _inkColor = inkColor;

    [self updateItemBarStyle];
  }
}

- (MDCTabBarAlignment)alignment {
  return MDCTabBarAlignmentForItemBarAlignment(_itemBar.alignment);
}

- (void)setAlignment:(MDCTabBarAlignment)alignment {
  [_itemBar setAlignment:MDCItemBarAlignmentForTabBarAlignment(alignment)];
}

- (void)setAlignment:(MDCTabBarAlignment)alignment animated:(BOOL)animated {
  [_itemBar setAlignment:MDCItemBarAlignmentForTabBarAlignment(alignment) animated:animated];
}

- (void)setItemAppearance:(MDCTabBarItemAppearance)itemAppearance {
  if (itemAppearance != _itemAppearance) {
    _itemAppearance = itemAppearance;

    [self updateItemBarStyle];
  }
}

- (void)setSelectedItemTintColor:(UIColor *)selectedItemTintColor {
  if (_selectedItemTintColor != selectedItemTintColor &&
      ![_selectedItemTintColor isEqual:selectedItemTintColor]) {
    _selectedItemTintColor = selectedItemTintColor;

    [self updateItemBarStyle];
  }
}

- (void)setUnselectedItemTintColor:(UIColor *)unselectedItemTintColor {
  if (_unselectedItemTintColor != unselectedItemTintColor &&
      ![_unselectedItemTintColor isEqual:unselectedItemTintColor]) {
    _unselectedItemTintColor = unselectedItemTintColor;

    [self updateItemBarStyle];
  }
}

- (void)setDisplaysUppercaseTitles:(BOOL)displaysUppercaseTitles {
  if (displaysUppercaseTitles != _displaysUppercaseTitles) {
    _displaysUppercaseTitles = displaysUppercaseTitles;

    [self updateItemBarStyle];
  }
}

#pragma mark - MDCItemBarDelegate

- (void)itemBar:(MDCItemBar *)itemBar didSelectItem:(UITabBarItem *)item {
  id<MDCTabBarDelegate> delegate = self.delegate;
  if ([delegate respondsToSelector:@selector(tabBar:didSelectItem:)]) {
    [delegate tabBar:self didSelectItem:item];
  }
}

- (void)itemBar:(MDCItemBar *)itemBar willSelectItem:(UITabBarItem *)item {
  id<MDCTabBarDelegate> delegate = self.delegate;
  if ([delegate respondsToSelector:@selector(tabBar:willSelectItem:)]) {
    [delegate tabBar:self willSelectItem:item];
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

+ (MDCItemBarStyle *)defaultStyleWithConfiguration:(MDCTabBarConfiguration *)configuration
                                    itemAppearance:(MDCTabBarItemAppearance)appearance {
  MDCItemBarStyle *style = [configuration.baseItemBarStyle copy];

  // Update appearance-dependent style properties.
  BOOL displayImage = NO;
  BOOL displayTitle = NO;
  switch (appearance) {
    case MDCTabBarItemAppearanceImages:
      displayImage = YES;
      break;

    case MDCTabBarItemAppearanceTitles:
      displayTitle = YES;
      break;

    case MDCTabBarItemAppearanceTitledImages:
      displayImage = YES;
      displayTitle = YES;
      break;

    default:
      NSAssert(0, @"Invalid appearance value %zd", appearance);
      displayTitle = YES;
      break;
  }
  style.shouldDisplayImage = displayImage;
  style.shouldDisplayTitle = displayTitle;

  CGFloat defaultHeight = (CGFloat)(configuration.heightByItemAppearance[@(appearance)].floatValue);
  if (defaultHeight == 0) {
    NSAssert(0, @"Missing default height for %zd", appearance);
    defaultHeight = kTitleOnlyBarHeight;
  }
  style.defaultHeight = defaultHeight;

  // Only show badge with images.
  style.shouldDisplayBadge = displayImage;

  return style;
}

- (void)updateItemBarStyle {
  MDCItemBarStyle *style;

  style =
      [[self class] defaultStyleWithConfiguration:_configuration itemAppearance:_itemAppearance];

  style.selectionIndicatorColor = self.tintColor;
  style.inkColor = _inkColor;
  style.selectedTitleColor = (_selectedItemTintColor ?: self.tintColor);
  style.titleColor = _unselectedItemTintColor;
  style.displaysUppercaseTitles = _displaysUppercaseTitles;

  [_itemBar applyStyle:style];
}

@end

#pragma mark -

@implementation MDCTabBarConfiguration

- (instancetype)init {
  self = [super init];
  if (self) {
    // Default initializer is the top tab style.
    _displaysUppercaseTitlesByDefault = YES;
    _defaultAlignment = MDCTabBarAlignmentLeading;
    _defaultItemAppearance = MDCTabBarItemAppearanceTitles;
    _heightByItemAppearance = @{
        @(MDCTabBarItemAppearanceTitledImages) : @(kTitledImageBarHeight),
        @(MDCTabBarItemAppearanceTitles) : @(kTitleOnlyBarHeight),
        @(MDCTabBarItemAppearanceImages) : @(kImageOnlyBarHeight),
    };

    // Set initial style with values that don't depend on tab bar state.
    MDCItemBarStyle *style = [[MDCItemBarStyle alloc] init];
    style.shouldDisplaySelectionIndicator = YES;
    style.shouldGrowOnSelection = NO;
    style.titleFont = [MDCTypography buttonFont];
    style.inkStyle = MDCInkStyleBounded;
    style.titleImagePadding =
        (kImageTitleSpecPadding + kImageTitlePaddingAdjustment);
    _baseItemBarStyle = style;
  }
  return self;
}

#pragma mark - Public

+ (instancetype)topTabsConfiguration {
  return [[[self class] alloc] init];
}

+ (instancetype)bottomNavigationConfiguration {
  MDCTabBarConfiguration *configuration = [[[self class] alloc] init];
  configuration.displaysUppercaseTitlesByDefault = NO;
  configuration.defaultAlignment = MDCTabBarAlignmentJustified;
  configuration.defaultItemAppearance = MDCTabBarItemAppearanceTitledImages;

  const CGFloat kBottomNavigationHeight = 56;
  configuration.heightByItemAppearance = @{
      @(MDCTabBarItemAppearanceTitledImages) : @(kBottomNavigationHeight),
      @(MDCTabBarItemAppearanceTitles) : @(kBottomNavigationHeight),
      @(MDCTabBarItemAppearanceImages) : @(kBottomNavigationHeight),
  };

  // Set initial style with values that don't depend on tab bar state.
  MDCItemBarStyle *style = [[MDCItemBarStyle alloc] init];
  style.shouldDisplaySelectionIndicator = NO;
  style.shouldGrowOnSelection = YES;
  style.maximumItemWidth = 168;
  style.titleFont = [[MDCTypography fontLoader] regularFontOfSize:12];
  style.inkStyle = MDCInkStyleUnbounded;
  style.titleImagePadding = 3;

  configuration.baseItemBarStyle = style;

  return configuration;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
  MDCTabBarConfiguration *newConfiguration = [[[self class] alloc] init];
  newConfiguration.displaysUppercaseTitlesByDefault = _displaysUppercaseTitlesByDefault;
  newConfiguration.defaultAlignment = _defaultAlignment;
  newConfiguration.defaultItemAppearance = _defaultItemAppearance;
  newConfiguration.baseItemBarStyle = _baseItemBarStyle;
  newConfiguration.heightByItemAppearance = _heightByItemAppearance;
  return newConfiguration;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
  if (![object isKindOfClass:[self class]]) {
    return NO;
  }
  
  MDCTabBarConfiguration *otherConfiguration = object;
  
  if (otherConfiguration.displaysUppercaseTitlesByDefault != _displaysUppercaseTitlesByDefault) {
    return NO;
  }
  
  if (otherConfiguration.defaultAlignment != _defaultAlignment) {
    return NO;
  }
  
  if (otherConfiguration.defaultItemAppearance != _defaultItemAppearance) {
    return NO;
  }

  MDCItemBarStyle *otherStyle = otherConfiguration.baseItemBarStyle;
  if (otherStyle != _baseItemBarStyle && ![otherStyle isEqual:_baseItemBarStyle]) {
    return NO;
  }

  return YES;
}

- (NSString *)description {
  return [NSString stringWithFormat:(@"%@ displaysUppercaseTitlesByDefault:%d defaultAlignment:%d"
                                     @" defaultItemAppearance:%d baseItemBarStyle:%@ heights:%@"),
                                    [super description],
                                    _displaysUppercaseTitlesByDefault,
                                    (int)_defaultAlignment,
                                    (int)_defaultItemAppearance,
                                    _baseItemBarStyle,
                                    _heightByItemAppearance];
}

- (NSUInteger)hash {
  return @(_displaysUppercaseTitlesByDefault).hash ^ @(_defaultAlignment).hash ^
      @(_defaultItemAppearance).hash ^ _baseItemBarStyle.hash ^ _heightByItemAppearance.hash;
}

@end 
