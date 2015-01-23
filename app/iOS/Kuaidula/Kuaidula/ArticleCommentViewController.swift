//
//  ArticleCommentViewController.swift
//  Kuaidula
//
//  Created by Xinhong LIU on 18/1/15.
//  Copyright (c) 2015 September. All rights reserved.
//

import Foundation
import UIKit
import CoreData



class ArticleCommentViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDataSource {
    
    struct Comment {
        var name: String
        var time: NSNumber
        var content: String
    }
    
    
    var news : NSManagedObject?
    
    var comments = [Comment]()
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        // get comments
        getComments()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "拖一下就刷新")
        self.refreshControl!.addTarget(self, action: "getComments", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        self.tableView.estimatedRowHeight = 68.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        // hide keyboard if touch anywhere else
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleOnTapAnywhereButKeyboard")
        tapRecognizer.delegate = self //delegate event notifications to this class
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillShowNotification)
        NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillHideNotification)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("comment", forIndexPath: indexPath) as ArticleCommentTableCell
        
        cell.nameAndTimeLabel?.text = self.comments[indexPath.row].name as String
        
        cell.contentLabel?.text = self.comments[indexPath.row].content as String
        
        return cell
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo : NSDictionary = notification.userInfo!
        let keyboardInfo : NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as NSValue
        let keyboardHeight = keyboardInfo.CGRectValue().height
        self.setViewMovedUp(true, keyboardHeight: keyboardHeight)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let userInfo : NSDictionary = notification.userInfo!
        let keyboardInfo : NSValue = userInfo.valueForKey(UIKeyboardFrameBeginUserInfoKey) as NSValue
        let keyboardHeight = keyboardInfo.CGRectValue().height
        self.setViewMovedUp(false, keyboardHeight: keyboardHeight)
    }
    
    func setViewMovedUp(movedUp : Bool, keyboardHeight : CGFloat){
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
    
        var rect : CGRect = self.view.frame;
        // reset view
        rect.origin.x = 0
        rect.origin.y = 0
        if movedUp {
            rect = CGRectOffset(rect, 0, -keyboardHeight)
        }
        self.view.frame = rect
    
        UIView.commitAnimations()
    }
    
    func handleOnTapAnywhereButKeyboard() -> Bool {
        println("touchesBegan")
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func submitComment(sender: AnyObject) {
        
        
        // insert comment:
        let id = self.news?.valueForKey("id") as String
        var request = NSMutableURLRequest(URL: NSURL(string: "http://app.kuaidula.com/0.1/article/\(id)/comments")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        let date = NSDate()
        let timestamp = date.timeIntervalSince1970
        let content = textField.text
        var params = ["name":"神经病", "time": "\(timestamp)", "content": content] as Dictionary<String, String>
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // error, refill the content back to textField
                    self.textField.text = content
                })
            }
            
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    var success = parseJSON["success"] as? Int
                    println("Succes: \(success)")
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                // refresh
                
                self.getComments()
            })
            
        })
        
        task.resume()
        
        
        // cancel the firstresponder of textField
        if self.textField.isFirstResponder() {
            self.textField.resignFirstResponder()
        }
        self.textField.text = ""
    }
    
    
    // network, JSON
    func httpGet(request: NSURLRequest!, callback: (NSData, String?) -> Void) {
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request){
            (data, response, error) -> Void in
            if error != nil {
                callback(data, error.localizedDescription)
            } else {
                callback(data, nil)
            }
        }
        task.resume()
    }
    
    func getJSON(urlToRequest: String) -> NSData{
        return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
    }
    
    func parseJSON(inputData: NSData) -> NSDictionary{
        var error: NSError?
        var boardsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        
        return boardsDictionary
    }

    func getComments() {
        let id = self.news?.valueForKey("id") as String
        var request = NSMutableURLRequest(URL: NSURL(string: "http://app.kuaidula.com/0.1/article/\(id)/comments")!)
        
        httpGet(request) {
            (data, error) -> Void in
            
            self.refreshControl!.endRefreshing()
            
            if error != nil {
                println(error)
            } else {
                println("parsing json")
                
                let resObj = self.parseJSON(data)
                let comments = resObj.valueForKey("comments") as NSArray
                
                if comments.count > 0 {
                    self.comments = [Comment]()
                }
                
                for comment in comments {
                    let name = comment.valueForKey("name") as String
                    let time = comment.valueForKey("time") as NSNumber
                    let content = comment.valueForKey("content") as String
                    let aComment = Comment(name: name, time: time, content: content)
                    self.comments.append(aComment)
                }
                
                self.comments.sort {(lhs: Comment, rhs: Comment) -> Bool in
                    return lhs.time.intValue - rhs.time.intValue >= 0
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
        }
        
    }
    
}