import SwiftUI
import WebKit
import ScreenCaptureKit

let WEB_CLIENT_URL = "http://localhost:5173/"
let webClientUrl = URL(string: WEB_CLIENT_URL)!

final class WebViewController: NSViewController, WKScriptMessageHandler, WKNavigationDelegate {
    private var webView: WKWebView!
    private var capture: MinimalScreenCapture? 

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

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard message.name == "native" else { return }

        guard
            let action = message.body as? [String: Any],
            let type = action["type"] as? String
        else {
            print("Invalid message shape:", message.body)
            return
        }

        switch type {
        case "startCapture":
            if capture == nil { capture = MinimalScreenCapture() }
            Task { @MainActor in
                do { try await capture?.start() } catch { print("start error:", error) }
            }

        case "stopCapture":
            capture?.stop()
            capture = nil

        default:
            print("Unknown action:", type)
        }
    }
}

struct WebViewControllerRepresentable: NSViewControllerRepresentable {
    let url: URL
    func makeNSViewController(context: Context) -> WebViewController { WebViewController() }
    func updateNSViewController(_ vc: WebViewController, context: Context) { vc.load(url) }
}

@main
struct deepApp: App {
    var body: some Scene {
        WindowGroup { WebViewControllerRepresentable(url: webClientUrl) }
    }
}
