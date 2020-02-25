//
//  NCViewerRichWorkspaceWebView.swift
//  Nextcloud
//
//  Created by Marino Faggiana on 12/12/19.
//  Copyright © 2019 Marino Faggiana. All rights reserved.
//
//  Author Marino Faggiana <marino.faggiana@nextcloud.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import WebKit

class NCViewerRichWorkspaceWebView: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var webViewBottomConstraint: NSLayoutConstraint!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @objc var metadata: tableMetadata?
    @objc var url: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userAgent : String = CCUtility.getUserAgent()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
                
        var request = URLRequest(url: URL(string: url)!)
        request.addValue("true", forHTTPHeaderField: "OCS-APIRequest")
        let language = NSLocale.preferredLanguages[0] as String
        request.addValue(language, forHTTPHeaderField: "Accept-Language")
                
        webView.configuration.userContentController.add(self, name: "DirectEditingMobileInterface")
        webView.navigationDelegate = self
        webView.customUserAgent = userAgent
        webView.load(request)
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        var safeAreaInsetsBottom: CGFloat = 0
        if #available(iOS 11.0, *) {
            safeAreaInsetsBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }
        guard let info = notification.userInfo else { return }
        guard let frameInfo = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = frameInfo.cgRectValue
        webViewBottomConstraint.constant = keyboardFrame.size.height - safeAreaInsetsBottom
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        webViewBottomConstraint.constant = 0
    }
    
    //MARK: -

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if (message.name == "DirectEditingMobileInterface") {
            
            if message.body as? String == "close" {
                
                if #available(iOS 13.0, *) {
                    self.presentationController?.delegate?.presentationControllerWillDismiss?(self.presentationController!)
                }
                dismiss(animated: true)
            }
            
            if message.body as? String == "share" {
                if (metadata != nil) {
                     NCMainCommon.sharedInstance.openShare(ViewController: self, metadata: metadata!, indexPage: 2)
                }
            }
            
            if message.body as? String == "loading" {
                print("loading")
            }
            
            if message.body as? String == "loaded" {
                print("loaded")
            }
            
            if message.body as? String == "paste" {
                self.paste(self)
            }
        }
    }
        
    //MARK: -

    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, nil);
        }
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation");
    }
    
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("didReceiveServerRedirectForProvisionalNavigation");
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish");
    }
}
