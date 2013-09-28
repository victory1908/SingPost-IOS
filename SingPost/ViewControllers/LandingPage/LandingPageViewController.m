//
//  LandingPageViewController.m
//  SingPost
//
//  Created by Edward Soetiono on 24/9/13.
//  Copyright (c) 2013 Codigo. All rights reserved.
//

#import "LandingPageViewController.h"
#import "AppDelegate.h"
#import "UIFont+SingPost.h"
#import "UIColor+SingPost.h"

//FIXME: remove
#import "TrackingMainViewController.h"

@interface TrackingNumberTextField : UITextField

@end

@implementation TrackingNumberTextField

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor SingPostBlueColor];
        self.font = [UIFont SingPostRegularFontOfSize:INTERFACE_IS_4INCHSCREEN ? 16.0f : 14.0f fontKey:kSingPostFontOpenSans];
    }
    
    return self;
}

- (void)drawPlaceholderInRect:(CGRect)rect {
    [[UIColor SingPostBlueColor] setFill];
    [[self placeholder] drawInRect:INTERFACE_IS_4INCHSCREEN ? CGRectInset(rect, 0, 0) : CGRectInset(rect, 0, 0)
                          withFont:[UIFont SingPostLightItalicFontOfSize:INTERFACE_IS_4INCHSCREEN ? 16.0f : 14.0f fontKey:kSingPostFontOpenSans]];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return INTERFACE_IS_4INCHSCREEN ? CGRectInset(bounds, 5, 12) : CGRectInset(bounds, 5, 6);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return INTERFACE_IS_4INCHSCREEN ? CGRectInset(bounds, 5, 12) : CGRectInset(bounds, 5, 6);
}

@end

@interface LandingPageViewController () <UITextFieldDelegate>

@end

@implementation LandingPageViewController
{
    TrackingNumberTextField *trackingNumberTextField;
}

- (void)test
{
    TrackingMainViewController *track = [[TrackingMainViewController alloc] initWithNibName:nil bundle:nil];
    [self presentNatGeoViewController:track];
}

#pragma mark - View lifecycle

- (void)loadView
{
    UIView *contentView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *envelopBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:INTERFACE_IS_4INCHSCREEN ? @"background_envelope" : @"35iphone_background_envelope"]];
    [envelopBackgroundImageView setUserInteractionEnabled:YES];
    [envelopBackgroundImageView setFrame:INTERFACE_IS_IPAD ? CGRectMake(0, 0, 768, 690) : (INTERFACE_IS_4INCHSCREEN ? CGRectMake(0, 0, 320, 276) : CGRectMake(0, 0, 320, 248))];
    [contentView addSubview:envelopBackgroundImageView];
    
    UIImageView *trackingTextBoxBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trackingTextBox"]];
    [trackingTextBoxBackgroundImageView setFrame:INTERFACE_IS_4INCHSCREEN ? CGRectMake(15, 80, 290, 47) : CGRectMake(15, 70, 290, 30)];
    [contentView addSubview:trackingTextBoxBackgroundImageView];
    
    trackingNumberTextField = [[TrackingNumberTextField alloc] initWithFrame:INTERFACE_IS_4INCHSCREEN ? CGRectMake(20, 80, 240, 47) : CGRectMake(20, 70, 245, 30)];
    [trackingNumberTextField setBackgroundColor:[UIColor clearColor]];
    [trackingNumberTextField setPlaceholder:@"Last tracking number entered"];
    [trackingNumberTextField setDelegate:self];
    [contentView addSubview:trackingNumberTextField];
    
    UIButton *findTrackingNumberButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [findTrackingNumberButton setImage:[UIImage imageNamed:@"tracking_button"] forState:UIControlStateNormal];
    [findTrackingNumberButton setFrame:INTERFACE_IS_4INCHSCREEN ? CGRectMake(265, 87, 35, 35) : CGRectMake(273, 71, 29, 29)];
    [findTrackingNumberButton addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:findTrackingNumberButton];
    
    UIImageView *singPostLogoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_singaporepost"]];
    [singPostLogoImageView setFrame:INTERFACE_IS_IPAD ? CGRectMake(0, 0, 0, 0) : CGRectMake(82, 8, 155, 55)];
    [contentView addSubview:singPostLogoImageView];
    
    UIButton *toggleSidebarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [toggleSidebarButton setFrame:CGRectMake(10, 10, 30, 30)];
    [toggleSidebarButton setImage:[UIImage imageNamed:@"sidebar_button"] forState:UIControlStateNormal];
    [toggleSidebarButton addTarget:self action:@selector(toggleSidebarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:toggleSidebarButton];
    
    //landing page buttons
#define NUM_ICON_HORIZONTAL 3.0f
#define ICON_WIDTH (INTERFACE_IS_4INCHSCREEN ? 90.0f : 80.0f)
#define ICON_HEIGHT (INTERFACE_IS_4INCHSCREEN ? 90.0f : 80.0f)
#define ICON_SPACING_VERTICAL (INTERFACE_IS_4INCHSCREEN ? 10.0f : 5.0f)
#define STARTING_OFFSET_X (INTERFACE_IS_4INCHSCREEN ? 30.0f : 40.0f)
#define STARTING_OFFSET_Y (INTERFACE_IS_4INCHSCREEN ? 230.0f : 185.0f)
    CGFloat offsetX, offsetY;
    
    offsetY = STARTING_OFFSET_Y;
    offsetX = STARTING_OFFSET_X;
    UIButton *menuCalculatePostageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuCalculatePostageButton setFrame:CGRectMake(offsetX, offsetY, ICON_WIDTH, ICON_HEIGHT)];
    [menuCalculatePostageButton setImage:[UIImage imageNamed:@"landing_calculatePostage"] forState:UIControlStateNormal];
    [menuCalculatePostageButton setTag:APP_PAGE_CALCULATEPOSTAGE];
    [menuCalculatePostageButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:menuCalculatePostageButton];

    offsetX += ICON_WIDTH;
    UIButton *menuPostalCodesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuPostalCodesButton setFrame:CGRectMake(offsetX, offsetY, ICON_WIDTH, ICON_HEIGHT)];
    [menuPostalCodesButton setImage:[UIImage imageNamed:@"landing_postalCodes"] forState:UIControlStateNormal];
    [menuPostalCodesButton setTag:APP_PAGE_POSTALCODES];
    [menuPostalCodesButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:menuPostalCodesButton];
    
    offsetX += ICON_WIDTH;
    UIButton *menuPageLocateUsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuPageLocateUsButton setFrame:CGRectMake(offsetX, offsetY, ICON_WIDTH, ICON_HEIGHT)];
    [menuPageLocateUsButton setImage:[UIImage imageNamed:@"landing_locateUs"] forState:UIControlStateNormal];
    [menuPageLocateUsButton setTag:APP_PAGE_LOCATEUS];
    [menuPageLocateUsButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:menuPageLocateUsButton];

    offsetX = STARTING_OFFSET_X;
    offsetY += ICON_HEIGHT + ICON_SPACING_VERTICAL;
    UIButton *menuSendReceiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuSendReceiveButton setFrame:CGRectMake(offsetX, offsetY, ICON_WIDTH, ICON_HEIGHT)];
    [menuSendReceiveButton setImage:[UIImage imageNamed:@"landing_sendReceive"] forState:UIControlStateNormal];
    [contentView addSubview:menuSendReceiveButton];
    
    offsetX += ICON_WIDTH;
    UIButton *menuPayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuPayButton setFrame:CGRectMake(offsetX, offsetY, ICON_WIDTH, ICON_HEIGHT)];
    [menuPayButton setImage:[UIImage imageNamed:@"landing_pay"] forState:UIControlStateNormal];
    [contentView addSubview:menuPayButton];
    
    offsetX += ICON_WIDTH;
    UIButton *menuShopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuShopButton setFrame:CGRectMake(offsetX, offsetY, ICON_WIDTH, ICON_HEIGHT)];
    [menuShopButton setImage:[UIImage imageNamed:@"landing_shop"] forState:UIControlStateNormal];
    [contentView addSubview:menuShopButton];
    
    offsetX = STARTING_OFFSET_X;
    offsetY += ICON_HEIGHT + ICON_SPACING_VERTICAL;
    UIButton *menuMoreServicesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuMoreServicesButton setFrame:CGRectMake(offsetX, offsetY, ICON_WIDTH, ICON_HEIGHT)];
    [menuMoreServicesButton setImage:[UIImage imageNamed:@"landing_moreServices"] forState:UIControlStateNormal];
    [contentView addSubview:menuMoreServicesButton];
    
    offsetX += ICON_WIDTH;
    UIButton *menuStampCollectiblesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuStampCollectiblesButton setFrame:CGRectMake(offsetX, offsetY, ICON_WIDTH, ICON_HEIGHT)];
    [menuStampCollectiblesButton setImage:[UIImage imageNamed:@"landing_stampCollectibles"] forState:UIControlStateNormal];
    [contentView addSubview:menuStampCollectiblesButton];
    
    offsetX += ICON_WIDTH;
    UIButton *menuOffersButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuOffersButton setFrame:CGRectMake(offsetX, offsetY, ICON_WIDTH, ICON_HEIGHT)];
    [menuOffersButton setImage:[UIImage imageNamed:@"landing_offers"] forState:UIControlStateNormal];
    [contentView addSubview:menuOffersButton];

    UIImageView *backgroundMore = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"background_more"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 20, 10, 20)]];
    [backgroundMore setFrame:CGRectMake(0, contentView.bounds.size.height - 46, contentView.bounds.size.width, 26)];
    [contentView addSubview:backgroundMore];
    
    //gesture recognizers
    UITapGestureRecognizer *dismissTrackingNumberKeyboardTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTrackingNumberKeyboard:)];
    [envelopBackgroundImageView addGestureRecognizer:dismissTrackingNumberKeyboardTapRecognizer];
    
    self.view = contentView;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
                                                                          
#pragma mark - Gesture recognizers
                                                                          
- (IBAction)dismissTrackingNumberKeyboard:(id)sender
{
    [trackingNumberTextField resignFirstResponder];
}

#pragma mark - IBActions

- (IBAction)menuButtonClicked:(UIButton *)sender
{
    [[AppDelegate sharedAppDelegate].rootViewController goToAppPage:(tAppPages)sender.tag];
}

- (IBAction)toggleSidebarButtonClicked:(id)sender
{
    [[AppDelegate sharedAppDelegate].rootViewController toggleSideBarVisiblity];
}

@end
