//
//  User.swift
//  Example
//
//  Created by Daniel Nilsson on 27/05/16.
//  Copyright © 2016 apegroup. All rights reserved.
//

import UIKit
import SwiftyJSON

enum Gender: String {
    case Male
    case Female
    case None
    
    init(json: String?) {
        guard let json = json else {
            self = .None
            return
        }
        
        if json == "male" {
            self = .Male
        } else if json == "female" {
            self = .Female
        } else {
            self = .None
        }
    }
    
    var json: String {
        switch self {
        case .Female:
            return "female"
        case .Male:
            return "male"
        case .None:
            return ""
        }
    }
}

struct User {
    var userId: Int
    var providerUserId: Int
    var firstName: String?
    var lastName: String?
    var gender: Gender
    var lastSeenAt: NSDate?
    var updatedAt: NSDate?
    var createdAt: NSDate?
    var birthyear: Int?
    
    init(json: JSON) throws {
        guard let userId = json["userId"].int else {
            throw ModelError.Parse(message: "User have no id")
        }
        self.userId = userId
        
        guard let providerUserId = json["providerUserId"].int else {
            throw ModelError.Parse(message: "User have no providerUserId, userId: \(userId)")
        }
        self.providerUserId = providerUserId
        
        firstName = json["firstname"].string
        lastName = json["lastname"].string
        gender = Gender(json: json["gender"].string)
        lastSeenAt = parseDate(json["lastSeenAt"].string)
        updatedAt = parseDate(json["updatedAt"].string)
        createdAt = parseDate(json["createdAt"].string)
        birthyear = json["birthyear"].int
    }
}

extension User {
    
    func parseDate(dateString: String?) -> NSDate? {
        guard let dateString = dateString else {
            return nil
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
        
        let date = dateFormatter.dateFromString(dateString)
        
        return date
    }
}
