/* Copyright Airship and Contributors */

import Foundation

@testable import AirshipCore

@objc(UATestAirshipInstance)
public class TestAirshipInstance: NSObject, AirshipInstanceProtocol {

    private var _config: RuntimeConfig?
    @objc
    public var config: RuntimeConfig {
        get {
            return _config!
        }
        set {
            _config = newValue
        }
    }

    @objc
    public var permissionsManager: AirshipPermissionsManager = AirshipPermissionsManager()

    private var _actionRegistry: ActionRegistry?
    public var actionRegistry: ActionRegistry {
        get {
            return _actionRegistry!
        }
        set {
            _actionRegistry = newValue
        }
    }

    private var _applicationMetrics: ApplicationMetrics?
    @objc
    public var applicationMetrics: ApplicationMetrics {
        get {
            return _applicationMetrics!
        }
        set {
            _applicationMetrics = newValue
        }
    }

    private var _channelCapture: ChannelCapture?
    @objc
    public var channelCapture: ChannelCapture {
        get {
            return _channelCapture!
        }
        set {
            _channelCapture = newValue
        }
    }

    private var _urlAllowList: URLAllowList?
    @objc
    public var urlAllowList: URLAllowList {
        get {
            return _urlAllowList!
        }
        set {
            _urlAllowList = newValue
        }
    }

    private var _localeManager: AirshipLocaleManager?
    @objc
    public var localeManager: AirshipLocaleManager {
        get {
            return _localeManager!
        }
        set {
            _localeManager = newValue
        }
    }

    private var _privacyManager: AirshipPrivacyManager?
    @objc
    public var privacyManager: AirshipPrivacyManager {
        get {
            return _privacyManager!
        }
        set {
            _privacyManager = newValue
        }
    }

    @objc
    public var javaScriptCommandDelegate: JavaScriptCommandDelegate?

    @objc
    public var deepLinkDelegate: DeepLinkDelegate?

    @objc
    public var components: [AirshipComponent] = []

    private var componentMap: [String: AirshipComponent] = [:]

    public func component(forClassName className: String) -> AirshipComponent? {
        let key = "Class:\(className)"
        if componentMap[key] == nil {
            self.componentMap[key] = self.components.first {
                NSStringFromClass(type(of: $0)) == className
            }
        }

        return componentMap[key]
    }

    public func component<E>(ofType componentType: E.Type) -> E? {
        let key = "Type:\(componentType)"
        if componentMap[key] == nil {
            self.componentMap[key] = self.components.first { ($0 as? E) != nil }
        }

        return componentMap[key] as? E
    }

    @objc
    public func makeShared() {
        Airship._shared = Airship(instance: self)
    }

    @objc
    public class func clearShared() {
        Airship._shared = nil
    }
}
