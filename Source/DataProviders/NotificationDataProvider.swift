//
//  NotificationDataProvider.swift
//  Example
//
//  Created by Daniel Nilsson on 27/05/16.
//  Copyright © 2016 apegroup. All rights reserved.
//

import UIKit
import ReactiveCocoa

struct NotificationDataProvider {
    
    func createDeviceTokenSignalProducer(registerForRemoteNotifications register: Bool) -> SignalProducer<String, DataProviderError> {
        var signalProducer = SignalProducer<String, DataProviderError>() { observer, disposable in
            let didRegisterForRemoteNotificationsSignal = self.createDidRegisterForRemoteNotificationsSignal()
            didRegisterForRemoteNotificationsSignal.subscribeNext({ object in
                let deviceTokenData = object as! NSData
                let deviceTokenString = self.deviceTokenDataToString(deviceTokenData)
                observer.sendNext(deviceTokenString)
                observer.sendCompleted()
            })
            
            let didFailToRegisterForRemoteNotificationsSignal = self.createDidFailToRegisterForRemoteNotificationsSignal()
            didFailToRegisterForRemoteNotificationsSignal.subscribeNext({ object in
                let error = object as! NSError
                let dataProviderError = DataProviderError.RemoteNotification(error: error)
                observer.sendFailed(dataProviderError)
            })
        }
        
        if register {
            signalProducer = signalProducer.on(started: {
                UIApplication.sharedApplication().registerForRemoteNotifications()
            })
        }
        
        return signalProducer
    }
 
    private func createDidRegisterForRemoteNotificationsSignal() -> RACSignal {
        let selector = #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let signal = appDelegate.rac_signalForSelector(selector, fromProtocol: UIApplicationDelegate.self).map { object in
            let tuple = object as! RACTuple
            return tuple.second
        }
 
        return signal
    }
 
    private func createDidFailToRegisterForRemoteNotificationsSignal() -> RACSignal {
        let selector = #selector(UIApplicationDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:))
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let signal = appDelegate.rac_signalForSelector(selector, fromProtocol: UIApplicationDelegate.self).map { object in
            let tuple = object as! RACTuple
            return tuple.second
        }
        
        return signal
    }
    
    private func deviceTokenDataToString(deviceTokenData: NSData) -> String {
        let tokenChars = UnsafePointer<CChar>(deviceTokenData.bytes)
        var deviceTokenString = ""
        
        for i in 0..<deviceTokenData.length {
            deviceTokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        return deviceTokenString
    }
}
