//
//  AppDelegate.h
//  TripPlanner
//
//  Created by Abel Castro on 16/4/15.
//  Copyright (c) 2015 TAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "WebServiceConnectionsController.h"
#import "CoreDataController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) WebServiceConnectionsController *webServiceController;
@property (readonly, strong, nonatomic) CoreDataController *coreDataController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

