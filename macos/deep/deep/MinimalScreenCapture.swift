import Cocoa
import ScreenCaptureKit
import AVFoundation

final class MinimalScreenCapture: NSObject, SCStreamOutput {
    private var stream: SCStream?
    private let queue = DispatchQueue(label: "capture.drop.queue")

    // Start a tiny, low-FPS capture that we immediately drop
    @MainActor
    func start() async throws {
        // 1) Pick a display (main display here). Using the system share picker is optional (see note below).
        let shareable = try await SCShareableContent.current
        guard let display = shareable.displays.first else { throw NSError(domain: "MinimalScreenCapture", code: 1) }

        // 2) Filter: capture from that display (no windows excluded/excepted)
        let filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])

        // 3) Config: 1×1 px ROI, very low frame rate, no cursor, no audio
        let cfg = SCStreamConfiguration()
        cfg.width  = 1
        cfg.height = 1
        cfg.showsCursor = false
        cfg.capturesAudio = false
        cfg.minimumFrameInterval = CMTimeMake(value: 1, timescale: 2) // ~2 fps to minimize work

        // 4) Build stream
        let stream = SCStream(filter: filter, configuration: cfg, delegate: nil)
        self.stream = stream

        // 5) Add a sink that discards frames
        try stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: queue)

        // 6) Go
        try await stream.startCapture()
        // From this point, macOS considers the system "sharing/presenting" and will block notifications
        // if the user has "Allow notifications when mirroring or sharing the display" turned OFF.
    }

    // Stop & clean up
    func stop() {
        guard let stream else { return }
        Task { @MainActor in
            try? await stream.stopCapture()
            try? stream.removeStreamOutput(self, type: .screen)
            self.stream = nil
        }
    }

    // SCStreamOutput: drop everything
    func stream(_ stream: SCStream, didOutputSampleBuffer sbuf: CMSampleBuffer, of type: SCStreamOutputType) {
        // Intentionally no-op to minimize CPU/GPU usage.
        // (You can also early-return without touching the buffer.)
    }

    func stream(_ stream: SCStream, didStopWithError error: Error) {
        // Optional: handle errors
        print("SCStream stopped with error: \(error)")
    }
}
