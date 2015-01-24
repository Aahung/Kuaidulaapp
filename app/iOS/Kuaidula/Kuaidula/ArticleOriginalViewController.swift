//
//  ArticleOriginalViewController.swift
//  Kuaidula
//
//  Created by Xinhong LIU on 17/1/15.
//  Copyright (c) 2015 September. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ArticleOriginalViewController : UIViewController {
    var news : NSManagedObject?
    
    @IBOutlet weak var articleOriginalText: UITextView!
    
    override func viewDidLoad() {
        self.navigationItem.title = news?.valueForKey("title") as? String
        articleOriginalText.text = getParagraphText()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.articleOriginalText.setContentOffset(CGPoint(x: 0, y: -60), animated: true)
    }
    
    func getParagraphText() -> String {
        var text : String = ""
        
        let paragraphs = news?.valueForKey("paragraphs") as NSArray
        for paragraph in paragraphs {
            let sentences = paragraph.valueForKey("sentences") as NSArray
            for sentence in sentences {
                let words = sentence.valueForKey("words") as NSArray
                for word in words {
                    text = "\(text)\(word)"
                }
            }
            text = "\(text)\n"
        }
        
        return text
    }
    
    
    
    @IBAction func openInSafari(sender: AnyObject) {
        
        let url : NSURL = NSURL(string: news?.valueForKey("url") as String)!
        
        UIApplication.sharedApplication().openURL(url)
        
    }
}