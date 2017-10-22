/**
 Copyright © 2017 Visa. All rights reserved.
 */

#import "AppDelegate.h"
@import VisaCheckoutSDK;

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    VisaProfile *profile = [[VisaProfile alloc] initWithEnvironment:VisaEnvironmentSandbox
                                                             apiKey:@"<#Your API Key goes here#>"
                                                        profileName:nil];
    /// An arbitrary example of some configuration details you can customize.
    /// See the documentation/headers for `Profile`.
    profile.datalevel = VisaDataLevelFull;
    [profile acceptedCardBrands: @[@(VisaCardBrandVisa),
                                   @(VisaCardBrandMastercard),
                                   @(VisaCardBrandDiscover)]];
    
    [VisaCheckoutSDK configureWithProfile:profile
                                   result:nil];
    
    return YES;
}
@end
