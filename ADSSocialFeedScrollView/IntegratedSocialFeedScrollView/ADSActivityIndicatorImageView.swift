//
//  ADSActivityIndicatorImageView.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 7/05/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit

class ADSActivityIndicatorImageView: UIImageView {
    
    internal private(set) var activityIndicator: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.initialize()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        self.initialize()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }
    
    func initialize() {
        if self.activityIndicator == nil {
            self.activityIndicator = UIActivityIndicatorView()
            self.activityIndicator.center = self.center
            
            self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
//            self.activityIndicator.activityIndicatorViewStyle = .WhiteLarge
            self.activityIndicator.activityIndicatorViewStyle = .Gray
            
            self.activityIndicator.hidden = true
            self.addSubview(self.activityIndicator)
            
//            self.addConstraint()
            NSLayoutConstraint(item: self.activityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
            NSLayoutConstraint(item: self.activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0).active = true
            NSLayoutConstraint(item: self.activityIndicator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.activityIndicator.bounds.width).active = true
            NSLayoutConstraint(item: self.activityIndicator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.activityIndicator.bounds.height).active = true
        }
        
//        self.backgroundColor = UIColor.lightGrayColor()
        self.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
    }
    
    func beginRefreshing() {
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
    }
    
    func endRefreshing() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
