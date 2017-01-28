//
//  AppDelegate.swift
//  GeoSearch
//
//  Created by Alex on 1/26/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import CSV


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coreDataStack = CoreDataStack()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(urls[urls.count-1] as URL) // look for doc. directory
        let vc = window?.rootViewController as? MainViewController
        vc?.coreDataStack = coreDataStack

//        importData()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        coreDataStack.saveContext()
    }
    /*
    - 0 : "business_id"
    - 1 : "name"
    - 2 : "address"
    - 3 : "city"
    - 4 : "state"
    - 5 : "postal_code"
    - 6 : "latitude"
    - 7 : "longitude"
    - 8 : "phone_number"
*/

    func importData () {
        let privateContext = CoreDataStack().persistentContainer.newBackgroundContext()
       let path = Bundle.main.path(forResource: "businesses", ofType: "csv")!
        let stream = InputStream(fileAtPath: path)!
        var csv = try! CSV(stream: stream)
        let _ = csv.next() //skip first one

        while let row = csv.next() {
            let restaurant = Restaurant(context: privateContext)

            restaurant.businessId = row[0]
            restaurant.name = row[1]
            restaurant.address = row[2]
            restaurant.city = row[3]
            restaurant.state = row[4]
            restaurant.postalCode = row[5]

            let lat = Double(row[6]) ?? 0
            restaurant.latitude = NSNumber(value: lat)
            let lon = Double(row[7]) ?? 0
            restaurant.longitude = NSNumber(value: lon)
            let hash = Geohash.encode(latitude: lat, longitude: lon, 8)
            print(hash)
            restaurant.geohash = hash

            restaurant.phoneNumber = row[8]
            try! privateContext.save()
        }
    }
 
}

