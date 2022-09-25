//
//  ViewController.swift
//  KakaoShareStoryBoard
//
//  Created by 김정윤 on 2022/09/25.
//

import UIKit
import WebKit
@objcMembers class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    // 웹뷰 목록 관리
    var webViews = [WKWebView]()
    var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRecieveTestNotification(_:)), name: NSNotification.Name("TestNotification"), object: nil)

        let screenSize: CGRect = UIScreen.main.bounds
        webView = createWebView(frame: screenSize, configuration: WKWebViewConfiguration())
        // Do any additional setup after loading the view.
        let myRequest = URLRequest(url: Var.myURL!)
        webView.load(myRequest)
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
        
    }
    
    @objc func didRecieveTestNotification(_ notification: Notification) {
            print("Test Notification")
        let myRequest = URLRequest(url: Var.myURL!)
        webView.load(myRequest)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void ) {
        print("!!! webView method - string", navigationAction.request.url?.absoluteString ?? "")

        // 카카오 SDK가 호출하는 커스텀 URL 스킴인 경우 open(_ url:) 메서드를 호출합니다.
        if let url = navigationAction.request.url , ["kakaolink", "itms-appss"].contains(url.scheme) {

            // 카카오톡 실행 가능 여부 확인 후 실행
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }

            decisionHandler(.cancel); return
        }

        // 서비스에 필요한 나머지 로직을 구현합니다.
        decisionHandler(.allow)
    }
    
    /// ---------- 팝업 열기 ----------
    /// - 카카오 JavaScript SDK의 로그인 기능은 popup을 이용합니다.
    /// - window.open() 호출 시 별도 팝업 webview가 생성되어야 합니다.
    ///
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        guard let frame = self.webViews.last?.frame else {
            return nil
        }
        return createWebView(frame: frame, configuration: configuration) // 웹뷰를 생성하여 리턴하면 현재 웹뷰와 parent 관계가 형성됩니다.
    }

    /// ---------- 팝업 닫기 ----------
    /// - window.close()가 호출되면 앞에서 생성한 팝업 webview를 닫아야 합니다.
    ///
    func webViewDidClose(_ webView: WKWebView) {
        destroyCurrentWebView()
    }

    // 웹뷰 생성 메소드 예제
    func createWebView(frame: CGRect, configuration: WKWebViewConfiguration) -> WKWebView {
        let webView = WKWebView(frame: frame, configuration: configuration)
        webView.uiDelegate = self // set delegate
        webView.navigationDelegate = self
        self.view.addSubview(webView) // 화면에 추가
        self.webViews.append(webView) // 웹뷰 목록에 추가
        return webView // 그 외 서비스 환경에 최적화된 뷰 설정하기
    }

    // 웹뷰 삭제 메소드 예제
    func destroyCurrentWebView() {
        self.webViews.popLast()?.removeFromSuperview() // 웹뷰 목록과 화면에서 제거하기
    }
}

//Var.swift
import Foundation
class Var{
    public static var myURL = URL(string:"http://kakao-share.s3-website.ap-northeast-2.amazonaws.com/")

//    public static var myURL = URL(string:"https://developers.kakao.com/tool/demo/message/kakaolink?method=button")
}
