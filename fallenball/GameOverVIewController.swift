//
//  GameOverVIewvController.swift
//  fallenball
//
//  Created by Vlad Kuzmenko on 24.06.2024.
//

import UIKit
import WebKit

class GameOverViewController: UIViewController,  WKNavigationDelegate {
    
    var webView: WKWebView!
    var isWinner: Bool = false
    var gameScene: GameScene?
    let toolBarItems = UIToolbar()
    var leftButton = UIBarButtonItem()
    var rightButton = UIBarButtonItem()
    var refreshButton = UIBarButtonItem()
    var backButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        super.viewDidLoad()
        self.navigationController?.setToolbarHidden(true, animated: false)
        createWebView()
        toolBarSettings()
    }
    
    func createWebView() {
        webView = WKWebView()
        view.addSubview(webView)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             webView.heightAnchor.constraint(equalToConstant: view.frame.height - 50)
            ])
        
        DispatchQueue.main.async {
            if self.isWinner {
                if let winnerURL = SupportingViewController.shared.winnerURL, let url = URL(string: winnerURL) {
                    self.webView.load(URLRequest(url: url))
                } else {
                    self.showError()
                }
            } else {
                if let loserURL = SupportingViewController.shared.loserURL, let url = URL(string: loserURL) {
                    self.webView.load(URLRequest(url: url))
                } else {
                    self.showError()
                }
            }
        }
    }
    
    func toolBarSettings() {
        
        let width = 50
        let heigh = 50
        
        let rightArrow = UIButton(type: .custom)
        rightArrow.setImage(.rightArrow, for: .normal)
        rightArrow.setImage(.dissRight, for: .disabled)
        rightArrow.frame.size = CGSize(width: width, height: heigh)
        rightArrow.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        
        let mid = UIButton(type: .custom)
        mid.frame.size = CGSize(width: 10, height: heigh)
        
    
    
        let leftArrow = UIButton(type: .custom)
        leftArrow.setImage(.leftArrow, for: .normal)
        leftArrow.setImage(.disLeft, for: .disabled)
        leftArrow.frame.size = CGSize(width: width, height: heigh)
        leftArrow.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        backButton = UIBarButtonItem(image: .buttonBack.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonPressed))
        leftButton = UIBarButtonItem(customView: leftArrow)
         let midButton = UIBarButtonItem(customView: createSpacer(width: 5))
        rightButton = UIBarButtonItem(customView: rightArrow)
        refreshButton = UIBarButtonItem(image: .refresh.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(refresh))
      
        let fixedSpaсe = UIBarButtonItem(systemItem: .fixedSpace)
        let flaxedSpace = UIBarButtonItem(systemItem: .flexibleSpace)
        toolBarItems.barTintColor  = .newgreen
        toolBarItems.items = [ leftButton, midButton, rightButton, fixedSpaсe, refreshButton, flaxedSpace, backButton]
        view.addSubview(toolBarItems)
        
        toolBarItems.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [toolBarItems.bottomAnchor.constraint(equalTo: view.bottomAnchor),
             toolBarItems.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             toolBarItems.heightAnchor.constraint(equalToConstant: 50),
             toolBarItems.widthAnchor.constraint(equalTo: view.widthAnchor)
            ])
    }
    
    
    
    
    @objc func backButtonPressed() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
            gameScene?.restartTheGame()
        }
    }
    
    @objc func goBack() {
        webView.goBack()
    }
    @objc func goForward() {
        webView.goForward()
        
    }
    @objc func refresh() {
        webView.reload()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if webView.canGoBack {
            leftButton.isEnabled = true
        } else {
            leftButton.isEnabled = false
        }
        if webView.canGoForward {
            rightButton.isEnabled = true
        } else {
            rightButton.isEnabled = false
        }
    }
    
    func createSpacer(width: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.widthAnchor.constraint(equalToConstant: width).isActive = true
        return spacer
    }
    
    func showError() {
        let alert = UIAlertController(title: "Error", message: "Downloading Faled", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }
    
    
}

