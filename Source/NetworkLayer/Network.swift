//
//  Network.swift
//  Example
//
//  Created by Daniel Nilsson on 27/05/16.
//  Copyright © 2016 apegroup. All rights reserved.
//

import UIKit

protocol NetworkProtocol {
    
    func send(completionHandler: NetworkResponse -> Void) -> NSURLSessionDataTask
}

enum NetworkResponse {
    
    case Success(data: NSData?)
    case Error(error: NetworkError)
}

enum NetworkError {
    
    case Local(error: NSError)
    case Server(response: NSHTTPURLResponse)
    case Client(response: NSHTTPURLResponse)
    case Unknown(response: NSHTTPURLResponse)
}

enum Network: NetworkProtocol {
    
    case GET(url: EndPoints)
    case POST(url: EndPoints, body: NSData?)
    case DELETE(url: EndPoints)
    
    func send(completionHandler: NetworkResponse -> Void) -> NSURLSessionDataTask {
        var request: NSMutableURLRequest

        switch self {
        case .GET(let url):
            request = NSMutableURLRequest(URL: url.absoluteURL)
            request.HTTPMethod = "GET"
            request.allHTTPHeaderFields = httpHeaders()
        case .POST(let url, let body):
            request = NSMutableURLRequest(URL: url.absoluteURL)
            request.HTTPMethod = "POST"
            request.allHTTPHeaderFields = httpHeaders()
            request.HTTPBody = body
        case .DELETE(let url):
            request = NSMutableURLRequest(URL: url.absoluteURL)
            request.HTTPMethod = "DELETE"
            request.allHTTPHeaderFields = httpHeaders()
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            if let error = error {
                let error = NetworkError.Local(error: error)
                let errorNetworkResponse = NetworkResponse.Error(error: error)
                completionHandler(errorNetworkResponse)
            } else {
                let httpResponse = response as! NSHTTPURLResponse
                switch httpResponse.statusCode {
                case 200...226:
                    let successNetworkResponse = NetworkResponse.Success(data: data)
                    completionHandler(successNetworkResponse)
                case 400...451:
                    let error = NetworkError.Client(response: httpResponse)
                    let errorNetworkResponse = NetworkResponse.Error(error: error)
                    completionHandler(errorNetworkResponse)
                case 500...511:
                    let error = NetworkError.Server(response: httpResponse)
                    let errorNetworkResponse = NetworkResponse.Error(error: error)
                    completionHandler(errorNetworkResponse)
                default:
                    let error = NetworkError.Unknown(response: httpResponse)
                    let errorNetworkResponse = NetworkResponse.Error(error: error)
                    completionHandler(errorNetworkResponse)
                }
            }
        }
        
        task.resume()
        
        return task
    }
    
    private func httpHeaders() -> [String : String] {
        var headers = [String : String]()
        headers["Content-Type"] = "application/json"
        headers["Accept-Language"] = NSLocale.preferredLanguages()[0]
        headers["Authorization"] = "Bearer <TOKEN>"
        
        return headers
    }
}


extension NSMutableData {

    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}
