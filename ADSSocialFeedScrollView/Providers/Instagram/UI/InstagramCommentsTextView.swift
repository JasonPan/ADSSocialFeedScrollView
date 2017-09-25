//
//  InstagramCommentsTextView.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 13/03/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit

class InstagramCommentsTextView: UITextView {
    
    override func awakeFromNib() {
        let tapOutTextField: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.showFullCaption))
        self.addGestureRecognizer(tapOutTextField)
    }
    
    func showFullCaption() {
        if let superview = self.superview?.superview as? InstagramPostView {
            superview.showFullCaption = true
            superview.refreshView()
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
