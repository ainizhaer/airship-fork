/* Copyright Airship and Contributors */

import XCTest

@testable
import AirshipCore

class EventTest: XCTestCase {
    
    func testAppInitEvent() throws {
        let testAnalytics = TestAnalytics()
        testAnalytics.conversionSendID = "push ID"
        testAnalytics.conversionPushMetadata = "base64metadataString"
    
        let event = AppInitEvent.init(analytics: testAnalytics, push: { return EventTestPush() })
    
        let data = event.gatherData()
        
        XCTAssertEqual(event.eventType, "app_init")
        XCTAssertEqual(data["connection_type"] as! String, "wifi")
        XCTAssertEqual(data["push_id"] as! String, "push ID")
        XCTAssertEqual(data["metadata"] as! String, "base64metadataString")
        XCTAssertEqual(data["time_zone"] as! NSNumber, NSNumber(value: Double(NSTimeZone.default.secondsFromGMT())))
        let daylightSavings = NSTimeZone.default as NSTimeZone
        XCTAssertEqual(data["daylight_savings"] as! String, daylightSavings.isDaylightSavingTime ? "true" : "false")
        XCTAssertEqual(data["os_version"] as! String, UIDevice.current.systemVersion)
        XCTAssertEqual(data["lib_version"] as! String, AirshipVersion.get())
        XCTAssertEqual(data["foreground"] as! String, "true")
    }
   
    func testForegroundEvent() throws {
        let testAnalytics = TestAnalytics()
        testAnalytics.conversionSendID = "push ID"
        testAnalytics.conversionPushMetadata = "base64metadataString"
    
        let event = AppForegroundEvent.init(analytics: testAnalytics, push: { return EventTestPush() })
    
        let data = event.gatherData()
        
        XCTAssertEqual(event.eventType, "app_foreground")
        XCTAssertEqual(data["connection_type"] as! String, "wifi")
        XCTAssertEqual(data["push_id"] as! String, "push ID")
        XCTAssertEqual(data["metadata"] as! String, "base64metadataString")
        XCTAssertEqual(data["time_zone"] as! NSNumber, NSNumber(value: Double(NSTimeZone.default.secondsFromGMT())))
        let daylightSavings = NSTimeZone.default as NSTimeZone
        XCTAssertEqual(data["daylight_savings"] as! String, daylightSavings.isDaylightSavingTime ? "true" : "false")
        XCTAssertEqual(data["notification_types"] as! Array <String>, [])
        XCTAssertEqual(data["notification_authorization"] as! String, "not_determined")
        XCTAssertEqual(data["os_version"] as! String, UIDevice.current.systemVersion)
        XCTAssertEqual(data["lib_version"] as! String, AirshipVersion.get())
    }
    
    func testAppExitEvent() throws {
        let testAnalytics = TestAnalytics()
        testAnalytics.conversionSendID = "push ID"
        testAnalytics.conversionPushMetadata = "base64metadataString"
    
        let event = AppExitEvent.init(analytics: testAnalytics)
    
        let data = event.gatherData()
        
        XCTAssertEqual(event.eventType, "app_exit")
        XCTAssertEqual(data["connection_type"] as! String, "wifi")
        XCTAssertEqual(data["push_id"] as! String, "push ID")
        XCTAssertEqual(data["metadata"] as! String, "base64metadataString")
    }
     

    func testAppBackgroundEvent() throws {
        let testAnalytics = TestAnalytics()
        testAnalytics.conversionSendID = "push ID"
        testAnalytics.conversionPushMetadata = "base64metadataString"
    
        let event = AppBackgroundEvent.init(analytics: testAnalytics)
        
        XCTAssertEqual(event.eventType, "app_background")
    }
    
    func testDeviceRegistrationEvent() throws {
        
        let testChannel = TestChannel()
        testChannel.identifier = "someChannelID"
        let testPush = InternalPush()
        
        let dataStore = PreferenceDataStore(appKey: UUID().uuidString)
        let privacyManager = PrivacyManager(dataStore: dataStore, defaultEnabledFeatures: .all)
      
        let event = DeviceRegistrationEvent.init(channel: testChannel, push: testPush, privacyManager: privacyManager)
        
        XCTAssertEqual(event.data["device_token"] as! String, "a12312ad")
        XCTAssertEqual(event.data["channel_id"] as! String, "someChannelID")
        XCTAssertEqual(event.eventType, "device_registration")
     }
    
    func testDeviceRegistrationEventWhenPushIsDisabled() throws {
        
        let testChannel = TestChannel()
        testChannel.identifier = "someChannelID"
        let testPush = InternalPush()
        
        let dataStore = PreferenceDataStore(appKey: UUID().uuidString)
        let privacyManager = PrivacyManager(dataStore: dataStore, defaultEnabledFeatures: .all)
        privacyManager.disableFeatures(.push)
      
        let event = DeviceRegistrationEvent.init(channel: testChannel, push: testPush, privacyManager: privacyManager)
        
        XCTAssertNil(event.data["device_token"])
        XCTAssertEqual(event.data["channel_id"] as! String, "someChannelID")
        XCTAssertEqual(event.eventType, "device_registration")
     }
   
    func testPushReceived() throws {
        let notification: [AnyHashable : Any] = ["_":"push ID",
                                                 "_uamid":"rich push ID",
                                                 "com.urbanairship.metadata":"base64metadataString"]
        
        let event = PushReceivedEvent.init(notification: notification)
        
        XCTAssertEqual(event.data["push_id"] as! String, "push ID")
        XCTAssertEqual(event.data["metadata"] as! String, "base64metadataString")
        XCTAssertEqual(event.eventType, "push_received")
     }
    
    func testPushReceivedNoPushID() throws {
        let notification: [AnyHashable : Any] = ["_uamid":"rich push ID"]
        
        let event = PushReceivedEvent.init(notification: notification)
        
        XCTAssertEqual(event.data["push_id"] as! String, "MISSING_SEND_ID")
        XCTAssertEqual(event.eventType, "push_received")
     }
    
    func testScreenTracking() throws {
        let event = ScreenTrackingEvent.init(screen: "test_screen", previousScreen: "previous_screen", startTime: 0, stopTime: 1)
        
        XCTAssertEqual(event!.data["duration"] as! String, "1.000")
        XCTAssertEqual(event!.data["entered_time"] as! String, "0.000")
        XCTAssertEqual(event!.data["exited_time"] as! String, "1.000")
        XCTAssertEqual(event!.data["previous_screen"] as! String, "previous_screen")
        XCTAssertEqual(event!.data["screen"] as! String, "test_screen")
     }
    
    func testScreenValidation() throws {
        var screenName = "".padding(toLength: 255, withPad: "test_screen_name", startingAt: 0)
        var event = ScreenTrackingEvent.init(screen: screenName, previousScreen: nil, startTime: 0, stopTime: 1)
        
        XCTAssertEqual(event!.screen, screenName)
        
        screenName = "".padding(toLength: 256, withPad: "test_screen_name", startingAt: 0)
        event = ScreenTrackingEvent.init(screen: screenName, previousScreen: nil, startTime: 0, stopTime: 1)
        XCTAssertNil(event)
        
        screenName = ""
        event = ScreenTrackingEvent.init(screen: screenName, previousScreen: nil, startTime: 0, stopTime: 1)
        XCTAssertNil(event)
     }
    
    func testScreenStopTimeValidation() throws {
        var event = ScreenTrackingEvent.init(screen: "test_screen", previousScreen: nil, startTime: 0, stopTime: 0)
        XCTAssertNil(event)
        
        event = ScreenTrackingEvent.init(screen: "test_screen", previousScreen: nil, startTime: 1, stopTime: 0)
        XCTAssertNil(event)
        
        event = ScreenTrackingEvent.init(screen: "test_screen", previousScreen: nil, startTime: 0, stopTime: 1)
        XCTAssertNotNil(event)
     }
}

fileprivate class EventTestPush: PushProtocol {
    var deviceToken: String?
    
    var combinedCategories: Set<UNNotificationCategory> = []
    
    var backgroundPushNotificationsEnabled = true
    
    var userPushNotificationsEnabled = true
    
    var extendedPushNotificationPermissionEnabled = false

    var requestExplicitPermissionWhenEphemeral = false

    var notificationOptions: UANotificationOptions = [.alert, .sound, .badge]
    
    var customCategories: Set<UNNotificationCategory> = []
    
    var accengageCategories: Set<UNNotificationCategory> = []
    
    var requireAuthorizationForDefaultCategories = false
    
    var pushNotificationDelegate: PushNotificationDelegate?
    
    var registrationDelegate: RegistrationDelegate?
    
    var launchNotificationResponse: UNNotificationResponse?
    
    var authorizedNotificationSettings: UAAuthorizedNotificationSettings = []
    
    var authorizationStatus: UAAuthorizationStatus = .notDetermined
    
    var userPromptedForNotifications = false
    
    var defaultPresentationOptions: UNNotificationPresentationOptions = [.alert, .sound, .badge]
    
    var badgeNumber: Int = 0
}

fileprivate final class InternalPush: InternalPushProtocol {
    var deviceToken: String? = "a12312ad"
    
    func updateAuthorizedNotificationTypes() {}
    
    func didRegisterForRemoteNotifications(_ deviceToken: Data) {}
    
    func didFailToRegisterForRemoteNotifications(_ error: Error) {}
    
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable : Any], isForeground: Bool, completionHandler: @escaping (Any) -> Void) {}
    

    func presentationOptionsForNotification(_ notification: UNNotification, completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([])
    }
    
    func didReceiveNotificationResponse(_ response: UNNotificationResponse, completionHandler: @escaping () -> Void) {}
    
    var combinedCategories: Set<UNNotificationCategory> = Set()
}
