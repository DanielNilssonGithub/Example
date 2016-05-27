//
//  DeviceDataProvider.swift
//  Example
//
//  Created by Daniel Nilsson on 27/05/16.
//  Copyright © 2016 apegroup. All rights reserved.
//

import ReactiveCocoa

struct DeviceDataProvider {
    
    func addDevice(userId: Int, deviceToken: String) -> SignalProducer<Void, DataProviderError> {
        return SignalProducer<Void, DataProviderError>() { observer, disposable in
            let route = EndPoints.AddDevice(userId: userId)
            let device = Device(deviceToken: deviceToken)
            let body = device.toJsonData()
            
            let network = Network.POST(url: route, body: body)
            let task = network.send({ networkResponse in
                switch networkResponse {
                case .Success:
                    observer.sendNext()
                    observer.sendCompleted()
                case .Error(let networkError):
                    let dataProviderError = DataProviderError.Network(error: networkError)
                    observer.sendFailed(dataProviderError)
                }
            })
            
            disposable.addDisposable({ 
                task.cancel()
            })
        }
    }
}