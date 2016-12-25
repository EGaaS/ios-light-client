//
//  ViewController.swift
//  DayLight
//
//  Created by Andrei Nechaev on 8/29/16.
//  Copyright © 2016 Andrei Nechaev. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var request: URLRequest?
    var poolURL: URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 20)
        webView = WKWebView(frame: frame)
        view.addSubview(webView);
        webView.navigationDelegate = self
        
        guard let url = poolURL else {
            let _ = self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        self.request = URLRequest(url: url)
        self.webView.load(self.request!)
    
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("provisional navigation")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let resp = navigationResponse.response as! HTTPURLResponse
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: resp.allHeaderFields as! [String:String], for: resp.url!)
        
        for cookie in cookies {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        
        let path = request.url?.absoluteString
        
        if let isThere = path?.contains("dcoinKey"), isThere {
            decisionHandler(.cancel)
            let str = request.url!.absoluteString + "&ios=1&first=1"
            let url = URL(string: str)!
            print("downloading key \(url)")
            if let data = try? Data(contentsOf: url) {
                if let img = UIImage(data: data) {
                    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                }
            }
            return
        }
        
        if let poolName = poolURL?.absoluteString, let path = path, !(path.contains(poolName)) {
            let url = URL(string: path)!
            UIApplication.shared.openURL(url)
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    
    @IBAction func menu(_ sender: AnyObject) {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = HTTPCookieStorage.shared
        
        let session = URLSession(configuration: config)
        let url = "\(request!.url!.absoluteString)/ajax?controllerName=menu"
        session.dataTask(with: URL(string: url)!).resume()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        
        coordinator.animate(alongsideTransition: { _ in
            let frame = CGRect(x: 0, y: 20, width: size.width, height: size.height - 20)
            self.webView.frame = frame
            }, completion: nil)
    }
}
