import SwiftUI
import WebKit
import ScreenCaptureKit

let WEB_CLIENT_URL = "http://localhost:5173/"
let webClientUrl = URL(string: WEB_CLIENT_URL)!

@main
struct deepApp: App {
    var body: some Scene {
        WindowGroup { WebViewControllerRepresentable(url: webClientUrl) }
    }
}

struct WebViewControllerRepresentable: NSViewControllerRepresentable {
    let url: URL
    func makeNSViewController(context: Context) -> WebViewController { WebViewController() }
    func updateNSViewController(_ vc: WebViewController, context: Context) { vc.load(url) }
}

final class WebViewController: NSViewController, WKNavigationDelegate {
    fileprivate var webView: WKWebView!
    fileprivate var capture: MinimalScreenCapture?

    override func loadView() {
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        contentController.addScriptMessageHandler(BridgeWithReply(self), contentWorld: .page, name: "native")
    
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        view = webView
    }

    deinit {
        webView?.configuration.userContentController.removeAllScriptMessageHandlers()
    }

    func load(_ url: URL) {
        webView.load(URLRequest(url: url))
    }

    fileprivate func perform(method: String, args: [String: Any]) async throws -> Any {
        switch method {
        case "capture.start":
            if capture == nil { capture = MinimalScreenCapture() }
            do {
                try await capture?.start()
                return ["ok": true]
            } catch {
                throw NSError(domain: "capture.start", code: 1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
            }

        case "capture.stop":
            capture?.stop()
            capture = nil
            return ["ok": true]

        case "capture.hasPermission":
            let allowed = MinimalScreenCapture.hasPermission()
            return ["allowed": allowed]

        default:
            throw NSError(domain: "native.bridge", code: 404, userInfo: [NSLocalizedDescriptionKey: "Unknown method: \(method)"])
        }
    }
}

@available(macOS 11.0, *)
private final class BridgeWithReply: NSObject, WKScriptMessageHandlerWithReply {
    weak var owner: WebViewController?
    init(_ owner: WebViewController) { self.owner = owner }

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage,
                               replyHandler: @escaping (Any?, String?) -> Void) {
        guard message.name == "native" else { replyHandler(nil, "bad_handler"); return }

        // Accept both {method,args} and the user's original {type, ...}
        let body = message.body as? [String: Any] ?? [:]
        let method = (body["method"] as? String) ?? (body["type"] as? String)
        let args = (body["args"] as? [String: Any]) ?? [:]

        guard let method = method else {
            replyHandler(nil, "invalid_payload")
            return
        }

        Task {
            do {
                guard let owner = self.owner else { replyHandler(nil, "deallocated"); return }
                let value = try await owner.perform(method: method, args: args)
                replyHandler(value, nil) // resolves JS Promise
            } catch {
                replyHandler(nil, error.localizedDescription) // rejects JS Promise
            }
        }
    }
}

