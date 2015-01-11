//
//  ViewController.swift
//  Kuaidula
//
//  Created by Xinhong LIU on 4/1/15.
//  Copyright (c) 2015 September. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // tableView
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    
    // news
    var news = [NSManagedObject]()
    
    override func viewWillAppear(animated: Bool) {
        
        
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"Article")
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        if let results = fetchedResults {
            news = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        updateNews()
        
        let indexPath = self.tableView.indexPathForSelectedRow
        self.tableView.reloadData()
        if indexPath() != nil {
            self.tableView.selectRowAtIndexPath(indexPath(), animated: false, scrollPosition: UITableViewScrollPosition.None)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let indexPath = self.tableView.indexPathForSelectedRow
        self.tableView.reloadData()
        if indexPath() != nil {
            self.tableView.deselectRowAtIndexPath(indexPath()!, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("segue to \(segue.identifier)")
        if segue.identifier == "detail" {
            let navigationC = segue.destinationViewController as UINavigationController
            let destinationVC = navigationC.viewControllers[0] as ArticleDetailViewController
            let indexPath = self.tableView.indexPathForCell(sender as UITableViewCell)
            destinationVC.news = self.news[indexPath?.item as Int!]
        }
    }
    
    // UITableViewDataSource prototype methods
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("NewsCell")
                as UITableViewCell
            
            cell.textLabel!.text = news[indexPath.row].valueForKey("title") as String?
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
            cell.detailTextLabel?.text = dateFormatter.stringFromDate(news[indexPath.row].valueForKey("time") as NSDate)
            
            return cell
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
    
    func updateNews() {
        
        navigationItem.title = "努力抓取新闻..."
        
        let articleUrl = "http://app.kuaidula.com/0.1/articles/all"
        var request = NSMutableURLRequest(URL: NSURL(string: articleUrl)!)
        
        
        
        httpGet(request) {
            (data, error) -> Void in
            if error != nil {
                println(error)
            } else {
                println("parsing json")
                
                let resObj = self.parseJSON(data)
                let articles = resObj.valueForKey("articles") as NSArray
                
                // core data
                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                let managedContext = appDelegate.managedObjectContext!
                let entity =  NSEntityDescription.entityForName("Article", inManagedObjectContext: managedContext)
                
                for article in articles {
                    let id = article.valueForKey("_id") as String
                    let title = article.valueForKey("title") as String
                    let timestamp = article.valueForKey("time") as NSNumber
                    let time = NSDate(timeIntervalSince1970: Double(timestamp))
                    let paragraphs = article.valueForKey("paragraphs") as NSArray
                    
                    // check if id exist, if, then modify, else insert
                    var exists = false
                    for existingNews in self.news {
                        let existingId = existingNews.valueForKey("id") as String
                        if existingId == id {
                            exists = true
                            break
                        }
                    }
                    if exists {
                        
                    } else {
                        let aNews = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
                        aNews.setValue(id, forKey: "id")
                        aNews.setValue(title, forKey: "title")
                        aNews.setValue(time, forKey: "time")
                        aNews.setValue(paragraphs, forKey: "paragraphs")
                        var error: NSError?
                        if !managedContext.save(&error) {
                            println("Could not save \(error), \(error?.userInfo)")
                        }
                        self.news.append(aNews)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                        self.navigationItem.title = "快读啦"
                    })
                }
            }
        }
        
    }
    
}

