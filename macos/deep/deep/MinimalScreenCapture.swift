import ScreenCaptureKit

final class MinimalScreenCapture: NSObject, SCStreamOutput {
    // Strong refs
    private var stream: SCStream?
    private var filter: SCContentFilter?
    private var config: SCStreamConfiguration?
    private let queue = DispatchQueue(label: "capture.drop.queue")
    
    static func hasPermission() -> Bool {
        CGPreflightScreenCaptureAccess()
    }
    
    @MainActor
    func start() async throws {
        // Pick first display
        let shareable = try await SCShareableContent.current
        guard let display = shareable.displays.first else {
            throw NSError(domain: "MinimalScreenCapture", code: 1, userInfo: [NSLocalizedDescriptionKey: "No display"])
        }

        // Filter & config (tiny region, ultra-low fps)
        let filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
        self.filter = filter

        let cfg = SCStreamConfiguration()
        cfg.width = 2
        cfg.height = 2
        cfg.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1) // 1×1 crop
        cfg.showsCursor = false
        cfg.capturesAudio = false
        cfg.queueDepth = 1
        cfg.minimumFrameInterval = CMTime(seconds: 3600, preferredTimescale: 600) // 1 frame/hour
        self.config = cfg

        let stream = SCStream(filter: filter, configuration: cfg, delegate: nil)
        self.stream = stream

        try stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: queue)
        try await stream.startCapture() // triggers "Presenting" state
        fputs("Started minimal capture (Presenting).", stderr)
    }

    func stop() {
        guard let stream else { return }
        Task { @MainActor in
            try? await stream.stopCapture()
            try? stream.removeStreamOutput(self, type: .screen)
            self.stream = nil
            self.filter = nil
            self.config = nil
            fputs("Stopped minimal capture (Presenting).\n", stderr)
        }
    }
    
    // Drop all frames
    func stream(_ stream: SCStream, didOutputSampleBuffer sbuf: CMSampleBuffer, of type: SCStreamOutputType) { /* no-op */ }
    func stream(_ stream: SCStream, didStopWithError error: Error) {
        fputs("SCStream stopped with error: \(error)\n", stderr)
    }
}
