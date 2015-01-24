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
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "分类"
        }
        return ""
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return appDelegate.categories.keys.array.count - 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("category")
            as MainSubTableViewCell
        if indexPath.section == 1 {
            cell.mainLabel.text = appDelegate.categories[appDelegate.cateShorts[indexPath.item + 1]]
        } else {
            cell.mainLabel.text = appDelegate.categories[appDelegate.cateShorts[0]]
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.containerViewController?.toggleLeftPanel()
        if indexPath.section == 1 {
            let index = indexPath.item + 1 // offset
            appDelegate.categoryIndex = index
        } else if indexPath.section == 0 {
            appDelegate.categoryIndex = 0
        }
        self.appDelegate.updateFilteredNews()
        self.containerViewController?.centerViewController.updateView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var indexPath = NSIndexPath(forRow: 0, inSection: 0)
        if appDelegate.categoryIndex > 0 {
            indexPath = NSIndexPath(forRow: appDelegate.categoryIndex - 1, inSection: 1)
        }
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
    }
    
}