//
//  AppDelegate.swift
//  Final_Finalproject
//
//  Created by dong eun shin on 2020/11/01.
//  Copyright © 2020 dong eun shin. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        sleep(3)
        DataManager.shared.setup(modelName: "Final_Finalproject")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [UNAuthorizationOptions.badge, .sound, .alert]) { (granted, error) in
            if granted {
                UNUserNotificationCenter.current().delegate = self
            }
            print("granted \(granted)")
        }
        return true
    }
//    func applicationWillResignActive(_ application: UIApplication) {
//
//        UIApplication.shared.applicationIconBadgeNumber = 0
//    }
//    
//    func applicationWillEnterForeground(_ application: UIApplication) {
//
//        UserDefaults(suiteName: "group.com.Final_Finalproject.bundleId")?.set(1, forKey: "count")
//        UIApplication.shared.applicationIconBadgeNumber = 0
//
//    }
}
extension AppDelegate: UNUserNotificationCenterDelegate{
        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            let content = notification.request.content
            let trigger = notification.request.trigger
            
            completionHandler([UNNotificationPresentationOptions.alert])
        }

           func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
               let content = response.notification.request.content
               let trigger = response.notification.request.trigger
               
                completionHandler()
           }
           
           
    }
    // MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }


//}

