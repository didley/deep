import SwiftUI
import WebKit

let WEB_CLIENT_URL = "http://localhost:5173/"
let webClientUrl = URL(string: WEB_CLIENT_URL)!

final class WebViewController: NSViewController, WKScriptMessageHandler, WKNavigationDelegate {
    private var webView: WKWebView!

    override func loadView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "native")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        view = webView
    }

    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "native")
    }

    func load(_ url: URL) {
        webView.load(URLRequest(url: url))
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "native" else { return }

        guard let action = message.body as? [String: Any],
              let type = action["type"] as? String else {
            print("Invalid message shape:", message.body)
            return
        }

        switch type {
        case "startCapture":
            print("start capture with payload:", action["payload"] ?? "none")
        case "stopCapture":
            print("stop capture")
        default:
            print("Unknown action:", type)
        }
    }
}

struct WebViewControllerRepresentable: NSViewControllerRepresentable {
    let url: URL

    func makeNSViewController(context: Context) -> WebViewController {
        let vc = WebViewController()
        return vc
    }

    func updateNSViewController(_ nsViewController: WebViewController, context: Context) {
        nsViewController.load(url)
    }
}

@main
struct deepApp: App {
    var body: some Scene {
        WindowGroup {
            WebViewControllerRepresentable(url: webClientUrl)
        }
    }
}

#Preview {
    WebViewControllerRepresentable(url: webClientUrl)
}
