import SwiftUI
import WebKit
import AVFoundation
import UIKit

private let fondo = UIColor(red: 13/255, green: 20/255, blue: 25/255, alpha: 1)

@main
struct VorticeAureoApp: App {
    init() {
        // .playback: la música y los tonos suenan aunque el interruptor de silencio esté activado.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    var body: some Scene {
        WindowGroup {
            BreathWebView()
                .ignoresSafeArea()
                .background(Color(fondo))
                .preferredColorScheme(.dark)
                .statusBarHidden(false)
                .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        }
    }
}

/// WKWebView que carga la app web empaquetada en el bundle (carpeta `web/`). Sin red.
struct BreathWebView: UIViewRepresentable {
    func makeCoordinator() -> NativeBridge { NativeBridge() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let content = WKUserContentController()
        content.add(context.coordinator, name: "native")
        // Misma interfaz que la versión Android (speak / vibrate), pero hacia Swift.
        let js = """
        window.NativeBridge = {
          speak: function (t) { window.webkit.messageHandlers.native.postMessage({ type: 'speak', text: String(t) }); },
          vibrate: function (p) { window.webkit.messageHandlers.native.postMessage({ type: 'vibrate', pattern: String(p) }); }
        };
        """
        content.addUserScript(WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        config.userContentController = content

        let web = WKWebView(frame: .zero, configuration: config)
        web.isOpaque = false
        web.backgroundColor = fondo
        web.scrollView.backgroundColor = fondo
        web.scrollView.contentInsetAdjustmentBehavior = .never
        web.scrollView.bounces = false
        web.allowsLinkPreview = false

        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "web") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

/// Recibe mensajes de JavaScript: voz guía (AVSpeechSynthesizer, es-MX) y háptica.
final class NativeBridge: NSObject, WKScriptMessageHandler {
    private let synth = AVSpeechSynthesizer()
    private let soft = UIImpactFeedbackGenerator(style: .soft)
    private let firm = UIImpactFeedbackGenerator(style: .medium)

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any],
              let type = body["type"] as? String else { return }

        switch type {
        case "speak":
            guard let text = body["text"] as? String, !text.isEmpty else { return }
            synth.stopSpeaking(at: .immediate)
            let u = AVSpeechUtterance(string: text)
            u.voice = AVSpeechSynthesisVoice(language: "es-MX") ?? AVSpeechSynthesisVoice(language: "es-ES")
            u.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
            synth.speak(u)

        case "vibrate":
            // Patrón estilo navigator.vibrate: [vibra, pausa, vibra, ...] en milisegundos.
            let raw = (body["pattern"] as? String ?? "[]").data(using: .utf8) ?? Data()
            let pattern = ((try? JSONSerialization.jsonObject(with: raw)) as? [NSNumber] ?? []).map { $0.doubleValue }
            var delay = 0.0
            for (i, ms) in pattern.enumerated() {
                if i % 2 == 0 {
                    let gen = ms >= 150 ? firm : soft
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay / 1000) { gen.impactOccurred() }
                }
                delay += ms
            }

        default:
            break
        }
    }
}
