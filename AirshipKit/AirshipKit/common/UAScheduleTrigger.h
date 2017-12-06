/* Copyright 2017 Urban Airship and Contributors */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 * Represents the possible error conditions when deserializing triggers from JSON.
 */
typedef NS_ENUM(NSInteger, UAScheduleTriggerErrorCode) {
    /**
     * Indicates an error with the trigger JSON definition.
     */
    UAScheduleTriggerErrorCodeInvalidJSON,
};

/**
 * The domain for NSErrors generated by `triggerWithJSON:error:`.
 */
extern NSString * const UAScheduleTriggerErrorDomain;

/**
 * Possible trigger types.
 */
typedef NS_ENUM(NSInteger, UAScheduleTriggerType) {

    /**
     * Foreground trigger.
     */
    UAScheduleTriggerAppForeground,

    /**
     * Background trigger.
     */
    UAScheduleTriggerAppBackground,

    /**
     * Region enter trigger.
     */
    UAScheduleTriggerRegionEnter,

    /**
     * Region exit trigger.
     */
    UAScheduleTriggerRegionExit,

    /**
     * Custom event count trigger.
     */
    UAScheduleTriggerCustomEventCount,

    /**
     * Custom event value trigger.
     */
    UAScheduleTriggerCustomEventValue,

    /**
     * Screen trigger.
     */
    UAScheduleTriggerScreen,

    /**
     * App init trigger.
     */
    UAScheduleTriggerAppInit,

    /**
     * Active session trigger.
     */
    UAScheduleTriggerActiveSession,

    /**
     * Version trigger.
     */
    UAScheduleTriggerVersion
};


/**
 * JSON key for the trigger's type. The type should be one of the type names.
 */
extern NSString *const UAScheduleTriggerTypeKey;

/**
 * JSON key for the trigger's predicate.
 */
extern NSString *const UAScheduleTriggerPredicateKey;

/**
 * JSON key for the trigger's goal.
 */
extern NSString *const UAScheduleTriggerGoalKey;

/**
 * App init trigger name when defining a trigger in JSON.
 */
extern NSString *const UAScheduleTriggerAppInitName;

/**
 * Foreground trigger name when defining a trigger in JSON.
 */
extern NSString *const UAScheduleTriggerAppForegroundName;

/**
 * Background trigger name when defining a trigger in JSON.
 */
extern NSString *const UAScheduleTriggerAppBackgroundName;

/**
 * Region enter trigger name when defining a trigger in JSON.
 */
extern NSString *const UAScheduleTriggerRegionEnterName;

/**
 * Region exit trigger name when defining a trigger in JSON.
 */
extern NSString *const UAScheduleTriggerRegionExitName;

/**
 * Custom event count trigger name when defining a trigger in JSON.
 */
extern NSString *const UAScheduleTriggerCustomEventCountName;

/**
 * Custom event value trigger name when defining a trigger in JSON.
 */
extern NSString *const UAScheduleTriggerCustomEventValueName;

/**
 * Screen trigger name when defining a trigger in JSON.
 */
extern NSString *const UAScheduleTriggerScreenName;

/**
 * Active session trigger name when defining a trigger in JSON.
 */
extern NSString *const UAScheduleTriggerActiveSessionName;

/**
 * Version trigger name when defining a trigger in JSON.
 */
extern NSString *const UAScheduleTriggerVersionName;

@class UAJSONPredicate;

/**
 * Trigger defines a condition to execute actions or cancel a delayed execution of actions.
 */
@interface UAScheduleTrigger: NSObject

///---------------------------------------------------------------------------------------
/// @name Schedule Trigger Properties
///---------------------------------------------------------------------------------------

/**
 * The trigger type.
 */
@property(nonatomic, readonly) UAScheduleTriggerType type;

/**
 * The trigger's goal. Once the goal is reached it will cause the schedule
 * to execute its actions.
 */
@property(nonatomic, readonly) NSNumber *goal;

///---------------------------------------------------------------------------------------
/// @name Schedule Trigger Factories
///---------------------------------------------------------------------------------------

/**
 * Factory method to create an app init trigger.
 *
 * @param count Number of foregrounds before firing the trigger.
 * @return An app init trigger.
 */
+ (instancetype)appInitTriggerWithCount:(NSUInteger)count;

/**
 * Factory method to create a foreground trigger.
 *
 * @param count Number of foregrounds before firing the trigger.
 * @return A foreground trigger.
 */
+ (instancetype)foregroundTriggerWithCount:(NSUInteger)count;

/**
 * Factory method to create a background trigger.
 *
 * @param count Number of backgrounds before firing the trigger.
 * @return A background trigger.
 */
+ (instancetype)backgroundTriggerWithCount:(NSUInteger)count;

/**
 * Factory method to create an active session trigger.
 *
 * @param count Number of active sessions before firing the trigger.
 * @return An active session trigger.
 */
+ (instancetype)activeSessionTriggerWithCount:(NSUInteger)count;

/**
 * Factory method to create a region enter trigger.
 *
 * @param regionID Source ID of the region.
 * @param count Number of region enters before firing the trigger.
 * @return A region enter trigger.
 */
+ (instancetype)regionEnterTriggerForRegionID:(NSString *)regionID
                                        count:(NSUInteger)count;

/**
 * Factory method to create a region exit trigger.
 *
 * @param regionID Source ID of the region.
 * @param count Number of region exits before firing the trigger.
 * @return A region exit trigger.
 */
+ (instancetype)regionExitTriggerForRegionID:(NSString *)regionID
                                       count:(NSUInteger)count;

/**
 * Factory method to create a screen trigger.
 *
 * @param screenName Name of the screen.
 * @param count Number of screen enters before firing the trigger.
 * @return A screen trigger.
 */
+ (instancetype)screenTriggerForScreenName:(NSString *)screenName
                                     count:(NSUInteger)count;

/**
 * Factory method to create a custom event count trigger.
 *
 * @param predicate Custom event predicate to filter out events that are applied
 * to the trigger's count.
 * @param count Number of custom event counts before firing the trigger.
 * @return A custom event count trigger.
 */
+ (instancetype)customEventTriggerWithPredicate:(UAJSONPredicate *)predicate
                                          count:(NSUInteger)count;

/**
 * Factory method to create a custom event value trigger.
 *
 * @param predicate Custom event predicate to filter out events that are applied
 * to the trigger's value.
 * @param value Aggregate custom event value before firing the trigger.
 * @return A custom event value trigger.
 */
+ (instancetype)customEventTriggerWithPredicate:(UAJSONPredicate *)predicate
                                          value:(NSNumber *)value;

/**
 * Factory method to create a version trigger.
 *
 * @param predicate JSON predicate to match against the app version.
 * @param count The number of updates to match before firing the trigger.
 * @return A version trigger.
 */
+ (instancetype)versionTriggerWithPredicate:(UAJSONPredicate *)predicate count:(NSUInteger)count;


/**
 * Factory method to create a trigger from a JSON payload.
 *
 * @param json The JSON payload.
 * @param error An NSError pointer for storing errors, if applicable.
 * @return A trigger or `nil` if the JSON is invalid.
 */
+ (nullable instancetype)triggerWithJSON:(id)json error:(NSError * _Nullable *)error;

///---------------------------------------------------------------------------------------
/// @name Schedule Trigger Evaluation
///---------------------------------------------------------------------------------------

/**
 * Checks if the trigger is equal to another trigger.
 *
 * @param trigger The other trigger info to compare against.
 * @return `YES` if the triggers are equal, otherwise `NO`.
 */
- (BOOL)isEqualToTrigger:(nullable UAScheduleTrigger *)trigger;

@end

NS_ASSUME_NONNULL_END

