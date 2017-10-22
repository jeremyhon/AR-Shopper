/**
 Copyright © 2017 Visa. All rights reserved.
 */

#import "ViewController.h"
#import "VisaCheckoutButton+Designable.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet VisaCheckoutButton *checkoutButton;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /// See the documentation/headers for `VisaPurchaseInfo` for
    /// various ways to customize the purchase experience.
    VisaCurrencyAmount *total = [[VisaCurrencyAmount alloc] initWithDouble:22.09];
    VisaPurchaseInfo *purchaseInfo = [[VisaPurchaseInfo alloc] initWithTotal:total
                                                                    currency:VisaCurrencyUsd];
    purchaseInfo.reviewAction = VisaReviewActionPay;
    
    [self.checkoutButton
     onCheckoutWithPurchaseInfo:purchaseInfo
     completion:^(VisaCheckoutResult *result) {
         switch (result.statusCode) {
             case VisaCheckoutResultStatusSuccess:
                 NSLog(@"Encrypted key: %@", result.encryptedKey);
                 NSLog(@"Payment data: %@", result.encryptedPaymentData);
                 break;
             case VisaCheckoutResultStatusUserCancelled:
                 NSLog(@"Payment cancelled by the user");
                 break;
             default:
                 break;
         }
     }];
}
@end
