//
//  DataProviderError.swift
//  Example
//
//  Created by Daniel Nilsson on 27/05/16.
//  Copyright © 2016 apegroup. All rights reserved.
//

import Foundation

enum DataProviderError: ErrorType {
    
    case Network(error: NetworkError)
    case Model(error: ModelError)
    case RemoteNotification(error: NSError)
    case AuthenticateHeaders(error: NSError)
    case MissingToken
    case Unknown
}
