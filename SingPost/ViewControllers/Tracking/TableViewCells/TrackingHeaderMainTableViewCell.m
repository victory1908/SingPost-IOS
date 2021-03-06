//
//  TrackingHeaderMainTableViewCell.m
//  SingPost
//
//  Created by Edward Soetiono on 28/9/13.
//  Copyright (c) 2013 Codigo. All rights reserved.
//

#import "TrackingHeaderMainTableViewCell.h"
#import "UIFont+SingPost.h"

@implementation TrackingHeaderMainTableViewCell
{
    UIView *separatorView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        CGFloat width;
        if (INTERFACE_IS_IPAD)
            width = 768;
        else
            width = 320;
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
        [contentView setBackgroundColor:[UIColor whiteColor]];
        
        UILabel *trackingNumbersHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 120, 30)];
        [trackingNumbersHeaderLabel setFont:[UIFont SingPostBoldFontOfSize:12.0f fontKey:kSingPostFontOpenSans]];
        [trackingNumbersHeaderLabel setText:@"My Items"];
        [trackingNumbersHeaderLabel setTextColor:RGB(125, 136, 149)];
        [trackingNumbersHeaderLabel setBackgroundColor:[UIColor clearColor]];
        [contentView addSubview:trackingNumbersHeaderLabel];
        
        UILabel *statusHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 0, 50, 30)];
        if (INTERFACE_IS_IPAD)
            statusHeaderLabel.left = 512;
        [statusHeaderLabel setFont:[UIFont SingPostBoldFontOfSize:12.0f fontKey:kSingPostFontOpenSans]];
        [statusHeaderLabel setText:@"Status"];
        [statusHeaderLabel setTextColor:RGB(125, 136, 149)];
        [statusHeaderLabel setBackgroundColor:[UIColor clearColor]];
        [contentView addSubview:statusHeaderLabel];
        
        separatorView = [[UIView alloc] initWithFrame:CGRectMake(15, 29, contentView.bounds.size.width - 30, 1.0f)];
        [separatorView setBackgroundColor:RGB(196, 197, 200)];
        [contentView addSubview:separatorView];
        
        [self.contentView addSubview:contentView];
    }
    
    return self;
}

- (void)setHideSeparatorView:(BOOL)inHideSeparatorView
{
    _hideSeparatorView = inHideSeparatorView;
    [separatorView setHidden:_hideSeparatorView];
}

@end
