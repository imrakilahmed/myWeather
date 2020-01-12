//
//  AppDelegate.swift
//  the-planner
//
//  Created by Rakil Ahmed on 6/29/19.
//  Copyright © 2019 Rakil Ahmed. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        return true
    }
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let vc = window?.rootViewController as? WeatherVC {
            vc.initializeLocationManager()
        }
    }
}

