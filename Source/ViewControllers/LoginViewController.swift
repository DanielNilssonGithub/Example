//
//  LoginViewController.swift
//  Example
//
//  Created by Daniel Nilsson on 27/05/16.
//  Copyright © 2016 apegroup. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        login()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func login() {
        viewModel.authenticateUser().start { event in
            // Show loading view
            switch event {
            case .Completed:
                // Dismiss loading view
                break
            case .Failed(let error):
                print("Something went wrong \(error)")
            case .Next(let isUserValid):
                print("Is user valid? \(isUserValid)")
            default:
                break
            }
        }
    }

}

