//
//  User.swift
//  Kuaidula
//
//  Created by Xinhong LIU on 23/1/15.
//  Copyright (c) 2015 September. All rights reserved.
//

import Foundation

class User {
    
    func getUserName() -> String {
        // load saved userinfo
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.synchronize()
        if let username = userDefaults.objectForKey("username") as? String {
            return username
        } else {
            let randomName = "匿名用户\(random() % 1000000)"
            saveUserName(randomName)
            return randomName
        }
    }
    
    func saveUserName(username: String) {
        NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
    }
    
}