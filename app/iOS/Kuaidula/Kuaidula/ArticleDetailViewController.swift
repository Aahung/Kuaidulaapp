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
    
    // 1
    // point to the beginning of the position of the current text
    var pointer = 0
    
    // 2
    // words
    var words = [String]()
    var wordPointer = 0
    
    // 3
    // words and character in word
    // var words
    // var wordPointer
    var characterPointer = 0
    
    // 4
    // better number display
    var queue = [String]()
    // var pointer = 0
    
    // timer
    var timer : NSTimer? = nil
    
    // timer parameters
    let characteInterval = 0.08
    let wordInterval = 0.10
    
    //
    var playOption = 3
    
    
    @IBOutlet weak var newsContent: UITextView!
    @IBOutlet weak var focusText: UILabel!
    @IBOutlet weak var titleText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // swipe on navigationitem downwards to close
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        self.navigationController?.view.addGestureRecognizer(panGestureRecognizer)
        
        println(news)
        self.navigationItem.title = news?.valueForKey("title") as? String
        titleText.text = news?.valueForKey("title") as? String
        content = getParagraphText()
        // newsContent.text = content
    }
    
    override func viewDidAppear(animated: Bool) {
        startTimer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        EndTimer()
    }
    
    
    func startTimer() {
        if playOption == 1 {
            
            timer = NSTimer.scheduledTimerWithTimeInterval(characteInterval, target: self, selector: Selector("updateByCharacterAtConstantSpeed"), userInfo: nil, repeats: true)
        } else if playOption == 2 {
            timer = NSTimer.scheduledTimerWithTimeInterval(characteInterval, target: self, selector: Selector("updateByWordAtConstantSpeed"), userInfo: nil, repeats: true)
        } else if playOption == 3 {
            timer = NSTimer.scheduledTimerWithTimeInterval(characteInterval, target: self, selector: Selector("updateByWordAtSmartSpeed"), userInfo: nil, repeats: false)
        } else if playOption == 4 {
            let paragraphs = news?.valueForKey("paragraphs") as NSArray
            for paragraph in paragraphs {
                let sentences = paragraph.valueForKey("sentences") as NSArray
                for sentence in sentences {
                    let words = sentence.valueForKey("words") as NSArray
                    for word in words {
                        let wordString = "\(word)"
                        let wordAsInt = wordString.toInt()
                        if wordAsInt == nil {
                            // not number
                            for c in wordString {
                                queue.append("\(c)")
                            }
                        } else {
                            queue.append(wordString)
                        }
                        queue.append("")
                    }
                }
            }
            timer = NSTimer.scheduledTimerWithTimeInterval(characteInterval, target: self, selector: Selector("updateByWordAtSmartSpeedWithBetterNumber"), userInfo: nil, repeats: false)
        }
    }
    
    func EndTimer() {
        timer?.invalidate()
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
                    self.words.append("\(word)")
                }
            }
        }
        
        return text
    }
    
    // update three characters and increment pointer
    func updateByCharacterAtConstantSpeed() {
        
        // character by character
        if pointer + 3 < countElements(content) {
            focusText.text = content.substringWithRange(Range<String.Index>(start: advance(content.startIndex, pointer), end: advance(content.startIndex, pointer + 3)))
            pointer++
            
            
        } else {
            timer = nil
        }
    }
    
    func updateByWordAtConstantSpeed() {
        
        // word by word
        
        if self.wordPointer < countElements(self.words) {
            focusText.text = self.words[self.wordPointer]
            self.wordPointer++
        } else {
            timer?.invalidate()
        }
    }
    
    func updateByWordAtSmartSpeed() {
       
        // character by character, slow down inter-word
        if self.wordPointer < countElements(self.words) {
            focusText.text = content.substringWithRange(Range<String.Index>(start: advance(content.startIndex, (pointer >= 2) ? (pointer - 2) : 0), end: advance(content.startIndex, pointer + 3 - 2)))
            pointer++
            // increment characterPointer
            self.characterPointer++
            // increment wordPointer if characterPointer exceed, wait for slow down
            if countElements(self.words[self.wordPointer]) <= self.characterPointer {
                self.wordPointer++
                self.characterPointer = 0
                // words end, timer time slow down
                timer = NSTimer.scheduledTimerWithTimeInterval(wordInterval, target: self, selector: Selector("updateByWordAtSmartSpeed"), userInfo: nil, repeats: false)
            } else {
                timer = NSTimer.scheduledTimerWithTimeInterval(characteInterval, target: self, selector: Selector("updateByWordAtSmartSpeed"), userInfo: nil, repeats: false)
            }
        } else {
            timer?.invalidate()
        }
    }
    
    func updateByWordAtSmartSpeedWithBetterNumber() {
        
        // character by character, slow down inter-word
        if self.pointer < countElements(self.queue) {
            var text = NSMutableAttributedString(
                string: "",
                attributes: NSDictionary(
                    object: UIFont(name: "Heiti SC", size: 96.0)!,
                    forKey: NSFontAttributeName))
            var count = 3
            var i = -1
            while count > 0 {
                if self.pointer + i >= 0 {
                    if self.queue[self.pointer + i] != "" {
                        if self.queue[self.pointer + i].toInt() == nil {
                            let attrString = NSAttributedString(
                                string: self.queue[self.pointer + i],
                                attributes: NSDictionary(
                                    object: UIFont(name: "Heiti SC", size: 96.0)!,
                                    forKey: NSFontAttributeName))
                            text.insertAttributedString(attrString, atIndex: 0)
                        } else {
                            let attrString = NSAttributedString(
                                string: self.queue[self.pointer + i],
                                attributes: NSDictionary(
                                    object: UIFont(name: "Heiti SC", size: 30.0)!,
                                    forKey: NSFontAttributeName))
                            text.insertAttributedString(attrString, atIndex: 0)
                        }
                    }
                    else {
                        count++
                    }
                    i--
                }
                count--
            }
            focusText.attributedText = text
            if self.queue[self.pointer] == "" {
                self.pointer++
                self.pointer++
                timer = NSTimer.scheduledTimerWithTimeInterval(characteInterval, target: self, selector: Selector("updateByWordAtSmartSpeedWithBetterNumber"), userInfo: nil, repeats: false)
            } else {
                self.pointer++
                timer = NSTimer.scheduledTimerWithTimeInterval(wordInterval, target: self, selector: Selector("updateByWordAtSmartSpeedWithBetterNumber"), userInfo: nil, repeats: false)
            }
        } else {
            timer?.invalidate()
        }
    }
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        
        let downDistance = Float(recognizer.translationInView(view).y)
        let threshold : Float = 50.0
        if downDistance < threshold && downDistance > 0.0 && recognizer.state == .Changed {
            // dim the view
            self.view.alpha = CGFloat((threshold - downDistance) / threshold + 0.3)
        }
        if recognizer.state == .Ended {
            if downDistance > threshold {
                self.dismissViewControllerAnimated(true, completion: {})
            } else {
                // back to normal
                self.view.alpha = 1.0
            }
        }
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("segue to \(segue.identifier)")
        if segue.identifier == "original" {
            let navigationC = segue.destinationViewController as UINavigationController
            let destinationVC = navigationC.viewControllers[0] as ArticleOriginalViewController
            destinationVC.news = self.news
        } else if segue.identifier == "comment" {
            let navigationC = segue.destinationViewController as UINavigationController
            let destinationVC = navigationC.viewControllers[0] as ArticleCommentViewController
            destinationVC.news = self.news
        }
    }
}