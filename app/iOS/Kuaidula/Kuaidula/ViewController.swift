//
//  ViewController.swift
//  Kuaidula
//
//  Created by Xinhong LIU on 4/1/15.
//  Copyright (c) 2015 September. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

@objc
protocol CenterViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func toggleRightPanel()
    optional func collapseSidePanels()
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // tableView
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    
    @IBOutlet weak var barMenuButton: UIBarButtonItem!
    
    var containerViewController: ContainerViewController?
    
    @IBOutlet weak var noNewsImage: UIImageView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    var refreshControl: UIRefreshControl?
    
    var delegate: CenterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "拖一下就刷新")
        self.refreshControl!.addTarget(self, action: "updateNews", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)

        self.tableView.tableFooterView = UIView()
        
        self.noNewsImage.hidden = true
        
        self.appDelegate.syncFromCoreDate()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if appDelegate.filteredNews.count == 0 {
            // no news
            self.noNewsImage.hidden = false
        } else {
            self.noNewsImage.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let indexPath = self.tableView.indexPathForSelectedRow
        if indexPath() != nil {
            self.tableView.deselectRowAtIndexPath(indexPath()!, animated: true)
        }
        
        self.updateView()
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    @IBAction func leftMenuToggleAction(sender: AnyObject) {
        delegate?.toggleLeftPanel!()
    }
    
    @IBAction func settingsMenuAction(sender: AnyObject) {
        delegate?.toggleRightPanel!()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("segue to \(segue.identifier)")
        if segue.identifier == "detail" {
            let navigationC = segue.destinationViewController as UINavigationController
            let destinationVC = navigationC.viewControllers[0] as ArticleDetailViewController
            let indexPath = sender as NSIndexPath?
            let selectedNews = appDelegate.filteredNews[indexPath?.item as Int!]
            selectedNews.setValue(true, forKey: "read")
            let managedContext = appDelegate.managedObjectContext!
            var error: NSError?
            // Save the object to persistent store
            managedContext.save(&error)
            destinationVC.news = selectedNews
        }
    }
    
    func updateView() {
        self.tableView.reloadData()
        self.navigationItem.title = appDelegate.categories[appDelegate.cateShorts[appDelegate.categoryIndex]]
        if appDelegate.filteredNews.count == 0 {
            // no news
            self.noNewsImage.hidden = false
        } else {
            self.noNewsImage.hidden = true
        }
    }
    
    // UITableViewDataSource prototype methods
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            // return atmost 50
            
            if appDelegate.filteredNews.count > 50 {
                return 50
            }
            return appDelegate.filteredNews.count
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("NewsCell")
                as ArticleTableCell
            
            let news = appDelegate.filteredNews[indexPath.row]
            cell.contentLabel?.text = news.valueForKey("title") as String?
            cell.contentLabel?.numberOfLines = 0
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
            let dateObj: AnyObject? = news.valueForKey("time")
            if dateObj != nil {
                let date = dateObj as NSDate
                cell.timeAndSourceLabel?.text = dateFormatter.stringFromDate(date)
            }
            
            var category = news.valueForKey("category") as String
            if contains(appDelegate.cateShorts, category) {
                category = appDelegate.categories[category]!
            }
            cell.categoryLabel.text = category
            
            let read = news.valueForKey("read") as Bool?
            
            if read != nil && read! {
                cell.contentView.alpha = 0.3
            } else {
                cell.contentView.alpha = 1.0
            }
            
            // shadow
            
//            cell.backgroundPanel.layer.shadowColor = UIColor.blackColor().CGColor
//            cell.backgroundPanel.layer.shadowOpacity = 0.2;
//            cell.backgroundPanel.layer.shadowRadius = 1.5;
//            cell.backgroundPanel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
            
            //let selectionBackgroundView = UIView(frame: cell.frame)
            //selectionBackgroundView.backgroundColor = UIColor.whiteColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.Gray
            
            return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // if not side menu, then segue
        if self.containerViewController!.isBothCollapsed() {
            self.performSegueWithIdentifier("detail", sender: indexPath)
        } else {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let news = appDelegate.filteredNews[indexPath.row]
        let content = news.valueForKey("title") as String?
        
        let font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        let attributedString = NSAttributedString(string: content!, attributes: [NSFontAttributeName: font])
        let rect = attributedString.boundingRectWithSize(CGSize(width: UIScreen.mainScreen().bounds.width - 10, height: 1000.0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        let size = rect.size
        // println("width: \(UIScreen.mainScreen().bounds.width), height: \(size.height)")
        return size.height + 51.0
    }
    
    
    
    func updateNews() {
        
        self.navigationItem.title = "努力下载中。。。"
        self.refreshControl!.beginRefreshing()
        
        self.appDelegate.syncFromCoreDate()
        var startId = "0"
        let endId = "0"
        if self.appDelegate.news.count > 0 {
            startId = self.appDelegate.getLargestNewsId()
        }
        
        Alamofire.request(.GET, "https://app.kuaidula.com/0.2/articles/uncensored/\(startId)/\(endId)/")
            .responseJSON { (request, response, JSON, error) in
                if error != nil {
                    println(error)
                } else {
                    
                    let articles = JSON!.valueForKey("articles") as NSArray
                    
                    // core data
                    let managedContext = self.appDelegate.managedObjectContext!
                    let entity =  NSEntityDescription.entityForName("Article", inManagedObjectContext: managedContext)
                    
                    for article in articles {
                        let id = article.valueForKey("_id") as String
                        let title = article.valueForKey("title") as String
                        let category = article.valueForKey("category") as String?
                        let url = article.valueForKey("url") as String
                        let timestamp = article.valueForKey("time") as NSNumber
                        let time = NSDate(timeIntervalSince1970: Double(timestamp))
                        let paragraphs = article.valueForKey("paragraphs") as NSArray
                        let keywords = article.valueForKey("keywords") as NSArray
                        let v = (article.valueForKey("__v") as NSNumber).integerValue
                        
                        // check if id exist, if, then modify, else insert
                        var exists = false
                        for existingNews in self.appDelegate.news {
                            let existingId = existingNews.valueForKey("id") as String
                            if existingId == id {
                                exists = true
                                break
                            }
                        }
                        
                        if !exists {
                            let aNews = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
                            aNews.setValue(id, forKey: "id")
                            aNews.setValue(title, forKey: "title")
                            if category != nil {
                                aNews.setValue(category, forKey: "category")
                            } else {
                                aNews.setValue("", forKey: "category")
                            }
                            aNews.setValue(url, forKey: "url")
                            aNews.setValue(time, forKey: "time")
                            aNews.setValue(paragraphs, forKey: "paragraphs")
                            aNews.setValue(keywords, forKey: "keywords")
                            aNews.setValue(v, forKey: "v")
                            var error: NSError?
                            if !managedContext.save(&error) {
                                println("Could not save \(error), \(error?.userInfo)")
                            }
                            self.appDelegate.news.append(aNews)
                        }
                        
                    }
                    
                    self.appDelegate.updateFilteredNews()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.updateView()
                        self.refreshControl!.endRefreshing()
                    })
                }
        }
        
    }
}

class CleanCacheViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    var centerViewController: ViewController?
    
    func cleanCache() {
        
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue, {
            
            let managedContext = self.appDelegate.managedObjectContext!
            let fetchRequest = NSFetchRequest(entityName:"Article")
            var error: NSError?
            
            let fetchedResults =
            managedContext.executeFetchRequest(fetchRequest,
                error: &error) as [NSManagedObject]?
            if let results = fetchedResults {
                for news in results {
                    managedContext.deleteObject(news)
                }
                managedContext.save(nil)
                self.appDelegate.news = [NSManagedObject]()
                self.appDelegate.updateFilteredNews()
                self.closeAction()
            } else {
                println("Could not fetch \(error), \(error!.userInfo)")
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        cleanCache()
    }
    
    func closeAction() {
        self.dismissViewControllerAnimated(true, completion: {})
    }
}
