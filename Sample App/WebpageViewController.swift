//
//  WebpageViewController.swift
//  Yoga Mamas
//
//  Created by Jason Pan on 27/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit
import WebKit
import ADSSocialFeedScrollView
import MBProgressHUD

class WebpageViewController: UIViewController {
    
    private var loadingHUD              : MBProgressHUD!
    private var backBarButtonItem       : UIBarButtonItem!
    private var forwardBarButtonItem    : UIBarButtonItem!
    
    private var hasLoadedForFirstTime   : Bool = false
    
    var webView                         : WKWebView!
    var url                             : NSURL! {
        willSet {
            guard self.webView != nil else {
                return
            }
            
            if self.url != newValue {
                self.webView.loadRequest(NSURLRequest(URL: url))
                self.showLoadHUD()
            }
        }
    }
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(url: NSURL) {
        super.init(nibName: nil, bundle: nil)
        
        self.url = url
    }
    
    //*********************************************************************************************************
    // MARK: - UI helpers
    //*********************************************************************************************************
    
    func setUpLoadHUD() {
        if self.loadingHUD?.superview == nil {
            self.loadingHUD = MBProgressHUD(view: self.view)
            self.loadingHUD.mode = .Indeterminate
            
            self.view.addSubview(self.loadingHUD)
        }
    }
    
    func showLoadHUD() {
        self.setUpLoadHUD()
        
        let loadContent: String = self.title != nil ? " \(self.title!.lowercaseString)" : ""
        self.loadingHUD?.label.text = "Loading\(loadContent)..."
        
        self.loadingHUD?.showAnimated(true)
    }
    
    func setupNavigationUI() {
        if self.backBarButtonItem == nil {
            self.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.goBack))
            self.backBarButtonItem.enabled = false
        }
        if self.forwardBarButtonItem == nil {
            self.forwardBarButtonItem = UIBarButtonItem(title: "Forward", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.goForward))
            self.forwardBarButtonItem.enabled = false
        }
    }
    
    func goBack() {
        guard self.webView != nil else {
            return
        }
        
        if self.webView.canGoBack {
            self.webView.goBack()
        }
        self.backBarButtonItem.enabled = self.webView.canGoBack
    }
    
    func goForward() {
        guard self.webView != nil else {
            return
        }
        
        if self.webView.canGoForward {
            self.webView.goForward()
        }
        self.forwardBarButtonItem.enabled = self.webView.canGoForward
    }
    
    //*********************************************************************************************************
    // MARK: - View lifecycle
    //*********************************************************************************************************
    
    override func viewWillAppear(animated: Bool) {
        if self.isViewLoaded() {
            self.setupNavigationUI()
            self.navigationController?.navigationItem.leftBarButtonItem = self.backBarButtonItem
            self.navigationController?.navigationItem.rightBarButtonItem = self.forwardBarButtonItem
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        guard self.webView != nil else {
            return
        }
        
//        guard self.loadingHUD != nil else { return }
        if self.webView.loading {
            self.showLoadHUD()
        }else {
            self.loadingHUD?.hideAnimated(true)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.webView.navigationDelegate = nil
        self.webView.scrollView.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        self.webView = WKWebView()
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.navigationDelegate = self
        
        self.webView.scrollView.delegate = self
        self.webView.scrollView.pagingEnabled = false
        
        self.view.addSubview(self.webView)
        
        let leadingConstraint   = self.webView.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor)
        let trailingConstraint  = self.webView.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor)
        let topConstraint       = self.webView.topAnchor.constraintEqualToAnchor(self.view.topAnchor)
        let bottomConstraint    = self.webView.bottomAnchor.constraintEqualToAnchor(self.bottomLayoutGuide.topAnchor)
        NSLayoutConstraint.activateConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
        
        self.webView.loadRequest(NSURLRequest(URL: self.url))
        self.showLoadHUD()
        
        self.webView.allowsBackForwardNavigationGestures = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//*********************************************************************************************************
// MARK: - UIScrollViewDelegate
//*********************************************************************************************************

extension WebpageViewController: UIScrollViewDelegate {
    
    //Fixes (somewhat) UIScrollView decelerationRate bug
    //See: http://stackoverflow.com/a/32843700/699963
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
}

//*********************************************************************************************************
// MARK: - WKNavigationDelegate
//*********************************************************************************************************

extension WebpageViewController: WKNavigationDelegate {
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard self.webView != nil else {
            return
        }
        
        if self.hasLoadedForFirstTime {
            self.setUpLoadHUD()
            self.loadingHUD?.label.text = "Loading"
            self.loadingHUD?.showAnimated(true)
        }
        
        self.backBarButtonItem.enabled = self.webView.canGoBack
        self.forwardBarButtonItem.enabled = self.webView.canGoForward
    }
    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        guard self.webView != nil else {
            return
        }
        
        self.backBarButtonItem.enabled = self.webView.canGoBack
        self.forwardBarButtonItem.enabled = self.webView.canGoForward
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        self.loadingHUD?.hideAnimated(true)
        self.hasLoadedForFirstTime = true
    }
    
}
