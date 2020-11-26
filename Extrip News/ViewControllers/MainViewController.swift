//
//  MainViewController.swift
//  TemplateForWebViewBasedApps
//
//  Created by Maxim Gaysin on 26/09/2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import UIKit
import WebKit

protocol MainViewControllerDelegate {
  func toggleRightMenu()
}

class MainViewController: UIViewController {
  
  enum Portal {
    case aeroexpress
    case rzd
  }
  
  enum WebViewPageType {
    case aeroexpressStart, aeroexpressContacts, aeroexpressMicrocabinet, aeroexpressPay
    case rzdStart, rzdShedule, rzdPassengerInfo, rzdLogin, rzdCabinet, rzdOrderForm, rzdSomeInfo
    case other
  }
  
  enum PageLanguage: String {
    case english = "🇬🇧", russian = "🇷🇺", german = "🇩🇪", chinese = "🇨🇳"
  }
  
  @IBOutlet weak var toolBar: UIToolbar!
  @IBOutlet weak var webView: WKWebView!
  @IBOutlet weak var webViewBottomConstraint: NSLayoutConstraint!
  
  var portal: Portal = .aeroexpress
  
  var currentLanguage: PageLanguage? {
    didSet {
      flagButton?.title = currentLanguage?.rawValue
    }
  }

  var currentWebViewPageType: WebViewPageType {
    get {
      if let currentURL = webView.url?.absoluteString {
        switch currentURL {
        //Aeroexpress URL`s
        case let url where url.contains("aeroexpress.app") && !url.contains("contacts") && !url.contains("microcabinet"):
          return .aeroexpressStart
        case let url where url.contains("aeroexpress.app") && url.contains("contacts") && !url.contains("microcabinet"):
          return .aeroexpressContacts
        case let url where url.contains("aeroexpress.app") && !url.contains("contacts") && url.contains("microcabinet"):
          return .aeroexpressMicrocabinet
        case let url where url.contains("securepayments.sberbank"):
          return .aeroexpressPay
        //RZD URL`s
        case let url where url.contains("rzd") && !url.contains("date=") && !url.contains("train/docs") && !url.contains("login") && !url.contains("detail"):
          return .rzdStart
        case let url where url.contains("rzd") && url.contains("date="):
          return .rzdShedule
        case let url where url.contains("rzd") && url.contains("train/docs"):
            return .rzdPassengerInfo
        case let url where url.contains("rzd") && url.contains("login"):
          return .rzdLogin
        case let url where url.contains("detail"):
          return .rzdCabinet
        case let url where url.contains("railway/order/blank") || url.contains("transaction"):
          return .rzdOrderForm
        case let url where url.contains("ehlektronnaja"):
          return .rzdSomeInfo
        default:
          return .other
        }
      }
      return .other
    }
  }
 
  ///little view for language buttons
  var languageMenuView: LanguageMenuView!

  /// view to copy and paste usreinformation
  var copyBoardView: CopyBoardView!
  
  /// buttons behavior depending on current webView`s url
  var isFlagButtonPressed = false {
    didSet {
      self.webView.isUserInteractionEnabled.toggle()
    }
  }
  
  var isCopyBoardOpened = false
  
  ///webView`s observers putted in Set
  var observers = Set<NSKeyValueObservation>()
  
  ///toolBar objects
  var browserBackButton: UIBarButtonItem?
  var space: UIBarButtonItem?
  var menuButton: UIBarButtonItem?
  var newSearchButton: UIBarButtonItem?
  var flagButton: UIBarButtonItem?
  var cabinetButton: UIBarButtonItem?
  var copyBoardButton: UIBarButtonItem?
  var shareButton: UIBarButtonItem?
  var sheduleButton: UIBarButtonItem?
  
  var url: String {
    let index = Languages.appleLanguageCodes.firstIndex(of: preferredLanguage) ?? 0
    return Languages.urls[index]
  }

  var preferredLanguage: String {
    get {return Languages.findLanguage()}
  }
  
  var delegate: MainViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView.navigationDelegate = self
    webView.uiDelegate = self
    toolBarConfig()
    webView.config(url: url)
    //      progressBarConfig()
    registerIsLoadingObserver()
    registerURLObserver()
    webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
    setupCurrentPageLanguage()
  }
  
  func setupCurrentPageLanguage() {
    currentLanguage = {
      switch preferredLanguage {
      case "ru": return .russian
      case "en": return .english
      case "de": return .german
      case "zh": return .chinese
      default: return .english
      }
    }()
  }
    
    func getRzdUrl() -> String {
        switch currentLanguage {
        case .english:
            return "https://www.rzd.online/rzd-en.html"
        case .russian:
            return "https://www.rzd.online/rzd-ru.html"
        case .german:
            return "https://www.rzd.online/rzd-de.html"
        case .chinese:
            return "https://www.rzd.online/rzd-zh.html"
        default:
            return "https://www.rzd.online/rzd-en.html"
        }
    }

  func urlDidChange() {
    switch currentWebViewPageType {
//aeroexpress pages
    case .aeroexpressStart:
      toolBar.setItems([sheduleButton!, space!, cabinetButton!, flagButton!, menuButton!], animated: true)
    case .aeroexpressContacts:
      toolBar.setItems([sheduleButton!, space!, copyBoardButton!, cabinetButton!, flagButton!,  menuButton!], animated: true)
    case .aeroexpressMicrocabinet:
      toolBar.setItems([sheduleButton!, space!, copyBoardButton!, browserBackButton!, flagButton!,  menuButton!], animated: true)
    case .aeroexpressPay:
      toolBar.setItems([sheduleButton!, space!, copyBoardButton!, menuButton!], animated: true)
//rzd pages
    case .rzdStart:
      toolBar.setItems([space!, cabinetButton!, flagButton!, menuButton!], animated: true)
      finishWebPageLoading()
    case .rzdShedule:
      toolBar.setItems([space!, browserBackButton!, cabinetButton!, menuButton!], animated: true)
      finishWebPageLoading()
    case .rzdPassengerInfo:
      toolBar.setItems([space!, copyBoardButton!, browserBackButton!,  cabinetButton!, menuButton!], animated: true)
      finishWebPageLoading()
    case .rzdLogin:
      toolBar.setItems([space!, copyBoardButton!, browserBackButton!, menuButton!], animated: true)
    case .rzdCabinet:
      toolBar.setItems([space!, browserBackButton!, menuButton!], animated: true)
    case .rzdOrderForm:
      toolBar.setItems([shareButton!, space!, browserBackButton!, menuButton!], animated: true)
      finishWebPageLoading()
    case .rzdSomeInfo:
      toolBar.setItems([shareButton!, space!, browserBackButton!,  menuButton!], animated: true)
    default:
      toolBar.setItems([space!, newSearchButton!, cabinetButton!, menuButton!], animated: true)
      finishWebPageLoading()
    }
    print("webView did finish loading, currentPageType is: \(self.currentWebViewPageType)")
  }
  
  func finishWebPageLoading() {
    webView.isHidden = false
     }
 //MARK: WebView Key-Value observing
  func registerIsLoadingObserver() {
    let options: NSKeyValueObservingOptions = [.new]
    let isLoadingObserver = webView.observe(\.isLoading,
                                   options: options,
                                   changeHandler: {object, change in
                                    if let value = change.newValue {
                                      if value {
                                        print("isLoading: true")
                                      } else {
                                        print("isLoading: false")
                                        print("URL IS: \(String(describing: self.webView.url))")
                                        self.webView.evaluate(script: ScriptStorage.mainPageHideHeader)
                                        self.finishWebPageLoading()
                                      }
                                    }
    })
    observers.insert(isLoadingObserver)
  }
    
    func registerURLObserver() {
        let options: NSKeyValueObservingOptions = [.new]
        let urlObserver = webView.observe(\.url,
                                                options: options,
                                                changeHandler: {object, change in
                                                    if let value = change.newValue {
                                                        print("new URL is: \(String(describing: value))")
                                                        self.urlDidChange()
        }
        })
        observers.insert(urlObserver)
    }
    
    func removeObservers() {
        observers.removeAll()
    }


  //MARK:- ToolBar config
  func toolBarConfig() {
    let languageButtonEmoji = transformPreferredLanguageToFlagEmoji()
    toolBar.backgroundColor = ControlPanel.toolBarBackgroundColor
    sheduleButton = UIBarButtonItem(title: "🕗",
                              style: .plain,
                              target: self,
                              action: #selector(sheduleButtonTapped))
    space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                            target: nil,
                            action: nil)


    
    menuButton = UIBarButtonItem(image: UIImage(named: "menu"),
                                 style: .plain,
                                 target: self,
                                 action: #selector(barButtonMenuTapped))
    
    browserBackButton = UIBarButtonItem(title: "🔙",
                                        style: .plain,
                                        target: self,
                                        action: #selector(browserBackButtonTapped))
    
    flagButton = UIBarButtonItem(title: languageButtonEmoji,
                                 style: .plain,
                                 target: self,
                                 action: #selector(flagButtonTapped))

    newSearchButton = UIBarButtonItem(image: UIImage(named: "home"),
                                      style: .plain,
                                      target: self,
                                      action: #selector(newSearchButtonTapped))
    
    cabinetButton = UIBarButtonItem(image: UIImage(named: "tickets"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(cabinetButtonTapped))
    copyBoardButton = UIBarButtonItem(image: UIImage(named: "copyboard"),
                                      style: .plain,
                                      target: self,
                                      action: #selector(copyBoardButtonTapped))
    shareButton = UIBarButtonItem(image: UIImage(named: "share"),
                                  style: .plain,
                                  target: self,
                                  action: #selector(shareButtonTapped))
    sheduleButton?.tintColor = .darkGray
    shareButton?.tintColor = .darkGray
    copyBoardButton?.tintColor = .darkGray
    cabinetButton?.tintColor = .darkGray
    menuButton?.tintColor = .darkGray
    newSearchButton?.tintColor = .darkGray
    flagButton?.tintColor = .darkGray
//    browserBackButton?.tintColor = .darkGray
    toolBar.setItems([sheduleButton!, space!, cabinetButton!, flagButton!, menuButton!], animated: true)
  
  }
  //MARK:- TOOLBAR BUTTONS ACTIONS
  @objc func shareButtonTapped() {
  let activityViewController = UIActivityViewController(activityItems: [webView.url ?? ControlPanel.appStoreUrl],
                                                            applicationActivities: nil)
      if UIDevice.current.userInterfaceIdiom == .pad {
  activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 0,
                                                                                  y: 30,
                                                                                  width: view.frame.width,
                                                                                  height: view.frame.height)
      }
      self.present(activityViewController, animated: true)
    }
  
  @objc func copyBoardButtonTapped() {
    addCopyBoardView()
  }
  
  @objc func sheduleButtonTapped() {
    webView.loadFrom(string: Languages.aeSheduleURL)
  }
  
  @objc func cabinetButtonTapped() {
    var cabinetURL = ""
    
    if portal == .aeroexpress {
      switch currentLanguage {
      case .english:
        cabinetURL = "https://www.aeroexpress.app/app.html#/en/microcabinet/login"
      case .russian:
        cabinetURL = "https://www.aeroexpress.app/app.html#/microcabinet/login"
      case .german:
        cabinetURL = "https://www.aeroexpress.app/app.html#/de/microcabinet/login"
      case .chinese:
        cabinetURL = "https://www.aeroexpress.app/app.html#/zh/microcabinet/login"
      default:
        cabinetURL = "https://www.aeroexpress.app/app.html#/microcabinet/login"
      }
    } else {
      print("rzd")
      switch currentLanguage {
      case .english:
        cabinetURL = "https://rzd.online/rzd2.html#"
      case .russian:
        cabinetURL = "https://rzd.online/rzd1.html#"
      case .german:
        cabinetURL = "https://rzd.online/rzd3.html#"
      case .chinese:
        cabinetURL = "https://rzd.online/rzd4.html#"
      default:
        cabinetURL = "https://rzd.online/rzd1.html#"
      }
    }
    webView.loadFrom(string: cabinetURL)
  }
  
  @objc func flagButtonTapped() {
    toggleLanguageMenu()
    isFlagButtonPressed.toggle()
  }
  
  @objc func barButtonMenuTapped() {
    delegate?.toggleRightMenu()
    // Prompt for review (10 times needed)
    ReviewRequest.shared.promptReview()
  }
  
  @objc func newSearchButtonTapped() {
    var url = self.url
    if portal == .aeroexpress {
      
    } else {
      url = getRzdUrl()
    }
    webView.loadFrom(string: url)
  }
  
  @objc func browserBackButtonTapped() {
    webView.goBack()
  }
    
  func transformPreferredLanguageToFlagEmoji() -> String {
      switch preferredLanguage {
      case "en":
        return "🇬🇧"
      case "ru":
        return "🇷🇺"
      case "de":
        return "🇩🇪"
      case "zh":
        return "🇨🇳"
      default:
        return "🇬🇧"
      }
    }
  
  func toggleLanguageMenu() {
    flagButton?.isEnabled.toggle()
    if isFlagButtonPressed {
      dismissLanguageMenuView()
    } else {
      addLanguageMenuView()
    }
  }

  func dismissLanguageMenuView() {
    guard languageMenuView != nil else {return}
    UIView.animate(withDuration: 0.5,
                   delay: 0,
                   usingSpringWithDamping: 0.7,
                   initialSpringVelocity: 3,
                   options: .curveEaseInOut,
                   animations: {self.languageMenuView.frame.origin.y = UIScreen.main.bounds.maxY},
                   completion: {_ in
                    self.languageMenuView.removeFromSuperview()
                    self.languageMenuView = nil
                    self.flagButton?.isEnabled.toggle()
                    
    })
  }
  
  func addLanguageMenuView() {
    guard languageMenuView == nil else {return}
    let origin = CGPoint(x: UIScreen.main.bounds.maxX - 110, y: UIScreen.main.bounds.maxY)
    languageMenuView = LanguageMenuView(origin: origin)
    languageMenuView.delegate = self
    view.addSubview(languageMenuView)
    languageMenuView.layer.shadowOpacity = 0.5
    languageMenuView.layer.shadowOffset = CGSize(width: 3, height: 3)
    languageMenuView.layer.shadowColor = ControlPanel.sideMenuBackgroundColor.cgColor
    
    UIView.animate(withDuration: 0.5,
                   delay: 0,
                   usingSpringWithDamping: 0.7,
                   initialSpringVelocity: 0.3,
                   options: .curveEaseInOut,
                   animations: {self.languageMenuView.frame.origin.y = UIScreen.main.bounds.maxY - self.languageMenuView.frame.height - self.toolBar.frame.height - 5},
                   completion: {_ in
                    self.flagButton?.isEnabled.toggle()
    })
  }
  
  func squeezeWebView() {
    if isCopyBoardOpened {
    self.webViewBottomConstraint.constant = UIScreen.main.bounds.maxY/4 - self.toolBar.frame.height
    } else {
    self.webViewBottomConstraint.constant = 1
    }
  }
  
  func addCopyBoardView() {
    guard copyBoardView == nil else {return}
    let origin = CGPoint(x: 0, y: UIScreen.main.bounds.maxY)
    copyBoardView = CopyBoardView(origin: origin)
    copyBoardView.delegate = self
    copyBoardView.layer.borderWidth = 1
    copyBoardView.layer.borderColor = UIColor.darkGray.cgColor
    view.addSubview(copyBoardView)
    UIView.animate(withDuration: 0.5,
                   delay: 0,
                   usingSpringWithDamping: 0.7,
                   initialSpringVelocity: 0.3,
                   options: .curveEaseInOut,
                   animations: {self.copyBoardView.frame.origin.y = 3 * UIScreen.main.bounds.maxY/4 - self.view.safeAreaInsets.bottom},
                   completion: {_ in
                    self.isCopyBoardOpened = true
                    self.squeezeWebView()})
  }
  
  func dismissCopyBoardView() {
    guard copyBoardView != nil else {return}
    self.isCopyBoardOpened = false
    squeezeWebView()
    UIView.animate(withDuration: 0.5,
                   delay: 0,
                   usingSpringWithDamping: 0.7,
                   initialSpringVelocity: 3,
                   options: .curveEaseInOut,
                   animations: {self.copyBoardView.frame.origin.y = UIScreen.main.bounds.maxY},
                   completion: {_ in
                    self.copyBoardView.removeFromSuperview()
                    self.copyBoardView = nil
                    
    })
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    if isFlagButtonPressed {
    dismissLanguageMenuView()
    coordinator.animate(alongsideTransition: nil, completion: {_ in
      self.addLanguageMenuView()
    })
  }
    if isCopyBoardOpened {
      dismissCopyBoardView()
      coordinator.animate(alongsideTransition: nil, completion: {_ in
        self.addCopyBoardView()
      })
    }
  }
}

//MARK: - WKNavigationDelegate
extension MainViewController: WKNavigationDelegate {
  
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//    view.showProgress()
//    webView.isHidden = true
  }
}
//MARK: - CopyBoardViewDelegate
extension MainViewController: CopyBoardViewDelegate {
  func closeButtonTouch() {
    dismissCopyBoardView()
  }
}

//MARK: - LanguageMenuViewDelegate
extension MainViewController: LanguageMenuViewDelegate {
  func buttonPressed(with buttonLabelText: String) {
    var urlString:String = ""
    
    guard buttonLabelText != currentLanguage?.rawValue else {return}
    flagButton?.isEnabled.toggle()
    
    currentLanguage = {
           switch buttonLabelText {
           case "🇷🇺": return .russian
           case "🇬🇧": return .english
           case "🇩🇪": return .german
           case "🇨🇳": return .chinese
           default: return .english
           }
         }()
    
    if portal == .aeroexpress  {
  
      let languageCode: String = {
        switch buttonLabelText {
        case "🇷🇺":
          Bundle.setLanguage(lang: "ru")
          return ""
        case "🇬🇧": return "en"
        case "🇩🇪":
          Bundle.setLanguage(lang: "de")
          return "de"
        case "🇨🇳": return "zh"
        default: return ""
        }
      }()
      
      switch languageCode {
      case "":
        currentLanguage = .russian
        switch currentWebViewPageType {
        case .aeroexpressStart:
          urlString = "https://www.aeroexpress.app/app.html#/"
        case .aeroexpressContacts:
          urlString = "https://www.aeroexpress.app/app.html#/contacts"
        case .aeroexpressMicrocabinet:
          urlString = "https://www.aeroexpress.app/app.html#/microcabinet/login"
        default:
          break
        }
      default:
        switch currentWebViewPageType {
        case .aeroexpressStart:
          urlString = "https://www.aeroexpress.app/app.html#/" + languageCode
        case .aeroexpressContacts:
          urlString = "https://www.aeroexpress.app/app.html#/" + languageCode + "/contacts"
        case .aeroexpressMicrocabinet:
          urlString = "https://www.aeroexpress.app/app.html#/" + languageCode + "/microcabinet/login"
        default:
          break
        }
      }
    } else {
      urlString = getRzdUrl()
    }

    isFlagButtonPressed.toggle()
    dismissLanguageMenuView()
    webView.loadFrom(string: urlString)
    if portal == .aeroexpress {
      webView.evaluate(script: ScriptStorage.mainPageHideHeader)
    }
  }
}

//Allows to open "target:blank!" hrefs
extension MainViewController: WKUIDelegate {
  func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
      if navigationAction.targetFrame == nil {
          webView.load(navigationAction.request)
      }
      return nil
  }
}
