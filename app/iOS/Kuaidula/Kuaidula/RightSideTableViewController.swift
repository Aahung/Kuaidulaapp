//
//  SettingViewController.swift
//  Kuaidula
//
//  Created by Xinhong LIU on 17/1/15.
//  Copyright (c) 2015 September. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RightSideTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var containerViewController: ContainerViewController?
    
    @IBOutlet weak var nametextField: UITextField!
    
    @IBOutlet weak var sizeOfDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        
        nametextField.text = User().getUserName()
            
        sizeOfDataLabel.text = "\(self.appDelegate.news.count)条新闻"
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headers = ["", "基本设置", "关于"]
        var label = UILabel()
        label.text = headers[section];
        label.backgroundColor = UIColor.clearColor();
        label.textAlignment = NSTextAlignment.Right
        return label;
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("\(indexPath.section), \(indexPath.item)")
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as MainSubTableViewCell
        println(cell.mainLabel.text)
        let cellText = cell.mainLabel.text
        if cellText == "清除缓存" {
            self.performSegueWithIdentifier("clean", sender: self)
            self.containerViewController?.toggleRightPanel()
        } else if cellText == "速度" {
            println("poping up the speed adjustment menu.")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // hide keyboard if touch anywhere else
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleOnTapAnywhereButKeyboard")
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = self //delegate event notifications to this class
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "clean" {
            let destVC = segue.destinationViewController as CleanCacheViewController
            destVC.centerViewController = self.containerViewController?.centerViewController
        }
    }
    
    func alert(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func handleOnTapAnywhereButKeyboard() -> Bool {
        println("touchesBegan")
        if nametextField.text != "" {
            nametextField.endEditing(true)
            User().saveUserName(nametextField.text)
        }
        return false
    }
    
    @IBAction func usernameDidEndEditing(sender: AnyObject) {
        if nametextField.text != "" {
            nametextField.endEditing(true)
            User().saveUserName(nametextField.text)
        }
    }
}