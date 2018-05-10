//
//  AppDelegate.swift
//  QingStorSDKDemo
//
//  Created by Chris on 16/12/29.
//  Copyright © 2016年 Yunify. All rights reserved.
//

import UIKit
import QingStorSDK

var globalService: QingStor!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Using `APIContext` to initialize QingStor service.
        usingAPIContextToInitializeQingStorService()
        
        // Or you can use `Registry` to register QingStor service config.
//        usingRegistryToInitializeQingStorService()
        
        // Or you might want to use customized signer to calculate signature string.
//        usingCustomizedSignerToCalculateSignatureStringAndInitializeQingStorService()
        
        return true
    }
    
    func usingAPIContextToInitializeQingStorService() {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Config", ofType: "plist")!)
        let context = try! APIContext(plist: url)
        globalService = QingStor(context: context)
    }
    
    // Using `Registry` to register QingStor service config.
    func usingRegistryToInitializeQingStorService() {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Config", ofType: "plist")!)
        try! Registry.registerFrom(plist: url)
        globalService = QingStor()
    }
    
    // Use customized signer to calculate signature string.
    func usingCustomizedSignerToCalculateSignatureStringAndInitializeQingStorService() {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Config", ofType: "plist")!)
        let context = try! APIContext(plist: url)
        let singer = CustomizedSigner.init(signatureType: .header) { signer, plainString, builder, completion in
            // Setting http date header of used to calculate the signature.
            builder.addHeaders(["Date":"The date of used to calculate the signature"])
            
            let signatureString = "The signature string of you calculated"
            let accessKey = "The access key of you applied from QingCloud"
            var result: SignatureResult!
            switch signer.signatureType {
            case let .query(timeoutSeconds):
                result = .query(signature: signatureString, accessKey: accessKey, expires: timeoutSeconds)
            case .header:
                result = .header(signature: signatureString, accessKey: accessKey)
            }
            
            completion(result)
        }
        
        globalService = QingStor(context: context, signer: singer)
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
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
