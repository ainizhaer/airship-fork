/* Copyright Airship and Contributors */

import Foundation

/// Protocol to be implemented by deep link handlers.
@objc(UADeepLinkDelegate)
public protocol DeepLinkDelegate {

    /// Called when a deep link has been triggered from Airship. If implemented, the delegate is responsible for processing the provided url.
    /// - Parameters:
    ///     - deepLink: The deep link.
    func receivedDeepLink(_ deepLink: URL) async
}
