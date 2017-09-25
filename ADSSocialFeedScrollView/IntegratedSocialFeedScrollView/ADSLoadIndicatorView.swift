//
//  ADSLoadIndicatorView.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 28/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit

class ADSLoadIndicatorView: UIView {
    
    private var activityIndicatorView: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    private func initialize() {
        self.activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        
        self.activityIndicatorView.hidden = false
        self.activityIndicatorView.hidesWhenStopped = false
        
        self.activityIndicatorView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)
        self.addSubview(self.activityIndicatorView)
    }
    
    override var frame: CGRect {
        didSet {
            if self.activityIndicatorView != nil {
                self.activityIndicatorView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)
            }
        }
    }
    
    override var center: CGPoint {
        didSet {
            if self.activityIndicatorView != nil {
                self.activityIndicatorView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)
            }
        }
    }
    
    func isRefreshing() -> Bool {
        return self.activityIndicatorView.isAnimating()
    }
    
    func startRefreshing() {
        self.activityIndicatorView.startAnimating()
    }
    
    func stopRefreshing() {
        self.activityIndicatorView.stopAnimating()
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
