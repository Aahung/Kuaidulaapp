//
//  LeftSideTableViewController.swift
//  Kuaidula
//
//  Created by Xinhong LIU on 22/1/15.
//  Copyright (c) 2015 September. All rights reserved.
//

import Foundation
import UIKit

class LeftSideTableViewController: UITableViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    var containerViewController: ContainerViewController?

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "分类"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.categories.keys.array.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("category")
            as MainSubTableViewCell
        cell.mainLabel.text = appDelegate.categories[appDelegate.cateShorts[indexPath.item]]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.containerViewController?.toggleLeftPanel()
        if indexPath.section == 0 {
            let index = indexPath.item
            appDelegate.categoryIndex = index
        }
        self.appDelegate.updateFilteredNews()
        self.containerViewController?.centerViewController.updateView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let indexPath = NSIndexPath(forRow: appDelegate.categoryIndex, inSection: 0)
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
    }
    
}