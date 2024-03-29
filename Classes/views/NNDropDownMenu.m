//
//  NNDropDownMenu.m
//  Neonan
//
//  Created by capricorn on 12-12-10.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "NNDropDownMenu.h"

@interface NNDropDownMenu ()
@property (nonatomic, strong) UIView *containerView;
@end

@implementation NNDropDownMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.windowLevel = UIWindowLevelNormal + 1;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)RGBA(0, 0, 0, .65).CGColor, (id)RGBA(0, 0, 0, .99).CGColor, (id)RGBA(0, 0, 0, .80).CGColor, (id)RGBA(0, 0, 0, .60).CGColor, nil];
        [self.layer insertSublayer:gradient atIndex:0];

//        self.backgroundColor = [UIColor blackColor];
        
        self.containerView = [[UIView alloc] initWithFrame:frame];
        self.containerView.clipsToBounds = YES;
    }
    return self;
}

- (NSArray *)items {
    return _containerView.subviews;
}

- (void)setTopPadding:(CGFloat)topPadding {
    _topPadding = topPadding;
    
    CGRect frame = _containerView.frame;
    frame.origin.y = topPadding;
    frame.size.height -= topPadding;
    _containerView.frame = frame;
}

- (void)setItemHeight:(CGFloat)itemHeight {
    if (_itemHeight == itemHeight) {
        return;
    }
    
    _itemHeight = itemHeight;
    [self.containerView.subviews enumerateObjectsUsingBlock:^(NNMenuItem *item, NSUInteger idx, BOOL *stop) {
        CGRect frame = item.frame;
        frame.origin.y = _topPadding + idx * _itemHeight;
        frame.size.height = _itemHeight;
        item.frame = frame;
    }];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self || hitView == _containerView) {
        [self dismissMenu];
    }
    
    return hitView;
}

- (void)addItem:(NNMenuItem *)item {
    NSUInteger index = self.containerView.subviews.count;
    item.tag = index;
    
    CGRect frame = item.frame;
    frame.origin.y = index * _itemHeight;
    frame.size.height = _itemHeight;
    item.frame = frame;
    
    [item addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.containerView addSubview:item];
}

- (void)showMenu {
    self.showing = YES;
    
    if (!_containerView.superview) {
        [self addSubview:_containerView];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self makeKeyAndVisible];
        
        // Animate in items
        [self.containerView.subviews enumerateObjectsUsingBlock:^(NNMenuItem *item, NSUInteger idx, BOOL *stop) {
            item.transform = CGAffineTransformMakeTranslation(0, -item.frame.origin.y - _itemHeight);
        }];
        
        [UIView animateWithDuration:0.2f delay:0.01f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.containerView.subviews enumerateObjectsUsingBlock:^(NNMenuItem *item, NSUInteger idx, BOOL *stop) {
                item.transform = CGAffineTransformMakeTranslation(0, 0);
            }];
        } completion:^(BOOL finished) {
        }];
        
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {
        }];
        
    });
}

- (void)dismissMenu {
    self.showing = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Animate out the items
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.containerView.subviews enumerateObjectsUsingBlock:^(NNMenuItem *item, NSUInteger idx, BOOL *stop) {
                item.transform = CGAffineTransformMakeTranslation(0, -item.frame.origin.y - _itemHeight);
            }];
        } completion:^(BOOL finished) {
        }];
        
        
        // Fade out the overlay window and remove self from it
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            
            [[UIApplication sharedApplication].windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
                if ([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                    [window makeKeyWindow];
                    *stop = YES;
                }
            }];
            
            if (_menuDelegate && [_menuDelegate respondsToSelector:@selector(onMenuDismissed)]) {
                [_menuDelegate onMenuDismissed];
            }
        }];
    });
}

- (void)tappedBackground {
    [self dismissMenu];
}

- (void)itemClicked:(NNMenuItem *)item {
    if (self.onItemClicked) {
        self.onItemClicked(item, item.tag);
    }
}

@end

static const CGFloat kIconPadding = 12;

@interface NNMenuItem ()
@property (nonatomic, unsafe_unretained) UIImageView *iconView;
@property (nonatomic, unsafe_unretained) UILabel *textLabel;
@end

@implementation NNMenuItem

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *iconView = self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kIconPadding, 0, 20, 20)];
        CGPoint center = iconView.center;
        center.y = frame.size.height / 2;
        iconView.center = center;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:iconView];
        
        CGFloat leftPadding = kIconPadding + 20 + kIconPadding;
        UILabel *textLabel = self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, frame.size.width - leftPadding, frame.size.height)];
        textLabel.font = [UIFont boldSystemFontOfSize:16];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        textLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:textLabel]; 
        
//        CALayer *bottomBorder = [CALayer layer];        
//        bottomBorder.frame = CGRectMake(0, frame.size.height - 1, frame.size.width, 1);
//        bottomBorder.backgroundColor = RGB(18, 18, 18).CGColor;
//        [self.layer addSublayer:bottomBorder];
    }
    return self;
}

- (void)dealloc {
    self.iconView = nil;
    self.textLabel = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _iconView.hidden = !_iconView.image;
    _textLabel.x = kIconPadding + (_iconView.hidden ? 0 : (20 + kIconPadding));
}

- (void)setIconImage:(UIImage *)image andHighlightedImage:(UIImage *)highlightedImage {
    _iconView.image = image;
    _iconView.highlightedImage = highlightedImage;
}

- (void)setText:(NSString *)text withColor:(UIColor *)color andHighlightedColor:(UIColor *)highlightedColor {
    _textLabel.text = text;
    _textLabel.textColor = color;
    _textLabel.highlightedTextColor = highlightedColor;
}

- (void)setText:(NSString *)text {
    _textLabel.text = text;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setHighlighted:highlighted];
    }];
}
@end
