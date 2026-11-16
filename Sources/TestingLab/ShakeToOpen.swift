#if DEBUG && os(iOS)
import UIKit

/// Shaking the device, or Device ▸ Shake in the simulator, opens the Testing Lab.
extension UIWindow {
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: .openTestingLab, object: nil)
        }
        super.motionEnded(motion, with: event)
    }
}
#endif
