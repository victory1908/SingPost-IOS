//
//  ApiClient.m
//  SingPost
//
//  Created by Edward Soetiono on 8/10/13.
//  Copyright (c) 2013 Codigo. All rights reserved.
//

#import "ApiClient.h"
#import "EntityLocation.h"
#import "TrackedItem.h"
#import "Stamp.h"
#import <SSKeychain.h>
#import "UIAlertView+Blocks.h"
#import "NSDictionary+Additions.h"
#import <sys/sysctl.h>
#import "DeliveryStatus.h"

@implementation ApiClient
@synthesize serverToken;
@synthesize fbToken;
@synthesize allTrackingItem;
@synthesize fbID;

@synthesize notificationProfileID = _notificationProfileID;


static BOOL isProduction = NO;

#define SINGPOST_BASE_URL   (isProduction ? SINGPOST_PRODUCTION_BASE_URL:SINGPOST_UAT_BASE_URL)
#define CMS_BASE_URL        (isProduction ? CMS_PRODUCTION_BASE_URL:CMS_UAT_BASE_URL)
#define CMS_BASE_URL_V4     (isProduction ? CMS_PRODUCTION_BASE_URL_V4:CMS_UAT_BASE_URL_V4)

//Development
static NSString *const SINGPOST_UAT_BASE_URL = @"https://uatesb1.singpost.com";
static NSString *const CMS_UAT_BASE_URL = @"http://27.109.106.170/mobile2/";
static NSString *const CMS_UAT_BASE_URL_V4 = @"http://27.109.106.170/mobile2/v4/";

//Production
static NSString *const SINGPOST_PRODUCTION_BASE_URL = @"https://prdesb1.singpost.com";
static NSString *const CMS_PRODUCTION_BASE_URL = @"http://mobile.singpost.com/mobile2/";
static NSString *const CMS_PRODUCTION_BASE_URL_V4 = @"http://mobile.singpost.com/mobile2/v4/";

static NSString *const APP_ID = @"M00002";
static NSString *const OS = @"ios";

//Tracking testing URL
//static NSString * const TRACKING_TEST_URL = @"https://prdesb1.singpost.com/ma/GetItemTrackingDetailsCentralTnT";
static NSString * const TRACKING_TEST_URL = @"https://uatesb1.singpost.com/ma/GetItemTrackingDetailsCentralTnT";

#pragma mark - Shared singleton instance

+ (ApiClient *)sharedInstance {
    static ApiClient *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:SINGPOST_BASE_URL]];
    });
    
    return sharedInstance;
}

- (id)initWithBaseURL:(NSURL *)url
{
    if ((self = [super initWithBaseURL:url])) {
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    }
    
    return self;
}

#pragma mark - Properties

- (BOOL)hasRegisteredProfileId
{
    return [[self notificationProfileID] length] > 0;
}

- (NSString *)notificationProfileID
{
    if (!_notificationProfileID) {
        _notificationProfileID = [SSKeychain passwordForService:KEYCHAIN_SERVICENAME account:@"SETTINGS_PROFILEID"];
    }
    return _notificationProfileID;
}

- (void)setNotificationProfileID:(NSString *)inNotificationProfileID
{
    if (inNotificationProfileID.length > 0) {
        _notificationProfileID = inNotificationProfileID;
        [SSKeychain setPassword:_notificationProfileID forService:KEYCHAIN_SERVICENAME account:@"SETTINGS_PROFILEID"];
    }
}

#pragma mark - API calls

#pragma mark - Informations

- (void)getSingpostContentsOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"singpost-contents.php"
                                                                              relativeToURL:[NSURL URLWithString:CMS_BASE_URL]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getSendReceiveItemsOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"apisendreceive.php"
                                                                              relativeToURL:[NSURL URLWithString:CMS_BASE_URL_V4]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getPayItemsOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"apipay.php"
                                                                              relativeToURL:[NSURL URLWithString:CMS_BASE_URL_V4]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getShopItemsOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"apishoponline.php"
                                                                              relativeToURL:[NSURL URLWithString:CMS_BASE_URL_V4]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getServicesItemsOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"apiservices.php"
                                                                              relativeToURL:[NSURL URLWithString:CMS_BASE_URL_V4]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getOffersItemsOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"singpost-updates.php" relativeToURL:[NSURL URLWithString:CMS_BASE_URL]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    [self enqueueHTTPRequestOperation:operation];
}


- (void)getSingPostAppsItemsOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"apiapps.php"
                                                                              relativeToURL:[NSURL URLWithString:CMS_BASE_URL_V4]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getSingpostAnnouncementSuccess:(ApiClientSuccess)success failure:(ApiClientFailure)failure {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"apiannouncement.php"
                                                                              relativeToURL:[NSURL URLWithString:CMS_BASE_URL_V4]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

#pragma mark - Calculate Postage

- (void)calculateSingaporePostageForFromPostalCode:(NSString *)fromPostalCode
                                   andToPostalCode:(NSString *)toPostalCode
                                         andWeight:(NSString *)weightInGrams
                                         onSuccess:(ApiClientSuccess)success
                                         onFailure:(ApiClientFailure)failure {
    NSString *xml = [NSString stringWithFormat:@"<SingaporePostalInfoDetailsRequest xmlns=\"http://singpost.com/paw/ns\">"
                     "<ToPostalCode>%@</ToPostalCode>"
                     "<FromPostalCode>%@</FromPostalCode>"
                     "<Weight>%@</Weight>"
                     "<DeliveryServiceName></DeliveryServiceName>"
                     "</SingaporePostalInfoDetailsRequest>", toPostalCode, fromPostalCode, weightInGrams];
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"ma/FilterSingaporePostalInfo" parameters:nil];
    [request addValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d", [xml length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLElement) {
        if (success)
            success(XMLElement);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLElement) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:xml message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)calculateOverseasPostageForCountryCode:(NSString *)countryCode
                                     andWeight:(NSString *)weightInGrams
                               andItemTypeCode:(NSString *)itemTypeCode
                               andDeliveryCode:(NSString *)deliveryCode
                                     onSuccess:(ApiClientSuccess)success
                                     onFailure:(ApiClientFailure)failure {
    if (deliveryCode == nil || [deliveryCode length] <= 0)
        deliveryCode = @"999";
    
    NSString *xml = [NSString stringWithFormat:@"<OverseasPostalInfoDetailsRequest xmlns=\"http://singpost.com/paw/ns\">"
                     "<Country>%@</Country>"
                     "<Weight>%@</Weight>"
                     "<DeliveryServiceName></DeliveryServiceName>"
                     "<ItemType>%@</ItemType>"
                     "<PriceRange>999</PriceRange>"
                     "<DeliveryTimeRange>%@</DeliveryTimeRange>"
                     "</OverseasPostalInfoDetailsRequest>", countryCode, weightInGrams, itemTypeCode, deliveryCode];
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"ma/FilterOverseasPostalInfo" parameters:nil];
    [request addValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d", [xml length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLElement) {
        if (success)
            success(XMLElement);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLElement) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:xml message:[error description]];
    }];
    [self enqueueHTTPRequestOperation:operation];
}

#pragma mark - Postal Code

- (void)findPostalCodeForBuildingNo:(NSString *)buildingNo
                      andStreetName:(NSString *)streetName
                          onSuccess:(ApiClientSuccess)success
                          onFailure:(ApiClientFailure)failure {
    NSString *xml = [NSString stringWithFormat:@"<PostalCodeByStreetDetailsRequest xmlns=\"http://singpost.com/paw/ns\">"
                     "<BuildingNo>%@</BuildingNo>"
                     "<StreetName>%@</StreetName>"
                     "</PostalCodeByStreetDetailsRequest>", buildingNo, streetName];
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"ma/PostalCodebyStreet" parameters:nil];
    [request addValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d", [xml length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLElement) {
        if (success)
            success(XMLElement);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLElement) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:xml message:[error description]];
    }];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)findPostalCodeForLandmark:(NSString *)landmark
                        onSuccess:(ApiClientSuccess)success
                        onFailure:(ApiClientFailure)failure {
    NSString *xml = [NSString stringWithFormat:@"<PostalAddressByLandMarkDetailsRequest  xmlns=\"http://singpost.com/paw/ns\"><BuildingName>%@</BuildingName></PostalAddressByLandMarkDetailsRequest>", landmark];
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"ma/PostalAddressbyLandMark" parameters:nil];
    [request addValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d", [xml length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLElement) {
        if (success)
            success(XMLElement);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLElement) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:xml message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)findPostalCodeForWindowsDeliveryNo:(NSString *)windowsDeliveryNo andType:(NSString *)type andPostOffice:(NSString *)postOffice onSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
    NSString *xml = [NSString stringWithFormat:@"<PostalCodeByPOBoxDetailsRequest xmlns=\"http://singpost.com/paw/ns\"><WindowDeliveryNo>%@</WindowDeliveryNo><Type>%@</Type><PostOffice>%@</PostOffice></PostalCodeByPOBoxDetailsRequest>", windowsDeliveryNo, type, postOffice];
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"ma/PostalCodebyPOBox" parameters:nil];
    [request addValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d", [xml length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLElement) {
        if (success)
            success(XMLElement);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLElement) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:xml message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

#pragma mark - Locations

- (void)getPostingBoxLocationsOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"postingbox.php" relativeToURL:[NSURL URLWithString:CMS_BASE_URL]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getPostOfficeLocationsOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"postoffice.php" relativeToURL:[NSURL URLWithString:CMS_BASE_URL]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getSamLocationsOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"sam.php" relativeToURL:[NSURL URLWithString:CMS_BASE_URL]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getPostalAgentLocationsOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"api-postalagent.php" relativeToURL:[NSURL URLWithString:CMS_BASE_URL]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getSingPostAgentLocationsOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"api-speedpostagent.php" relativeToURL:[NSURL URLWithString:CMS_BASE_URL]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getPopStationLocationsOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"api-popstation.php" relativeToURL:[NSURL URLWithString:CMS_BASE_URL]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getLocationsUpdatesOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"apilocationversion.php" relativeToURL:[NSURL URLWithString:CMS_BASE_URL_V4]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getLocationsUpdatesDetails:(NSArray *)array
                           success:(ApiClientSuccess)success
                           failure:(ApiClientFailure)failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:[NSString stringWithFormat:@"%@apilocationdetails.php",CMS_BASE_URL_V4]
                                                parameters:@{@"ids":array}];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:[NSString stringWithFormat:@"%@",array] message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

#pragma mark - Tracking

- (void)getItemTrackingDetailsForTrackingNumber:(NSString *)trackingNumber onSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
    NSString *xml = [NSString stringWithFormat: @"<ItemTrackingDetailsRequest xmlns=\"http://singpost.com/paw/ns\">"
                     "<ItemTrackingNumbers>"
                     "<TrackingNumber>%@</TrackingNumber>"
                     "</ItemTrackingNumbers>"
                     "</ItemTrackingDetailsRequest>", [trackingNumber uppercaseString]];
    
#warning TESTING URL
    
    /*NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:TRACKING_TEST_URL
                                                parameters:nil];*/
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"ma/GetItemTrackingDetails" parameters:nil];
    
    [request addValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d", [xml length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLElement) {
        if (success)
            success(XMLElement);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLElement) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:xml message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)batchUpdateTrackedItems:(NSArray *)trackedItems onSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure withProgressCompletion:(ApiClientProgressCompletion)progressCompletion
{
    NSMutableArray *updateOperations = [NSMutableArray array];
    
#define NUM_ITEMS_PER_API 10
    NSUInteger chunk = 0;
    NSArray *chunkedTrackedItems;
    do {
        chunkedTrackedItems = [trackedItems subarrayWithRange:NSMakeRange(chunk * NUM_ITEMS_PER_API, MIN(trackedItems.count - (chunk * NUM_ITEMS_PER_API), NUM_ITEMS_PER_API))];
        
        if (chunkedTrackedItems.count > 0) {
            NSMutableString *trackingNumbersXml = [NSMutableString string];
            for (TrackedItem *trackedItem in chunkedTrackedItems) {
                [trackingNumbersXml appendFormat:@"<TrackingNumber>%@</TrackingNumber>", [trackedItem.trackingNumber uppercaseString]];
            }
            
            NSString *xml = [NSString stringWithFormat: @"<ItemTrackingDetailsRequest xmlns=\"http://singpost.com/paw/ns\">"
                             "<ItemTrackingNumbers>"
                             "%@"
                             "</ItemTrackingNumbers>"
                             "</ItemTrackingDetailsRequest>", trackingNumbersXml];
            
            NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"ma/GetItemTrackingDetails" parameters:nil];
            [request addValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request addValue:[NSString stringWithFormat:@"%d", [xml length]] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
            
            AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLElement) {
                if (success)
                    success(XMLElement);
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLElement) {
                if (failure)
                    failure(error);
            }];
            
            [updateOperations addObject:operation];
        }
        
        chunk++;
    } while((chunk * NUM_ITEMS_PER_API) < trackedItems.count);
    
    [self enqueueBatchOfHTTPRequestOperations:updateOperations
                                progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                                    if (progressCompletion)
                                        progressCompletion(numberOfFinishedOperations, totalNumberOfOperations);
                                } completionBlock:^(NSArray *operations) {
                                    //do nothing
                                }];
}

#pragma mark - Notifications

- (void)registerAPNSToken:(NSString *)apnsToken onSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
    NSString *xml = [NSString stringWithFormat: @"<RegisterRequest>"
                     "<PushID>%@</PushID>"
                     "<AppID>%@</AppID>"
                     "<OS>%@</OS>"
                     "</RegisterRequest>", apnsToken, APP_ID, OS];
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"ma/notify/registration/add" parameters:nil];
    [request addValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d", [xml length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLElement) {
        if (success) {
            success(XMLElement);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLElement) {
        if (failure) {
            failure(error);
            double delayInSeconds = 30;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                [self registerAPNSToken:apnsToken onSuccess:^(id responseObject){} onFailure:^(NSError *error){}];
            });
            [self reportAPIIssueURL:[request.URL absoluteString] payload:xml message:[error description]];
        }
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)subscribeNotificationForTrackingNumber:(NSString *)trackingNumber onSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
    NSString *xml = [NSString stringWithFormat: @"<SubscribeRequest>"
                     "<ProfileID>%@</ProfileID>"
                     "<ItemNumberList><ItemNumber>%@</ItemNumber></ItemNumberList>"
                     "</SubscribeRequest>", [self notificationProfileID], trackingNumber];
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"ma/notify/subscription/add" parameters:nil];
    [request addValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d", [xml length]] forHTTPHeaderField:@"Content-Length"];
    
    NSData * data = [xml dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    
    AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLElement) {
        if (success)
            success(XMLElement);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLElement) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:xml message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)subscribeNotificationForTrackingNumberArray:(NSArray *)trackingNumberArray
                                          onSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure {
    NSString *xml = [NSString stringWithFormat: @"<SubscribeRequest>"
                     "<ProfileID>%@</ProfileID>"
                     "<ItemNumberList>", [self notificationProfileID]];
    
    for(NSString * itemNumber in trackingNumberArray) {
        xml = [xml stringByAppendingString:[NSString stringWithFormat:@"<ItemNumber>%@</ItemNumber>",itemNumber]];
    }
    xml = [xml stringByAppendingString:@"</ItemNumberList>""</SubscribeRequest>"];
    
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"ma/notify/subscription/add" parameters:nil];
    [request addValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d", [xml length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLElement) {
        if (success)
            success(XMLElement);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLElement) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:xml message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)unsubscribeNotificationForTrackingNumber:(NSString *)trackingNumber onSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
    NSString *xml = [NSString stringWithFormat: @"<UnsubscribeRequest>"
                     "<ProfileID>%@</ProfileID>"
                     "<ItemNumberList><ItemNumber>%@</ItemNumber></ItemNumberList>"
                     "</UnsubscribeRequest>", [self notificationProfileID], trackingNumber];
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"ma/notify/subscription/remove" parameters:nil];
    [request addValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d", [xml length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLElement) {
        if (success)
            success(XMLElement);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLElement) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:xml message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)unsubscribeNotificationForTrackingNumberArray:(NSArray *)trackingNumberArray onSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
    NSString *xml = [NSString stringWithFormat: @"<UnsubscribeRequest>"
                     "<ProfileID>%@</ProfileID>"
                     "<ItemNumberList>", [self notificationProfileID]];
    
    for(NSString * itemNumber in trackingNumberArray) {
        xml = [xml stringByAppendingString:[NSString stringWithFormat:@"<ItemNumber>%@</ItemNumber>",itemNumber]];
    }
    xml = [xml stringByAppendingString:@"</ItemNumberList>""</UnsubscribeRequest>"];
    
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"ma/notify/subscription/remove" parameters:nil];
    [request addValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d", [xml length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLElement) {
        if (success)
            success(XMLElement);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLElement) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:xml message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}


#pragma mark - Philately

- (void)getStampsOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"singpost-philately.php" relativeToURL:[NSURL URLWithString:CMS_BASE_URL]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getImagesOfStamp:(Stamp*)stamp onSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"singpost-philately-images.php?album=%d", stamp.serverIdValue] relativeToURL:[NSURL URLWithString:CMS_BASE_URL]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getMaintananceStatusOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"apimaintenance.php" relativeToURL:[NSURL URLWithString:CMS_BASE_URL_V4]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

#pragma mark - Feedback

- (void)postFeedbackMessage:(NSString *)message subject:(NSString *)subject onSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure
{
#define FEEDBACK_EMAIL_ADDRESS @"mobilityAtSP@singpost.com,chirag@singpost.com"
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"ma/feedback/send" parameters:nil];
    [request addValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [request addValue:FEEDBACK_EMAIL_ADDRESS forHTTPHeaderField:@"EmailTo"];
    [request addValue:APP_ID forHTTPHeaderField:@"AppID"];
    [request addValue:subject forHTTPHeaderField:@"Subject"];
    [request setHTTPBody:[message dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if ([responseString isEqualToString:@"ACCEPTED"]) {
            if (success) {
                success(responseString);
            }
        }
        else {
            if (failure) {
                failure([NSError errorWithDomain:ERROR_DOMAIN code:1 userInfo:@{NSLocalizedDescriptionKey: responseString}]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
            [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
        }
    }];
    [self enqueueHTTPRequestOperation:operation];
}

#pragma mark - Bug reporting
- (void)reportAPIIssueURL:(NSString *)url payload:(NSString *)payload message:(NSString *)message {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValidObject:@"iOS" forKey:@"OS"];
    [params setValidObject:[[UIDevice currentDevice] systemVersion] forKey:@"OSVersion"];
    [params setValidObject:@"M00002" forKey:@"ApplicationId"];
    [params setValidObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"ApplicationVersion"];
    [params setValidObject:url forKey:@"APILink"];
    [params setValidObject:payload forKey:@"Payload"];
    [params setValidObject:message forKey:@"ErrorMessage"];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"dd-MM-yyyy HH:mm:ss";
    NSString *date = [formatter stringFromDate:[NSDate date]];
    [params setValidObject:date forKey:@"Timestamp"];
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:[NSString stringWithFormat:@"%@apisavelogs.php",CMS_BASE_URL_V4]
                                                parameters:params];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                    }];
    [self enqueueHTTPRequestOperation:operation];
}

#pragma mark - App version

- (void)checkAppUpdateWithAppVer:(NSString *)appVer andOSVer:(NSString *)osVer {
    NSString *fullPath = [NSString stringWithFormat:@"%@/ma/versionchecker/checkversion?applicationId=%@&applicationVersion=%@&os=IOS&osVersion=%@",SINGPOST_BASE_URL,APP_ID,appVer,osVer];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullPath]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self handleAppUpdateResponse:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)handleAppUpdateResponse:(NSDictionary *)responseJSON {
    NSInteger statusCode = [responseJSON[@"status"]integerValue];
    switch (statusCode) {
        case 1:
        {
            //Must update
            [UIAlertView showWithTitle:nil
                               message:[responseJSON[@"message"]stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"]
                     cancelButtonTitle:@"Update Now"
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      NSString *linkToAppStore = responseJSON[@"link"];
                                      if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:linkToAppStore]])
                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkToAppStore]];
                                  }
                              }];
            
            break;
        }
        case 2:
        {
            //Unsupported OS
            break;
        }
        case 3:
        {
            NSDate * checkUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"checkUpdateDate"];
            NSTimeInterval timeFromLastCheck = [checkUpdateDate timeIntervalSinceNow];
            
            if (checkUpdateDate == nil || timeFromLastCheck < -86400) //86400 seconds in 24hours
            {
                //Update available
                [UIAlertView showWithTitle:nil
                                   message:[responseJSON[@"message"]stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"]
                         cancelButtonTitle:@"Maybe Later"
                         otherButtonTitles:@[@"Update Now"]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      if (buttonIndex != [alertView cancelButtonIndex]) {
                                          NSString *linkToAppStore = responseJSON[@"link"];
                                          if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:linkToAppStore]])
                                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkToAppStore]];
                                      }
                                  }];
                //Reset check update date
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"checkUpdateDate"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            break;
        }
        case 4:
        {
            //No upgrade
            break;
        }
        case 500:
        {
            //Validation fail
            break;
        }
        default:
            break;
    }
}

#pragma mark - Ad Banner

-(void ) getAdvertisementWithId : (NSString *)locationMasterId Count:(NSString *)count onSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure {
    
    
    NSString * url = [NSString stringWithFormat:@"https://uat.vbox.com.sg:8083/restful-services/advertisementServices/getAdvertisement/%@/%@",locationMasterId,count];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url ]];
    
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    [self enqueueHTTPRequestOperation:operation];


}

-(void) incrementClickCountWithId: (NSString *)locationId onSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure {
    NSString * url = [NSString stringWithFormat:@"https://uat.vbox.com.sg:8083/restful-services/advertisementServices/incrementClickCount/%@",locationId];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url ]];
    
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    [self enqueueHTTPRequestOperation:operation];
}

#pragma mark - Tracking labeling

//CAAUvvzfCKB8BAOEmKK1qULoNzZBQUm87XZCVILlZCXEbnojy138U3EeeOFc0BWT4MXQhk4zGc9elxZAuTJ5wjqZBDahoQWZCLecjidMurZBfqjCUcDdNGtlX59CqeSdPE6PW4D79ifcWt84xDt901Y6TGEFNgeZAnqn06zD0QX0XZCLXTJbKwD7vX6hVvAZC0Duiw4Q7pcC6BpZCm3Ix92i5riH

#define TEST_FB_TOKEN @"CAAUvvzfCKB8BABZBlEv7uvEwHk6WmImULD6NgzwhZBBCxZAdpvbmVHKqbKNx7YyWogbHY5KPGE3ZAh3I6SUdeDqZCjXDThNEQut3e8JBXtwjk3vZBPwjgTI2kfSMRitoA4P0uhHfdga66ZC3MCFDQw8ngvysZB4KltFq5f7IqkYSisF17aMuszTi4QXynWGTLYQMirtUTcjQ36eiB8hI4b71m5vOwzyZBKvAZD"



- (void) facebookLoginOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure{
    NSString * url = @"http://27.109.106.170/singpost3/api/login/k3y15k3y";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url ]];
    [request setHTTPMethod:@"POST"];
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    NSString * postString = [NSString stringWithFormat:@"fb_token=%@&device=iPhone&model=%@&privacy_policy=1&pdpa=0",fbToken,[self platformType:platform]];
    
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    [self enqueueHTTPRequestOperation:operation];
}

- (void) registerTrackingNunmbers: (NSArray *)numbers WithLabels : (NSArray *)labels TrackDetails : (NSArray *) details onSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure{
    NSString * url = @"http://27.109.106.170/singpost3/api/registertracking/k3y15k3y";
    
    NSString * str = [self getNumberAndLabelString:numbers WithLabels:labels];
    NSString * payload = [self getTrackingDetailString:details];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url ]];
    [request setHTTPMethod:@"POST"];
    NSString * postString = [NSString stringWithFormat:@"server_token=%@%@%@",serverToken,str,payload];
    postString = [postString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    [self enqueueHTTPRequestOperation:operation];
    
}

- (void) deleteAllTrackingNunmbersOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure{
    NSString * url = @"http://27.109.106.170/singpost3/api/removealltrackings/k3y15k3y";
    
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url ]];
    [request setHTTPMethod:@"POST"];
    NSString * postString = [NSString stringWithFormat:@"server_token=%@",serverToken];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    [self enqueueHTTPRequestOperation:operation];
    
}

- (NSString *) getNumberAndLabelString : (NSArray *)numbers WithLabels : (NSArray *)labels {
    NSMutableString * str = [[NSMutableString alloc] init];
    
    int i = 0;
    for(NSString * num in numbers) {
        [str appendString:[NSString stringWithFormat:@"&tracking[%d]=%@",i,num]];
        
        NSString * label = [labels objectAtIndex:i];
        if(![label isEqualToString:@""]) {
            [str appendString:[NSString stringWithFormat:@"||%@",label]];
        }
        i++;
    }
    return str;
}

- (NSString *) getTrackingDetailString : (NSArray *)itemArr {
    NSMutableString * finalStr = [[NSMutableString alloc] init];
    
   // NSMutableArray * arr = [[NSMutableArray alloc] init];
    
    int i = 0;
    for(TrackedItem * item in itemArr) {
        
        NSMutableDictionary * dic1 = [[NSMutableDictionary alloc] init];
        NSMutableDictionary * dic2 = [[NSMutableDictionary alloc] init];
        NSMutableDictionary * dicX = [[NSMutableDictionary alloc] init];
        
        [dic2 setValue:item.originalCountry forKey:@"OriginalCountry"];
        [dic2 setValue:item.trackingNumber forKey:@"TrackingNumber"];
        [dic2 setValue:(item.isFoundValue?@"true":@"false") forKey:@"TrackingNumberFound"];
        [dic2 setValue:item.destinationCountry forKey:@"DestinationCountry"];
        [dic2 setValue:item.isActive forKey:@"TrackingNumberActive"];
        
        [dic2 setValue:@"" forKey:@"AlternativeTrackingNumber"];
        [dic2 setValue:@"" forKey:@"InsuredSDR"];
        [dic2 setValue:@"" forKey:@"ExpressInd"];
        [dic2 setValue:@"" forKey:@"ReceptacleID"];
        [dic2 setValue:@"" forKey:@"PostingDate"];
        [dic2 setValue:@"" forKey:@"Weight"];
        [dic2 setValue:@"" forKey:@"ItemCategory"];
        [dic2 setValue:@"" forKey:@"InsuredValue"];
        [dic2 setValue:@"" forKey:@"PreadviceDate"];
        [dic2 setValue:@"" forKey:@"Content"];
        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"yyyyMMdd' 'HHmmss"];
        
        NSMutableArray * statusArray = [NSMutableArray array];
        
        NSMutableDictionary * dicY = [[NSMutableDictionary alloc] init];
        for(DeliveryStatus * deliveryStatus in item.deliveryStatuses.array) {
            
            NSMutableDictionary * dic3 = [[NSMutableDictionary alloc] init];
            
            [dic3 setValue:deliveryStatus.location forKey:@"Location"];

            [dic3 setValue:deliveryStatus.statusDescription forKey:@"StatusDescription"];

            [dic3 setValue:[dateFormatter stringFromDate:deliveryStatus.date] forKey:@"Date"];
            
            [dic3 setValue:[dateFormatter2 stringFromDate:deliveryStatus.date] forKey:@"AceDate"];
            
            [dic3 setValue:@"" forKey:@"BeatNo"];
            
            [statusArray addObject:dic3];
            
            [dicY setValue:statusArray forKey:@"DeliveryStatusDetail"];
        }
        
        [dic2 setValue:dicY forKey:@"DeliveryStatusDetails"];
        [dicX setValue:dic2 forKey:@"ItemTrackingDetail"];
        [dic1 setValue:dicX forKey:@"ItemsTrackingDetailList"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic1
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        NSString * str;
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
        } else {
            str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        [finalStr appendFormat:[NSString stringWithFormat:@"&tracking_detail[%d]=%@",i,str]];
        
        
        i++;
    }
    
    //[dic1 setValue:arr forKey:@"ItemsTrackingDetailList"];
    
   

    return finalStr;
}

- (void) getAllTrackingNunmbersOnSuccess:(ApiClientSuccess)success onFailure:(ApiClientFailure)failure{
    NSString * url = @"http://27.109.106.170/singpost3/api/gettrackings/k3y15k3y";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url ]];
    [request setHTTPMethod:@"POST"];
    NSString * postString = [NSString stringWithFormat:@"server_token=%@",serverToken];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure)
            failure(error);
        [self reportAPIIssueURL:[request.URL absoluteString] payload:nil message:[error description]];
    }];
    [self enqueueHTTPRequestOperation:operation];
    
}

- (NSString *) platformType:(NSString *)platform
{
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}


@end
