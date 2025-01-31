/* Copyright Airship and Contributors */

#import "UAScheduleAction.h"
#import "UAActionSchedule.h"
#import "UAAirshipAutomationCoreImport.h"
#import "UAInAppAutomation+Internal.h"
#import "NSDictionary+UAAdditions+Internal.h"

#if __has_include("AirshipKit/AirshipKit-Swift.h")
#import <AirshipKit/AirshipKit-Swift.h>
#elif __has_include("AirshipKit-Swift.h")
#import "AirshipKit-Swift.h"
#else
@import AirshipCore;
#endif

@implementation UAScheduleAction

NSString * const UAScheduleActionDefaultRegistryName = @"schedule_actions";
NSString * const UAScheduleActionDefaultRegistryAlias = @"^sa";

static NSString *const UAScheduleInfoPriorityKey = @"priority";
static NSString *const UAScheduleInfoLimitKey = @"limit";
static NSString *const UAScheduleInfoGroupKey = @"group";
static NSString *const UAScheduleInfoEndKey = @"end";
static NSString *const UAScheduleInfoStartKey = @"start";
static NSString *const UAScheduleInfoTriggersKey = @"triggers";
static NSString *const UAScheduleInfoDelayKey = @"delay";
static NSString *const UAScheduleInfoIntervalKey = @"interval";
static NSString *const UAScheduleInfoActionsKey = @"actions";

static NSString * const UAScheduleActionErrorDomain = @"com.urbanairship.schedule_action";


- (BOOL (^)(id _Nullable, NSInteger))defaultPredicate {
    return nil;
}

- (NSArray<NSString *> *)defaultNames {
    return @[UAScheduleActionDefaultRegistryName, UAScheduleActionDefaultRegistryAlias];
}


- (BOOL)acceptsArgumentValue:(nullable id)arguments situation:(NSInteger)situation {
    switch (situation) {
        case UAActionSituationManualInvocation:
        case UAActionSituationWebViewInvocation:
        case UAActionSituationBackgroundPush:
        case UAActionSituationForegroundPush:
        case UAActionSituationAutomation:
            return [arguments isKindOfClass:[NSDictionary class]];
    }
    return NO;
}

- (void)performWithArgumentValue:(nullable id)argument
                       situation:(NSInteger)situation
                    pushUserInfo:(nullable NSDictionary *)pushUserInfo
               completionHandler:(nonnull void (^)(void))completionHandler {

    NSError *error = nil;

    UASchedule *schedule =[self parseSchedule:argument error:&error];

    if (!schedule) {
        UA_LERR(@"Unable to schedule actions. Invalid schedule payload: %@", schedule);
        completionHandler();
        return;
    }

    [[UAInAppAutomation shared] schedule:schedule completionHandler:^(BOOL result) {
        completionHandler();
    }];
}


- (UASchedule *)parseSchedule:(id)json error:(NSError **)error {
    id actions = [json dictionaryForKey:UAScheduleInfoActionsKey defaultValue:nil];
    if (![actions isKindOfClass:[NSDictionary class]]) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"Actions payload must be a dictionary. Invalid value: %@", actions];
            *error =  [NSError errorWithDomain:UAScheduleActionErrorDomain
                                          code:UAScheduleActionErrorCodeInvalidJSON
                                      userInfo:@{NSLocalizedDescriptionKey:msg}];
        }
        return nil;
    }


    // Triggers
    NSMutableArray *triggers = [NSMutableArray array];
    for (id triggerJSON in [json arrayForKey:UAScheduleInfoTriggersKey defaultValue:nil]) {
        NSError *triggerError;
        UAScheduleTrigger *trigger = [UAScheduleTrigger triggerWithJSON:triggerJSON error:&triggerError];
        if (triggerError || !trigger) {
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"Invalid trigger: %@", triggerError];
                *error =  [NSError errorWithDomain:UAScheduleActionErrorDomain
                                              code:UAScheduleActionErrorCodeInvalidJSON
                                          userInfo:@{NSLocalizedDescriptionKey:msg}];
            }
            return nil;
        }
        [triggers addObject:trigger];
    }

    // Delay
    UAScheduleDelay *delay = nil;
    if (json[UAScheduleInfoDelayKey]) {
        NSError *delayError;
        UAScheduleDelay *delay = [UAScheduleDelay delayWithJSON:json[UAScheduleInfoDelayKey] error:&delayError];
        if (delayError || !delay) {
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"Invalid trigger: %@", delayError];
                *error =  [NSError errorWithDomain:UAScheduleActionErrorDomain
                                              code:UAScheduleActionErrorCodeInvalidJSON
                                          userInfo:@{NSLocalizedDescriptionKey:msg}];
            }
            return nil;
        }
    }

    return [UAActionSchedule scheduleWithActions:actions
                                    builderBlock:^(UAScheduleBuilder *builder) {
        builder.triggers = triggers;
        builder.delay = delay;
        builder.group = [json stringForKey:UAScheduleInfoGroupKey defaultValue:nil];
        builder.limit = [[json numberForKey:UAScheduleInfoLimitKey defaultValue:@(1)] unsignedIntegerValue];
        builder.priority = [[json numberForKey:UAScheduleInfoPriorityKey defaultValue:nil] integerValue];
        builder.interval = [[json numberForKey:UAScheduleInfoIntervalKey defaultValue:nil] doubleValue];

        if (json[UAScheduleInfoStartKey]) {
            builder.start = [UAUtils parseISO8601DateFromString:[json stringForKey:UAScheduleInfoStartKey defaultValue:@""]];
        }

        if (json[UAScheduleInfoEndKey]) {
            builder.end = [UAUtils parseISO8601DateFromString:[json stringForKey:UAScheduleInfoEndKey defaultValue:@""]];
        }
    }];
}

@end

