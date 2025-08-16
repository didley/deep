import SwiftUI
import WebKit

let WEB_CLIENT_URL = "https://google.com"

let webClientUrl = URL(string: WEB_CLIENT_URL)!

struct WebView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.load(URLRequest(url: url))
    }
}

@main
struct deepApp: App {
    var body: some Scene {
        WindowGroup {
            WebView(url: webClientUrl)
        }
    }
}

#Preview {
    WebView(url: webClientUrl)
}
