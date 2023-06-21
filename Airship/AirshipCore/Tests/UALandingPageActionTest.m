/* Copyright Airship and Contributors */

#import "UABaseTest.h"
#import "UALandingPageAction.h"
#import "UAInAppAutomation.h"
#import "UAInAppMessageHTMLDisplayContent+Internal.h"
#import "UASchedule+Internal.h"
#import "AirshipTests-Swift.h"

@import AirshipCore;

@interface UALandingPageActionTest : UABaseTest

@property (nonatomic, strong) UATestAirshipInstance *airship;
@property (nonatomic, strong) id mockConfig;
@property (nonatomic, strong) UALandingPageAction *action;
@property (nonatomic, strong) UATestURLAllowList *URLAllowList;
@property (nonatomic, strong) id mockInAppAutomation;
@end


@implementation UALandingPageActionTest

- (void)setUp {
    [super setUp];
    self.action = [[UALandingPageAction alloc] init];

    self.mockConfig = [self mockForClass:[UARuntimeConfig class]];
    self.URLAllowList = [[UATestURLAllowList alloc] init];

    [[[self.mockConfig stub] andReturn:@"app-key"] appKey];
    [[[self.mockConfig stub] andReturn:@"app-secret"] appSecret];

    self.mockInAppAutomation = [self mockForClass:[UAInAppAutomation class]];
    [[[self.mockInAppAutomation stub] andReturn:self.mockInAppAutomation] shared];

    self.airship = [[UATestAirshipInstance alloc] init];
    self.airship.components = @[self.mockInAppAutomation];
    self.airship.config = self.mockConfig;
    self.airship.urlAllowList = self.URLAllowList;
    [self.airship makeShared];
}

/**
 * Test accepts arguments
 */
- (void)testAcceptsArguments {
    self.URLAllowList.isAllowedReturnValue = YES;

    [self verifyAcceptsArgumentsWithValue:@"foo.urbanairship.com" shouldAccept:YES];
    [self verifyAcceptsArgumentsWithValue:@"https://foo.urbanairship.com" shouldAccept:YES];
    [self verifyAcceptsArgumentsWithValue:@"http://foo.urbanairship.com" shouldAccept:YES];
    [self verifyAcceptsArgumentsWithValue:@"file://foo.urbanairship.com" shouldAccept:YES];
    [self verifyAcceptsArgumentsWithValue:[NSURL URLWithString:@"https://foo.urbanairship.com"] shouldAccept:YES];
}

/**
 * Test accepts arguments rejects argument values that are unable to parsed
 * as a URL
 */
- (void)testAcceptsArgumentsNo {
    self.URLAllowList.isAllowedReturnValue = YES;

    [self verifyAcceptsArgumentsWithValue:nil shouldAccept:NO];
    [self verifyAcceptsArgumentsWithValue:[[NSObject alloc] init] shouldAccept:NO];
    [self verifyAcceptsArgumentsWithValue:@[] shouldAccept:NO];
}

/**
 * Test rejects arguments with URLs that are not allowed.
 */
- (void)testURLAllowList {
    self.URLAllowList.isAllowedReturnValue = NO;

    [self verifyAcceptsArgumentsWithValue:@"foo.urbanairship.com" shouldAccept:NO];
    [self verifyAcceptsArgumentsWithValue:@"https://foo.urbanairship.com" shouldAccept:NO];
    [self verifyAcceptsArgumentsWithValue:@"http://foo.urbanairship.com" shouldAccept:NO];
    [self verifyAcceptsArgumentsWithValue:@"file://foo.urbanairship.com" shouldAccept:NO];
    [self verifyAcceptsArgumentsWithValue:[NSURL URLWithString:@"https://foo.urbanairship.com"] shouldAccept:NO];
}

/**
 * Test perform in foreground situations
 */
- (void)testPerformInForeground {
    self.URLAllowList.isAllowedReturnValue = YES;

    NSString *urlString = @"www.airship.com";
    // Expected URL String should be message ID with prepended message scheme.
    NSString *expectedURLString = [NSString stringWithFormat:@"%@%@", @"https://", urlString];
    [self verifyPerformWithArgValue:urlString expectedURLString:expectedURLString];
}

/**
 * Test perform with a message ID thats available in the message list is displayed
 * in a landing page controller.
 */
- (void)verifyPerformWithArgValue:(id)value expectedURLString:(NSString *)expectedURLString {
    __block BOOL actionPerformed;

    UAActionSituation validSituations[6] = {
        UAActionSituationForegroundInteractiveButton,
        UAActionSituationLaunchedFromPush,
        UAActionSituationManualInvocation,
        UAActionSituationWebViewInvocation,
        UAActionSituationForegroundPush,
        UAActionSituationAutomation
    };

    for (int i = 0; i < 6; i++) {

        [[[self.mockInAppAutomation expect] andDo:^(NSInvocation *invocation) {
            void *scheduleArg;
            [invocation getArgument:&scheduleArg atIndex:2];
            UASchedule *schedule = (__bridge UASchedule *)scheduleArg;
            UAInAppMessage *message = schedule.data;

            XCTAssertEqual(message.displayType, UAInAppMessageDisplayTypeHTML);
            XCTAssertEqualObjects(message.displayBehavior, UAInAppMessageDisplayBehaviorImmediate);
            XCTAssertEqual(message.isReportingEnabled, NO);

            UAInAppMessageHTMLDisplayContent *displayContent = (UAInAppMessageHTMLDisplayContent *)message.displayContent;
            XCTAssertEqual(displayContent.requireConnectivity, NO);
            XCTAssertEqualObjects(displayContent.url, expectedURLString);

            void *handlerArg;
            [invocation getArgument:&handlerArg atIndex:3];
            void (^handler)(UASchedule *) = (__bridge void (^)(UASchedule *))handlerArg;
            handler(nil);

        }] schedule:OCMOCK_ANY completionHandler:OCMOCK_ANY];

        [self.action performWithArgumentValue:value situation:validSituations[i] pushUserInfo:nil completionHandler:^{
            actionPerformed = YES;
        }];

        XCTAssertTrue(actionPerformed);
        [self.mockInAppAutomation verify];
    }
}

/**
 * Helper method to verify accepts arguments
 */
- (void)verifyAcceptsArgumentsWithValue:(id)value shouldAccept:(BOOL)shouldAccept {
    NSArray *situations = @[[NSNumber numberWithInteger:UAActionSituationWebViewInvocation],
                                     [NSNumber numberWithInteger:UAActionSituationForegroundPush],
                                     [NSNumber numberWithInteger:UAActionSituationLaunchedFromPush],
                                     [NSNumber numberWithInteger:UAActionSituationManualInvocation]];

    for (NSNumber *situationNumber in situations) {
        BOOL accepts = [self.action acceptsArgumentValue:value situation:situationNumber.intValue];
        if (shouldAccept) {
            XCTAssertTrue(accepts, @"landing page action should accept value %@ in situation %@", value, situationNumber);
        } else {
            XCTAssertFalse(accepts, @"landing page action should not accept value %@ in situation %@", value, situationNumber);
        }
    }
}

@end
