//
//  AppDelegate.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2013/12/17.
//  Copyright (c) 2013 MIYAMOTO Shohei. All rights reserved.
//

#import "AppDelegate.h"

#import <Crashlytics/Crashlytics.h>

#import "DocumentListViewController.h"
#import "Folder.h"
#import "FolderDocumentListViewModel.h"
#import "FolderTableDataSource.h"
#import "FolderTableViewController.h"
#import "FolderTableViewController.h"
#import "HomeViewController.h"
#import "LibraryUtils.h"
#import "NSFileManager+GreatReaderAdditions.h"
#import "PDFDocumentViewController.h"
#import "PDFRecentDocumentList.h"
#import "PDFRecentDocumentListViewController.h"
#import "RecentDocumentListViewModel.h"
#import "RootFolderTableDataSource.h"

NSString * const RestorationDocumentListTabBar = @"RestorationDocumentListTabBar";
NSString * const RestorationDocumentListRecentNavi = @"RestorationDocumentListRecentNavi";
NSString * const RestorationDocumentListRecent = @"RestorationDocumentListRecent";
NSString * const RestorationDocumentListFolderNavi = @"RestorationDocumentListFolderNavi";
NSString * const RestorationDocumentListFolder = @"RestorationDocumentListFolder";
NSString * const RestorationPDFDocument = @"RestorationPDFDocument";
NSString * const StoryboardPDFDocument = @"StoryboardPDFDocument";


@interface AppDelegate () <UITabBarControllerDelegate>
@property (nonatomic, strong) PDFRecentDocumentList *documentList;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (CrashlyticsEnabled()) {
        [Crashlytics startWithAPIKey:GetCrashlyticsAPIKey()];
    }

    self.documentList = [PDFRecentDocumentList new];
    
    UITabBarController *tabBar = (UITabBarController *)[[self window] rootViewController];
    tabBar.delegate = self;

    DocumentListViewController *folder = (DocumentListViewController *)[tabBar.viewControllers[0] topViewController];
    FolderDocumentListViewModel *folderModel =
            [[FolderDocumentListViewModel alloc] initWithDocumentList:self.documentList];
    folderModel.folder = [Folder rootFolder];
    folder.viewModel = folderModel;
    [folder view];
    
    DocumentListViewController *recent = (DocumentListViewController *)[tabBar.viewControllers[1] topViewController];
    RecentDocumentListViewModel *recentModel =
            [[RecentDocumentListViewModel alloc] initWithDocumentList:self.documentList];
    recent.viewModel = recentModel;

    tabBar.title = folder.title;
    
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (UIViewController *)application:(UIApplication *)application
viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                            coder:(NSCoder *)coder
{
    NSString *identifier = [identifierComponents lastObject];
    if ([identifier isEqual:RestorationPDFDocument]) {
        UIStoryboard *storyboard = [self.window.rootViewController storyboard];
        PDFDocumentViewController *vc =
                [storyboard instantiateViewControllerWithIdentifier:StoryboardPDFDocument];
        vc.hidesBottomBarWhenPushed = YES;
        vc.document = [self.documentList open:[self.documentList.documents firstObject]];
        vc.documentList = self.documentList;
        return vc;
    } else {
        return nil;
    }
}
						
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *fileName = [url lastPathComponent];
    NSURL *dirURL = [[url URLByDeletingLastPathComponent] URLByDeletingLastPathComponent];
    NSURL *destURL = [dirURL URLByAppendingPathComponent:fileName];

    NSFileManager *fm = [NSFileManager new];
    NSURL *uniqueDestURL = [fm grt_incrementURLIfNecessary:destURL];
    NSError *error = nil;
    if ([fm moveItemAtURL:url
                    toURL:uniqueDestURL
                    error:&error]) {
        
        [self openURL:uniqueDestURL];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Open Document in GreatReader

- (void)openURL:(NSURL *)URL
{
    UINavigationController *root = (UINavigationController *)[[self window] rootViewController];
    UIViewController *top = [root topViewController];
    void (^reloadRootFolder)(void) = ^{
        HomeViewController *vc = (HomeViewController *)[root topViewController];
        FolderTableViewController *folderViewController = vc.folderViewController;
        FolderTableDataSource *dataSource = [[FolderTableDataSource alloc] 
                                                initWithFolder:[Folder rootFolder]];
        folderViewController.dataSource = dataSource;
        [folderViewController.tableView reloadData];
        [folderViewController performSelector:@selector(openDocumentsAtURL:)
                                   withObject:URL
                                   afterDelay:0.5];
    };

    if (top.presentedViewController) {
        [top dismissViewControllerAnimated:NO
                                completion:^{
            [root popToRootViewControllerAnimated:NO];
            reloadRootFolder();
        }];
    } else {
        [root popToRootViewControllerAnimated:NO];
        reloadRootFolder();
    }
}

#pragma mark -

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    tabBarController.title = viewController.title;
}

@end
