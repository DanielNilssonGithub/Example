//
//  UserDataProvider.swift
//  Example
//
//  Created by Daniel Nilsson on 27/05/16.
//  Copyright © 2016 apegroup. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SwiftyJSON

struct UserDataProvider {
    
    func authenticateUser(authHeaders: [NSObject : AnyObject]) -> SignalProducer<User, DataProviderError> {
        return SignalProducer<User, DataProviderError>() { observer, disposable in
            let route = EndPoints.AuthenticateUser
            
            let json = JSON(authHeaders)
            var jsonData: NSData
            do {
                jsonData = try json.rawData()
            } catch let error as NSError {
                let dataProviderError = DataProviderError.AuthenticateHeaders(error: error)
                observer.sendFailed(dataProviderError)
                return
            }
            
            let network = Network.POST(url: route, body: jsonData)
            let task = network.send { networkResponse in
                switch networkResponse {
                case .Success(let data):
                    let json = JSON(data: data!)
                    
                    guard let token = json["token"].string else {
                        let dataProviderError = DataProviderError.MissingToken
                        observer.sendFailed(dataProviderError)
                        return
                    }
                    
                    // Save token to key chain
                    
                    let userJson = json["user"]
                    var user: User
                    do {
                         user = try User(json: userJson)
                    } catch ModelError.Parse(let message) {
                        let dataProviderError = DataProviderError.Model(error: ModelError.Parse(message: message))
                        observer.sendFailed(dataProviderError)
                        return
                    } catch {
                        let dataProviderError = DataProviderError.Unknown
                        observer.sendFailed(dataProviderError)
                        return
                    }
                    
                    // Save user id to user defaults
                    
                    observer.sendNext(user)
                    observer.sendCompleted()
                case .Error(let networkError):
                    let dataProviderError = DataProviderError.Network(error: networkError)
                    observer.sendFailed(dataProviderError)
                }
            }
            
            disposable.addDisposable({
                task.cancel()
            })
        }
    }
}
