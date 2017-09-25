//
//  ADSFeedPostView.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 11/03/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import Foundation

class ADSFeedPostView: UIView {
    
    internal weak var __postViewTopLayoutConstraint       : NSLayoutConstraint!
//    internal weak var __postViewBottomLayoutConstraint       : NSLayoutConstraint!
    internal weak var __postViewCentreXLayoutConstraint       : NSLayoutConstraint!
    internal weak var __postViewWidthLayoutConstraint       : NSLayoutConstraint!
    internal weak var __postViewHeightLayoutConstraint       : NSLayoutConstraint!
    
    @IBOutlet private weak var contentView: UIView!
    
    func initialize() {
        NSBundle(forClass: self.dynamicType).loadNibNamed(self.nameOfClass, owner: self, options: nil)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.contentView)
        
        self.addConstraint(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Left,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.contentView,
            attribute: NSLayoutAttribute.Left,
            multiplier: 1,
            constant: 0))
        
        self.addConstraint(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.contentView,
            attribute: NSLayoutAttribute.Right,
            multiplier: 1,
            constant: 0))
        
        self.addConstraint(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.contentView,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: 0))
        
        self.addConstraint(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.contentView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    func setPostHeight(height: CGFloat) {
        self.frame.size.height = height
        
        if self.__postViewHeightLayoutConstraint == nil {
            self.__postViewHeightLayoutConstraint = NSLayoutConstraint(
                item: self,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.NotAnAttribute,
                multiplier: 1,
                constant: self.frame.size.height) //TODO: Create generic class-scope constant
        }
        
        if self.__postViewHeightLayoutConstraint.constant != height {
            self.__postViewHeightLayoutConstraint.constant = height
            self.layoutIfNeeded()
//            self.setNeedsLayout()
//            self.setNeedsUpdateConstraints()
        }
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    
}
