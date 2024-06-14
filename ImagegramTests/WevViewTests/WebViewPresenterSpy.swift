//
//  WebViewPresenterSpy.swift
//  ImagegramTests
//
//  Created by Владислав Усачев on 13.06.2024.
//

import Imagegram
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol{
    var viewDidLoadCalled: Bool = false
    var loadRequestCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
        loadRequest()
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
    
    func loadRequest() {
        loadRequestCalled = true
    }
    
    
}
