//
//  EndPoints.swift
//  Example
//
//  Created by Daniel Nilsson on 27/05/16.
//  Copyright © 2016 apegroup. All rights reserved.
//

import Foundation

enum EndPoints {
    
    case AuthenticateUser
    case AddDevice(userId: Int)
    
    private struct Path {
        static let users = "/users/"
        static let devices = "/devices/"
    }
    
    var path: String {
        switch self {
        case .AuthenticateUser:
            return Path.users
        case .AddDevice(let userId):
            return "\(Path.users)\(userId)\(Path.devices)"
        }
    }
    
    var baseURL: NSURL {
        return NSURL(string: "http://www.baseurl.com")!
    }
    
    var absoluteURL: NSURL {
        return self.baseURL.URLByAppendingPathComponent(self.path)
    }
}