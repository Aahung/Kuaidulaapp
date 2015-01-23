//
//  NewsConnect.swift
//  Kuaidula
//
//  Created by Xinhong LIU on 21/1/15.
//  Copyright (c) 2015 September. All rights reserved.
//

import Foundation
import CoreData
import Alamofire

class NewsConnect {
    struct News {
        var id: String
        var title: String
        var url: String
        var time: NSDate
        var paragraphs: [[[String]]]
        var keywords: [String]
        var imgs: [String]
        var v: Int
    }
    
    var news = [News]()
    var appDelegate: AppDelegate
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        self.syncFromCoreData()
    }
    
    func updateNews() {
        Alamofire.request(.GET, "http://app.kuaidula.com/0.1/articles/uncensored")
            .responseJSON { (request, response, JSON, error) in
                if error != nil {
                    println(error)
                } else {
                    
                    self.news = [News]()
                    
                    let articles = JSON!.valueForKey("articles") as NSArray
                    // core data
                    let managedContext = self.appDelegate.managedObjectContext!
                    let entity =  NSEntityDescription.entityForName("Article", inManagedObjectContext: managedContext)
                    
                    for article in articles {
                        let id = article.valueForKey("_id") as String
                        let title = article.valueForKey("title") as String
                        let url = article.valueForKey("url") as String
                        let timestamp = article.valueForKey("time") as NSNumber
                        let time = NSDate(timeIntervalSince1970: Double(timestamp))
                        var paragraphs = [[[String]]]()
                        let paragraphObjs = article.valueForKey("paragraphs") as NSArray
                        for paragraphObj in paragraphObjs {
                            var sentences = [[String]]()
                            let sentenceObjs = paragraphObj.valueForKey("sentences") as NSArray
                            for sentenceObj in sentenceObjs {
                                var words = [String]()
                                let wordObjs = sentenceObj.valueForKey("words") as NSArray
                                for wordObj in wordObjs {
                                    words.append(wordObj as String)
                                }
                                sentences.append(words)
                            }
                            paragraphs.append(sentences)
                        }
                        let keywords = article.valueForKey("keywords") as [String]
                        let imgs = article.valueForKey("imgs") as [String]
                        let v = (article.valueForKey("__v") as NSNumber).integerValue
                        let aNew = News(id: id, title: title, url: url, time: time, paragraphs: paragraphs, keywords: keywords, imgs: imgs, v: v)
                        self.news.append(aNew)
                    }
                }
        }
    }
    
    func getNews() -> [News] {
        self.news.sort( {(lhs: News, rhs: News) -> Bool in
            // you can have additional code here
            return  lhs.id < rhs.id
        })
        return self.news
    }
    
    func managedObj2News(obj: NSManagedObject) -> News {
        let id = obj.valueForKey("id") as String
        let title = obj.valueForKey("title") as String
        let url = obj.valueForKey("url") as String
        let time = obj.valueForKey("time") as NSDate
        let paragraphs = obj.valueForKey("paragraphs") as [[[String]]]
        let keywords = obj.valueForKey("keywords") as [String]
        let imgs = obj.valueForKey("imgs") as [String]
        let v = (obj.valueForKey("v") as NSNumber).integerValue
        return News(id: id, title: title, url: url, time: time, paragraphs: paragraphs, keywords: keywords, imgs: imgs, v: v)
    }
    
    func news2ManagedObj(news: News) -> NSManagedObject {
        let aNews = NSManagedObject()
        aNews.setValue(news.id, forKey: "id")
        aNews.setValue(news.time, forKey: "title")
        aNews.setValue(news.url, forKey: "url")
        aNews.setValue(news.time, forKey: "time")
        aNews.setValue(news.paragraphs, forKey: "paragraphs")
        aNews.setValue(news.keywords, forKey: "keywords")
        aNews.setValue(news.imgs, forKey: "imgs")
        aNews.setValue(news.v, forKey: "v")
        return aNews
    }
    
    func syncFromCoreData() {
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"Article")
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        if let results = fetchedResults {
            self.news = [News]()
            for result in results {
                news.append(self.managedObj2News(result))
            }
            self.news.sort({(lhs: News, rhs: News) -> Bool in
                return lhs.id < rhs.id
            })
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    func syncToCoreData() {
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"Article")
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        if let results = fetchedResults {
            var news = [News]()
            for result in results {
                news.append(self.managedObj2News(result))
            }
            // insert
            for aNews in news {
                if self.news.filter({$0.id == aNews.id && $0.v == aNews.v}).count == 0 {
                    // insert
                    managedContext.insertObject(news2ManagedObj(aNews))
                }
                managedContext.save(&error)
                if error != nil {
                    println(error)
                }
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
}