//
//  LoginViewModel.swift
//  Example
//
//  Created by Daniel Nilsson on 27/05/16.
//  Copyright © 2016 apegroup. All rights reserved.
//

import ReactiveCocoa

class LoginViewModel {
    
    func authenticateUser() -> SignalProducer<Bool, DataProviderError> {
        // Auth header
        let authHeaders = [NSObject : AnyObject]()
        
        return UserDataProvider().authenticateUser(authHeaders)
            // Save user for later use and transform the signal producer to create a tuple
            .map { user -> (isValidUser: Bool, userId: Int) in
                return (self.isValidUser(user), user.userId)
            }
            // Transform to a signal producer that fetches device token and then fill the tuple
            .flatMap(.Latest) { (isValidUser, userId) -> SignalProducer<(isValidUser: Bool, userId: Int, deviceToken: String), DataProviderError> in
                return  NotificationDataProvider().createDeviceTokenSignalProducer(registerForRemoteNotifications: true)
                    .map { deviceToken -> (isValidUser: Bool, userId: Int, deviceToken: String) in
                        return (isValidUser, userId, deviceToken)
                }
            }
            // Transform to a signal producer that add device and then returns if user is valid or not
            .flatMap(.Latest) { (isValidUser, userId, deviceToken) -> SignalProducer<Bool, DataProviderError> in
                return DeviceDataProvider().addDevice(userId, deviceToken: deviceToken).map {
                    return isValidUser
                }
        }.observeOn(UIScheduler())
    }
    
    func isValidUser(user: User) -> Bool {
        let validFirstName = isValidFirstName(user.firstName)
        let validLastName = isValidLastName(user.lastName)
        
        return validFirstName && validLastName
    }
    
    private func isValidFirstName(firstName: String?) -> Bool {
        guard let firstName = firstName else {
            return false
        }
        
        let ignoreWhitespace = firstName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return ignoreWhitespace.characters.count > 0
    }
    
    private func isValidLastName(lastName: String?) -> Bool {
        guard let lastName = lastName else {
            return false
        }
        
        let ignoreWhitespace = lastName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return ignoreWhitespace.characters.count > 0
    }
}