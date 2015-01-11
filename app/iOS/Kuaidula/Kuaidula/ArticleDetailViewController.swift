//
//  ArticleDetailViewController.swift
//  Kuaidula
//
//  Created by Xinhong LIU on 11/1/15.
//  Copyright (c) 2015 September. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ArticleDetailViewController : UIViewController {
    var news : NSManagedObject?
    
    // paragraph
    var content = ""
    
    // point to the beginning of the position of the current text
    var pointer = 0
    
    // timer
    var timer : NSTimer? = nil
    
    @IBOutlet weak var newsContent: UITextView!
    @IBOutlet weak var focusText: UILabel!
    
    override func viewDidLoad() {
        println(news)
        self.navigationItem.title = news?.valueForKey("title") as? String
        content = getParagraphText()
        newsContent.text = content
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
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
        }
        
        return text
    }
    
    // update three characters and increment pointer
    func update() {
        if pointer + 3 < countElements(content) {
            focusText.text = content.substringWithRange(Range<String.Index>(start: advance(content.startIndex, pointer), end: advance(content.startIndex, pointer + 3)))
            pointer++
        } else {
            timer = nil
        }
    }
}