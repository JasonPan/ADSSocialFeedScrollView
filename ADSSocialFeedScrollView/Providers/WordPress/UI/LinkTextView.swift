//
//  LinkTextView.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 12/03/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit

//extension UITextView {
//    //If Editable = NO
//    //Prevent text selection through double tapping
//    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
//        
//        if self.editable == false {
//            if gestureRecognizer.isKindOfClass(UITapGestureRecognizer.self) && (gestureRecognizer as! UITapGestureRecognizer).numberOfTapsRequired == 2 {
//                if gestureRecognizer.isMemberOfClass(UITapGestureRecognizer.self) {
//                    return true
//                }
//                else {
//                    return false
//                }
//            }
//        }
//        return super.gestureRecognizerShouldBegin(gestureRecognizer)
//    }
//}

class LinkTextView: UITextView {
    
    
    //Fix for UITextView text selection issue (with support for links)
    //See: http://stackoverflow.com/a/24929450/699963
    override func canPerformAction(action: Selector, withSender sender: AnyObject!) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer.isKindOfClass(UITapGestureRecognizer) && ((gestureRecognizer as! UITapGestureRecognizer).numberOfTapsRequired == 1) {
//            print("gesture: \(gestureRecognizer)")
//            print("not: \((gestureRecognizer as! UITapGestureRecognizer).numberOfTapsRequired)")
            let touchPoint = gestureRecognizer.locationOfTouch(0, inView: self)
            let cursorPosition = closestPositionToPoint(touchPoint)
            selectedTextRange = textRangeFromPosition(cursorPosition!, toPosition: cursorPosition!)
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        else if gestureRecognizer.isKindOfClass(UILongPressGestureRecognizer) {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        else if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer) {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        else {
//            print("gesture: \(gestureRecognizer)")
            return false
        }
        
    }
    
    
    
    
    
    
    
//    //If Editable = NO
//    //Prevent text selection through double tapping
//    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
//        
//        if self.editable == false {
//            if gestureRecognizer.isKindOfClass(UITapGestureRecognizer.self) && (gestureRecognizer as! UITapGestureRecognizer).numberOfTapsRequired == 2 {
//                if gestureRecognizer.isMemberOfClass(UITapGestureRecognizer.self) {
//                    return true
//                }
//                else {
//                    return false
//                }
//            }
//        }
//        return super.gestureRecognizerShouldBegin(gestureRecognizer)
//    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
