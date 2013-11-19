#import "ItemTracking.h"
#import "ApiClient.h"
#import "DeliveryStatus.h"

@interface ItemTracking ()

// Private interface goes here.

@end


@implementation ItemTracking

- (NSString *)status
{
    DeliveryStatus *firstDeliveryStatus = [self.deliveryStatuses firstObject];
    return firstDeliveryStatus ? firstDeliveryStatus.statusDescription : @"-";
}

+ (ItemTracking *)createIfNotExistsFromXMLElement:(RXMLElement *)el inContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    if (![[[el child:@"TrackingNumberFound"] text] boolValue]) {
        *error = [NSError errorWithDomain:ERROR_DOMAIN code:1 userInfo:@{NSLocalizedDescriptionKey: @"Tracking number not found"}];
        return nil;
    }
    
    NSString *trackingNumber = [[el child:@"TrackingNumber"] text];
    ItemTracking *trackingItem = [ItemTracking MR_findFirstByAttribute:ItemTrackingAttributes.trackingNumber withValue:trackingNumber inContext:context];
    if (!trackingItem) {
        trackingItem = [ItemTracking MR_createInContext:context];
        [trackingItem setAddedOn:[NSDate date]];
        [trackingItem setGroup:@"active"]; //FIXME: how to determine group? hardcoded to active now
    }
    
    [trackingItem setTrackingNumber:trackingNumber];
    [trackingItem setOriginalCountry:[el child:@"OriginalCountry"].text];
    [trackingItem setDestinationCountry:[el child:@"DestinationCountry"].text];
    
    //delete existing status
    for (DeliveryStatus *deliveryStatus in trackingItem.deliveryStatuses) {
        [context deleteObject:deliveryStatus];
    }
    
    //rebuild delivery statuses
    RXMLElement *rxmlItems = [el child:@"DeliveryStatusDetails"];
    
    NSMutableOrderedSet *deliveries = [NSMutableOrderedSet orderedSet];
    for (RXMLElement *rxmlDeliveryStatus in [rxmlItems children:@"DeliveryStatusDetail"]) {
        [deliveries addObject:[DeliveryStatus createFromXMLElement:rxmlDeliveryStatus inContext:context]];
    }
    
    [trackingItem setDeliveryStatuses:deliveries];
    
    return trackingItem;
}

+ (void)API_getItemTrackingDetailsForTrackingNumber:(NSString *)trackingNumber onCompletion:(void(^)(BOOL success, NSError *error))completionBlock
{
    [[ApiClient sharedInstance] getItemTrackingDetailsForTrackingNumber:trackingNumber onSuccess:^(RXMLElement *rootXML) {
        NSLog(@"tracking item response: %@", rootXML);
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            RXMLElement *rxmlItems = [rootXML child:@"ItemsTrackingDetailList"];
            
            for (RXMLElement *rxmlItem in [rxmlItems children:@"ItemTrackingDetail"]) {
                NSError *error;
                [ItemTracking createIfNotExistsFromXMLElement:rxmlItem inContext:localContext error:&error];
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(NO, error);
                    });
                    return;
                }
            }

            [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                if (completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(!error, error);
                    });
                }
            }];
        });
    } onFailure:^(NSError *error) {
        if (completionBlock) {
            completionBlock(NO, error);
        }
    }];
}


@end