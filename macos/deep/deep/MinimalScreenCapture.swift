import ScreenCaptureKit
import AVFoundation

final class MinimalScreenCapture: NSObject, SCStreamOutput {
    // Strong refs
    private var stream: SCStream?
    private var filter: SCContentFilter?
    private var config: SCStreamConfiguration?
    private let queue = DispatchQueue(label: "capture.drop.queue")

    @MainActor
    func start() async throws {
        // Get a display
        let shareable = try await SCShareableContent.current
        guard let display = shareable.displays.first else {
            throw NSError(domain: "MinimalCapture", code: 1, userInfo: [NSLocalizedDescriptionKey: "No display"])
        }

        // Keep filter/config alive
        let filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
        self.filter = filter

        let cfg = SCStreamConfiguration()
        cfg.width = 1
        cfg.height = 1
        cfg.showsCursor = false
        cfg.capturesAudio = false
        cfg.minimumFrameInterval = CMTime(value: 1, timescale: 2) // ~2 fps
        cfg.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1) 
        self.config = cfg

        let stream = SCStream(filter: filter, configuration: cfg, delegate: nil)
        self.stream = stream

        try stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: queue)
        try await stream.startCapture() // triggers “presenting” state
    }

    func stop() {
        guard let stream else { return }
        Task { @MainActor in
            try? await stream.stopCapture()
            try? stream.removeStreamOutput(self, type: .screen)
            self.stream = nil
            self.filter = nil
            self.config = nil
        }
    }

    // Drop frames
    func stream(_ stream: SCStream, didOutputSampleBuffer sbuf: CMSampleBuffer, of type: SCStreamOutputType) { }
    func stream(_ stream: SCStream, didStopWithError error: Error) { print("SCStream stopped:", error) }
}
