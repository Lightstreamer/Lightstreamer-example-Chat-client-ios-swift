//
//  AppDelegate.swift
//  SwiftChat
//
// Copyright (c) Lightstreamer Srl
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
        
        // Register for user notifications
        let mySettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(mySettings)
        
        return true
	}
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        let allowedTypes = notificationSettings.types
        
        NSLog("AppDelegate: registration for user notifications succeeded with types: \(allowedTypes)")
        
        // Finally register for remote notifications
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NSLog("AppDelegate: registration for remote notifications succeeded with token: \(deviceToken)")

        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        // Notify the device token to the view controller
        let viewController = self.window?.rootViewController as! ViewController
        viewController.deviceTokenAvailable(token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("AppDelegate: registration for remote notifications failed with error: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NSLog("AppDelegate: remote notification with info: \(userInfo)")
        
        // No need to show the notification: the real-time subscription
        // is updated automatically with the current snapshot
    }

	func applicationWillResignActive(_ application: UIApplication) {
        // Nothign to do here: disconnections and reconnections
        // are handled automatically by the LS Client
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
        // Nothign to do here: disconnections and reconnections
        // are handled automatically by the LS Client
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
        // Nothign to do here: disconnections and reconnections
        // are handled automatically by the LS Client
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
        // Nothign to do here: disconnections and reconnections
        // are handled automatically by the LS Client
	}

	func applicationWillTerminate(_ application: UIApplication) {
        // Nothign to do here: disconnections and reconnections
        // are handled automatically by the LS Client
	}
}

