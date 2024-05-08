//
//  WebViewViewController.swift
//  Imagegram
//
//  Created by Владислав Усачев on 03.05.2024.
//

import UIKit
import WebKit

enum WebViewConstants{
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

final class WebViewViewController: UIViewController{
    weak var delegate: WebViewViewControllerDelegate?
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progress: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        loadAuthView()
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?, 
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            upgradeProgress()
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func upgradeProgress() {
        progress.progress = Float(webView.estimatedProgress)
        progress.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    private func loadAuthView(){
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {fatalError("Failed to construct URL")}
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
         ]
        guard let url = urlComponents.url else {fatalError("Failed to construct URL")}
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension WebViewViewController: WKNavigationDelegate{
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        }else{
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItems = items.first(where: { $0.name == "code"})
        {
            return codeItems.value
        }else{
            return nil
        }
    }
}

protocol WebViewViewControllerDelegate: AnyObject{
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) //WebViewViewController получил код
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) //пользователь нажал кнопку назад и отменил авторизацию
}

