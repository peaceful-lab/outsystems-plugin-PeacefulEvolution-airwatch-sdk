//
// Copyright © 2017 VMware, Inc. All rights reserved.
// This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
// AirWatch products may be covered by one or more patents listed at http:www.vmware.com/go/patents.
//

#import "AWDocumentOpenInHandler.h"

@interface AWDocumentOpenInHandler () <UIDocumentInteractionControllerDelegate>

@property (nonatomic, weak) UIViewController *sourceViewController;
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic) BOOL showRestrictedAlert;

@end

@implementation AWDocumentOpenInHandler

- (instancetype)initWithSourceViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        self.sourceViewController = viewController;
    }
    return self;
}

- (void)open:(NSURL *)fileURL{
    self.fileURL = fileURL;
    
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[self tempFileURLfrom:fileURL]];
    self.documentInteractionController.delegate = self;
    
    /* We need to provide a frame from where the menu should appear, keep it as CGRectZero for now since there is no way to find the exact touch point from the cordova web view */
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.sourceViewController.view animated:YES];
    });
    
}

# pragma mark - Helpers
- (BOOL)canOpenInApplication:(NSString *)appBundleID {
    BOOL allowApp = YES;
    if (self.restrictDocumentToApps) allowApp = NO;
    
    if (self.whitelistedApplications) {
        for (NSString *appID in self.whitelistedApplications) {
            if ([appBundleID caseInsensitiveCompare:appID] == NSOrderedSame) {
                allowApp = YES;
                break;
            }
        }
    }
    return allowApp;
}

- (NSURL *)tempFileURLfrom:(NSURL *)originalURL {
    NSString *filename = originalURL.lastPathComponent;
    NSString *directoryPath = [originalURL.path stringByDeletingLastPathComponent];
    NSString *tempPath = [NSString stringWithFormat:@"%@/vmware/%@",directoryPath, filename];
    return  [[NSURL alloc] initFileURLWithPath:tempPath];
}

# pragma mark - UIDocumentInteractionControllerDelegate
- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application{
    BOOL canOpen = [self canOpenInApplication:application];
    if(self.restrictDocumentToApps && !canOpen) {
        NSLog(@"Oopz! Your company policy blocks opening the document to this application");
        self.showRestrictedAlert = YES;
    } else {
        NSLog(@"Opening document to %@", application);
        [controller setURL:self.fileURL];
        self.showRestrictedAlert = NO;
    }
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller{
    if(self.showRestrictedAlert){
        NSLog(@"Showing document restricted alert");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Blocked" message:@"Your company policy blocks opening the document to this application." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* CancelButtonAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:CancelButtonAction];
        [self.sourceViewController presentViewController:alert animated:YES completion:nil];
        self.showRestrictedAlert = NO;
    }
    NSLog(@"Document interaction controller dismissed");
}

@end
