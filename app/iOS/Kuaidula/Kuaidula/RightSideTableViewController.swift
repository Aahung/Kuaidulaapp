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
    
    var containerViewController: ContainerViewController?
    
    @IBOutlet weak var nametextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
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
    
    func alert(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func handleOnTapAnywhereButKeyboard() -> Bool {
        println("touchesBegan")
        nametextField.endEditing(true)
        return false
    }
    
}