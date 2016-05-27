//
//  Device.swift
//  Example
//
//  Created by Daniel Nilsson on 27/05/16.
//  Copyright © 2016 apegroup. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Device {
    
    var vendorIdentifier: String
    var deviceModel: String
    var pushToken: String
    var deviceName: String
    var createdAt: NSDate
    
    init(json: JSON) {
        vendorIdentifier = json["vendorIdentifier"].stringValue
        deviceModel = json["deviceModel"].stringValue
        pushToken = json["pushToken"].stringValue
        deviceName = json["deviceName"].stringValue
        
        if let createdAtString = json["createdAt"].string {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
            createdAt = dateFormatter.dateFromString(createdAtString)!
        } else {
            fatalError("User have no created date")
        }
    }
    
    init(deviceToken: String) {
        vendorIdentifier = UIDevice.currentDevice().identifierForVendor!.UUIDString
        deviceModel = UIDevice.currentDevice().model
        pushToken = deviceToken
        deviceName = UIDevice.currentDevice().name
        createdAt = NSDate()
    }
    
    func toJsonData() -> NSData? {
        let json = toJson()
        
        if let data = try? json.rawData() { return data }
        return nil
    }
    
    func toJsonString() -> String? {
        let json = toJson()
        
        return json.rawString()
    }
    
    private func toJson() -> JSON {
        let json: JSON = ["vendorIdentifier": vendorIdentifier,
                          "deviceModel": deviceModel,
                          "pushToken": pushToken,
                          "deviceName": deviceName]
        
        return json
    }
}
