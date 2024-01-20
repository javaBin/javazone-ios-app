import SwiftUI
import WebKit

struct PartnerWebViewRepresentable: UIViewRepresentable {
    var webView = WebView()

    func makeUIView(context: Context) -> WKWebView {
        webView.webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

class WebView: NSObject {
    var webView: WKWebView!

    let request = URLRequest(url: EnvConfig.partnerUrl)
    
    override init() {
        super.init()
        webView = WKWebView(frame: .zero)
        webView.load(request)
        webView.setPullToRefresh()
        webView.navigationDelegate = self
    }
}

extension WebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.refreshControl?.endRefreshing()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.refreshControl?.endRefreshing()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webView.refreshControl?.endRefreshing()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url, !url.absoluteString.contains("javazone") {
            decisionHandler(.cancel)
            
            UIApplication.shared.open(url)
        } else {
            decisionHandler(.allow)
        }
    }
}

extension WKWebView {
    var refreshControl: UIRefreshControl? {
        (scrollView.getAllSubviews() as [UIRefreshControl]).first
    }

    func setPullToRefresh() {
        (scrollView.getAllSubviews() as [UIRefreshControl]).forEach {
            $0.removeFromSuperview()
        }

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(webViewPullToRefreshHandler(source:)), for: .valueChanged)
        scrollView.addSubview(refreshControl)
    }

    @objc func webViewPullToRefreshHandler(source: UIRefreshControl) {
        guard let url = self.url else {
            source.endRefreshing()
            return
        }
        load(URLRequest(url: url))
    }
}

extension UIView {
    class func getAllSubviews<T: UIView>(from parentView: UIView) -> [T] {
        return parentView.subviews.flatMap { subView -> [T] in
            var result = getAllSubviews(from: subView) as [T]
            if let view = subView as? T {
                result.append(view)
            }
            return result
        }
    }

    func getAllSubviews<T: UIView>() -> [T] {
        return UIView.getAllSubviews(from: self) as [T]
    }
}


struct PartnerWebView: View {
    var body: some View {
        PartnerWebViewRepresentable()
            .background(Color.black)
    }
}

struct PartnerWebView_Previews: PreviewProvider {
    static var previews: some View {
        PartnerWebView()
    }
}
