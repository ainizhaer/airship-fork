/* Copyright Airship and Contributors */

#import "UAAirshipBaseTest.h"

@import AirshipCore;

@interface UAUtilsTest : UAAirshipBaseTest
@property(nonatomic, strong) NSCalendar *gregorianUTC;
@end

@implementation UAUtilsTest

- (void)setUp {
    [super setUp];
    self.gregorianUTC = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    self.gregorianUTC.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
}

- (void)testConnectionType {
    // SETUP
    NSArray *possibleConnectionTypes = @[@"cell", @"wifi", @"none"];

    // TEST
    NSString *connectionType = [UAUtils connectionType];
    
    // VERIFY
    XCTAssertTrue([possibleConnectionTypes containsObject:connectionType]);
}

- (void)testDeviceModelName {
    // TEST
    NSString *deviceModelName = [UAUtils deviceModelName];

    // VERIFY
    XCTAssertNotNil(deviceModelName);

    id validSimulatorModels = @[@"x86_64", @"arm64", @"mac"];
    XCTAssertTrue([validSimulatorModels containsObject:deviceModelName]);
}

- (NSDateComponents *)componentsForDate:(NSDate *)date {
    return [self.gregorianUTC components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
}

- (void)validateDateFormatter:(NSDateFormatter *)dateFormatter withFormatString:(NSString *)formatString {
    NSDate *date = [dateFormatter dateFromString:formatString];

    NSDateComponents *components = [self componentsForDate:date];
    XCTAssertEqual(components.year, 2020);
    XCTAssertEqual(components.month, 12);
    XCTAssertEqual(components.day, 15);
    XCTAssertEqual(components.hour, 11);
    XCTAssertEqual(components.minute, 45);
    XCTAssertEqual(components.second, 22);

    XCTAssertEqualObjects(formatString, [dateFormatter stringFromDate:date]);
}

- (void)testISODateFormatterUTC {
    [self validateDateFormatter:[UAUtils ISODateFormatterUTC] withFormatString:@"2020-12-15 11:45:22"];
}

- (void)testISODateFormatterUTCWithDelimiter {
    [self validateDateFormatter:[UAUtils ISODateFormatterUTCWithDelimiter] withFormatString:@"2020-12-15T11:45:22"];
}

- (void)testParseISO8601FromTimeStamp {
    // yyyy
    NSDate *date = [UAUtils parseISO8601DateFromString:@"2020"];
    NSDateComponents *components = [self componentsForDate:date];
    XCTAssertNotNil(components);
    XCTAssertEqual(components.year, 2020);
    XCTAssertEqual(components.month, 1);
    XCTAssertEqual(components.day, 1);
    XCTAssertEqual(components.hour, 0);
    XCTAssertEqual(components.minute, 0);
    XCTAssertEqual(components.second, 0);

    // yyyy-MM
    date = [UAUtils parseISO8601DateFromString:@"2020-12"];
    components = [self componentsForDate:date];
    XCTAssertNotNil(components);
    XCTAssertEqual(components.year, 2020);
    XCTAssertEqual(components.month, 12);
    XCTAssertEqual(components.day, 1);
    XCTAssertEqual(components.hour, 0);
    XCTAssertEqual(components.minute, 0);
    XCTAssertEqual(components.second, 0);

    // yyyy-MM-dd
    date = [UAUtils parseISO8601DateFromString:@"2020-12-15"];
    components = [self componentsForDate:date];
    XCTAssertNotNil(components);
    XCTAssertEqual(components.year, 2020);
    XCTAssertEqual(components.month, 12);
    XCTAssertEqual(components.day, 15);
    XCTAssertEqual(components.hour, 0);
    XCTAssertEqual(components.minute, 0);
    XCTAssertEqual(components.second, 0);

    // yyyy-MM-dd'T'hh
    date = [UAUtils parseISO8601DateFromString:@"2020-12-15T11"];
    components = [self componentsForDate:date];
    XCTAssertNotNil(components);
    XCTAssertEqual(components.year, 2020);
    XCTAssertEqual(components.month, 12);
    XCTAssertEqual(components.day, 15);
    XCTAssertEqual(components.hour, 11);
    XCTAssertEqual(components.minute, 0);
    XCTAssertEqual(components.second, 0);

    // yyyy-MM-dd hh
    date = [UAUtils parseISO8601DateFromString:@"2020-12-15 11"];
    components = [self componentsForDate:date];
    XCTAssertNotNil(components);
    XCTAssertEqual(components.year, 2020);
    XCTAssertEqual(components.month, 12);
    XCTAssertEqual(components.day, 15);
    XCTAssertEqual(components.hour, 11);
    XCTAssertEqual(components.minute, 0);
    XCTAssertEqual(components.second, 0);

    // yyyy-MM-dd'T'hh:mm
    date = [UAUtils parseISO8601DateFromString:@"2020-12-15T11:45"];
    components = [self componentsForDate:date];
    XCTAssertNotNil(components);
    XCTAssertEqual(components.year, 2020);
    XCTAssertEqual(components.month, 12);
    XCTAssertEqual(components.day, 15);
    XCTAssertEqual(components.hour, 11);
    XCTAssertEqual(components.minute, 45);
    XCTAssertEqual(components.second, 0);

    // yyyy-MM-dd hh:mm
    date = [UAUtils parseISO8601DateFromString:@"2020-12-15 11:45"];
    components = [self componentsForDate:date];
    XCTAssertNotNil(components);
    XCTAssertEqual(components.year, 2020);
    XCTAssertEqual(components.month, 12);
    XCTAssertEqual(components.day, 15);
    XCTAssertEqual(components.hour, 11);
    XCTAssertEqual(components.minute, 45);
    XCTAssertEqual(components.second, 0);

    // yyyy-MM-dd'T'hh:mm:ss
    date = [UAUtils parseISO8601DateFromString:@"2020-12-15T11:45:22"];
    components = [self componentsForDate:date];
    XCTAssertNotNil(components);
    XCTAssertEqual(components.year, 2020);
    XCTAssertEqual(components.month, 12);
    XCTAssertEqual(components.day, 15);
    XCTAssertEqual(components.hour, 11);
    XCTAssertEqual(components.minute, 45);
    XCTAssertEqual(components.second, 22);

    // yyyy-MM-dd hh:mm:ss
    date = [UAUtils parseISO8601DateFromString:@"2020-12-15T11:45:22"];
    components = [self componentsForDate:date];
    XCTAssertNotNil(components);
    XCTAssertEqual(components.year, 2020);
    XCTAssertEqual(components.month, 12);
    XCTAssertEqual(components.day, 15);
    XCTAssertEqual(components.hour, 11);
    XCTAssertEqual(components.minute, 45);
    XCTAssertEqual(components.second, 22);
    NSDate *dateWithoutSubseconds = [date copy];

    // yyyy-MM-ddThh:mm:ss.SSS
    date = [UAUtils parseISO8601DateFromString:@"2020-12-15T11:45:22.123"];
    components = [self componentsForDate:date];
    XCTAssertNotNil(components);
    XCTAssertEqual(components.year, 2020);
    XCTAssertEqual(components.month, 12);
    XCTAssertEqual(components.day, 15);
    XCTAssertEqual(components.hour, 11);
    XCTAssertEqual(components.minute, 45);
    XCTAssertEqual(components.second, 22);
    double seconds = [date timeIntervalSinceDate:dateWithoutSubseconds];
    XCTAssertEqualWithAccuracy(seconds,0.123,0.0001);
}

/**
 * Test isSilentPush is YES when no notification alerts exist in the payload.
 */
- (void)testIsSilentPush {

    NSDictionary *emptyNotification = @{
                                        @"aps": @{
                                                @"content-available": @1
                                                }
                                        };

    NSDictionary *emptyAlert = @{
                                 @"aps": @{
                                         @"alert": @""
                                         }
                                 };

    NSDictionary *emptyLocKey = @{
                                         @"aps": @{
                                                 @"alert": @{
                                                         @"loc-key": @""
                                                         }
                                                 }
                                         };

    NSDictionary *emptyBody = @{
                                       @"aps": @{
                                               @"alert": @{
                                                       @"body": @""
                                                       }
                                               }
                                       };
    XCTAssertTrue([UAUtils isSilentPush:emptyNotification]);
    XCTAssertTrue([UAUtils isSilentPush:emptyAlert]);
    XCTAssertTrue([UAUtils isSilentPush:emptyLocKey]);
    XCTAssertTrue([UAUtils isSilentPush:emptyBody]);


}

/**
 * Test testIsSilentPush is NO when at least one notification alert exist in the payload.
 */
- (void)testIsSilentPushNo {

    NSDictionary *alertNotification = @{
                                        @"aps": @{
                                                @"alert": @"hello world"
                                                }
                                        };

    NSDictionary *badgeNotification = @{
                                        @"aps": @{
                                                @"badge": @2
                                                }
                                        };

    NSDictionary *soundNotification = @{
                                        @"aps": @{
                                                @"sound": @"cat"
                                                }
                                        };

    NSDictionary *notification = @{
                                   @"aps": @{
                                           @"alert": @"hello world",
                                           @"badge": @2,
                                           @"sound": @"cat"
                                           }
                                   };

    NSDictionary *locKeyNotification = @{
                                         @"aps": @{
                                                 @"alert": @{
                                                         @"loc-key": @"cool"
                                                         }
                                                 }
                                         };

    NSDictionary *bodyNotification = @{
                                         @"aps": @{
                                                 @"alert": @{
                                                         @"body": @"cool"
                                                         }
                                                 }
                                         };


    XCTAssertFalse([UAUtils isSilentPush:alertNotification]);
    XCTAssertFalse([UAUtils isSilentPush:badgeNotification]);
    XCTAssertFalse([UAUtils isSilentPush:soundNotification]);
    XCTAssertFalse([UAUtils isSilentPush:notification]);
    XCTAssertFalse([UAUtils isSilentPush:locKeyNotification]);
    XCTAssertFalse([UAUtils isSilentPush:bodyNotification]);
}

- (void)testIsAlertingPush {
    NSDictionary *alertNotification = @{
                                        @"aps": @{
                                                @"alert": @"hello world"
                                                }
                                        };

    NSDictionary *notification = @{
                                   @"aps": @{
                                           @"alert": @"hello world",
                                           @"badge": @2,
                                           @"sound": @"cat"
                                           }
                                   };

    NSDictionary *locKeyNotification = @{
                                         @"aps": @{
                                                 @"alert": @{
                                                         @"loc-key": @"cool"
                                                         }
                                                 }
                                         };

    NSDictionary *bodyNotification = @{
                                       @"aps": @{
                                               @"alert": @{
                                                       @"body": @"cool"
                                                       }
                                               }
                                       };


    XCTAssertTrue([UAUtils isAlertingPush:alertNotification]);
    XCTAssertTrue([UAUtils isAlertingPush:notification]);
    XCTAssertTrue([UAUtils isAlertingPush:locKeyNotification]);
    XCTAssertTrue([UAUtils isAlertingPush:bodyNotification]);
}

- (void)testIsAlertingPushNo {
    NSDictionary *emptyNotification = @{
                                        @"aps": @{
                                                @"content-available": @1
                                                }
                                        };

    NSDictionary *emptyAlert = @{
                                 @"aps": @{
                                         @"alert": @""
                                         }
                                 };

    NSDictionary *emptyLocKey = @{
                                  @"aps": @{
                                          @"alert": @{
                                                  @"loc-key": @""
                                                  }
                                          }
                                  };

    NSDictionary *emptyBody = @{
                                @"aps": @{
                                        @"alert": @{
                                                @"body": @""
                                                }
                                        }
                                };

    NSDictionary *badgeNotification = @{
                                        @"aps": @{
                                                @"badge": @2
                                                }
                                        };

    NSDictionary *soundNotification = @{
                                        @"aps": @{
                                                @"sound": @"cat"
                                                }
                                        };

    XCTAssertFalse([UAUtils isAlertingPush:emptyNotification]);
    XCTAssertFalse([UAUtils isAlertingPush:emptyAlert]);
    XCTAssertFalse([UAUtils isAlertingPush:emptyLocKey]);
    XCTAssertFalse([UAUtils isAlertingPush:emptyBody]);
    XCTAssertFalse([UAUtils isAlertingPush:badgeNotification]);
    XCTAssertFalse([UAUtils isAlertingPush:soundNotification]);
}

- (void)testMergeFetchResults {
    NSMutableArray *fetchResults;

    // nil fetchResults
    XCTAssertEqual([UAUtils mergeFetchResults:fetchResults], UIBackgroundFetchResultNoData);

    // empty fetchResults
    fetchResults = [NSMutableArray array];
    XCTAssertEqual([UAUtils mergeFetchResults:fetchResults], UIBackgroundFetchResultNoData);

    // new data
    fetchResults[0] = [NSNumber numberWithInt:UIBackgroundFetchResultNewData];
    XCTAssertEqual([UAUtils mergeFetchResults:fetchResults], UIBackgroundFetchResultNewData);

    // no data
    fetchResults[0] = [NSNumber numberWithInt:UIBackgroundFetchResultNoData];
    XCTAssertEqual([UAUtils mergeFetchResults:fetchResults], UIBackgroundFetchResultNoData);

    // failed
    fetchResults[0] = [NSNumber numberWithInt:UIBackgroundFetchResultFailed];
    XCTAssertEqual([UAUtils mergeFetchResults:fetchResults], UIBackgroundFetchResultFailed);

    // new data & no data
    fetchResults[0] = [NSNumber numberWithInt:UIBackgroundFetchResultNewData];
    fetchResults[1] = [NSNumber numberWithInt:UIBackgroundFetchResultNoData];
    XCTAssertEqual([UAUtils mergeFetchResults:fetchResults], UIBackgroundFetchResultNewData);

    // new data & failed
    fetchResults[0] = [NSNumber numberWithInt:UIBackgroundFetchResultNewData];
    fetchResults[1] = [NSNumber numberWithInt:UIBackgroundFetchResultFailed];
    XCTAssertEqual([UAUtils mergeFetchResults:fetchResults], UIBackgroundFetchResultNewData);

    // no data & failed
    fetchResults[0] = [NSNumber numberWithInt:UIBackgroundFetchResultNoData];
    fetchResults[1] = [NSNumber numberWithInt:UIBackgroundFetchResultFailed];
    XCTAssertEqual([UAUtils mergeFetchResults:fetchResults], UIBackgroundFetchResultFailed);

    // new data, no data, failed
    fetchResults[0] = [NSNumber numberWithInt:UIBackgroundFetchResultNewData];
    fetchResults[1] = [NSNumber numberWithInt:UIBackgroundFetchResultNoData];
    fetchResults[2] = [NSNumber numberWithInt:UIBackgroundFetchResultFailed];
    XCTAssertEqual([UAUtils mergeFetchResults:fetchResults], UIBackgroundFetchResultNewData);
}

- (void)testFloatingPointIsEqualsWithAccuracy {
    // Positive numbers
    XCTAssertTrue([UAUtils float:10 isEqualToFloat:10.1 withAccuracy:0.1]);
    XCTAssertTrue([UAUtils float:10 isEqualToFloat:10.0 withAccuracy:0]);
    XCTAssertTrue([UAUtils float:10 isEqualToFloat:9.9 withAccuracy:0.1]);

    XCTAssertFalse([UAUtils float:10 isEqualToFloat:10.1 withAccuracy:0]);
    XCTAssertFalse([UAUtils float:10 isEqualToFloat:10.1 withAccuracy:0.01]);

    // Around zero
    XCTAssertTrue([UAUtils float:0 isEqualToFloat:0.1 withAccuracy:0.1]);
    XCTAssertTrue([UAUtils float:0 isEqualToFloat:-0.1 withAccuracy:0.1]);

    XCTAssertFalse([UAUtils float:0 isEqualToFloat:0.1 withAccuracy:0.099]);
    XCTAssertFalse([UAUtils float:0 isEqualToFloat:-0.1 withAccuracy:0.099]);

    // Negative numbers
    XCTAssertTrue([UAUtils float:-10 isEqualToFloat:-10.1 withAccuracy:0.1]);
    XCTAssertTrue([UAUtils float:-10 isEqualToFloat:-10.0 withAccuracy:0]);
    XCTAssertTrue([UAUtils float:-10 isEqualToFloat:-9.9 withAccuracy:0.1]);

    XCTAssertFalse([UAUtils float:-10 isEqualToFloat:-10.1 withAccuracy:0]);
    XCTAssertFalse([UAUtils float:-10 isEqualToFloat:-10.1 withAccuracy:0.01]);

    // Large numbers
    XCTAssertTrue([UAUtils float:1000000 isEqualToFloat:1000001 withAccuracy:1]);
    XCTAssertTrue([UAUtils float:1000000 isEqualToFloat:999999 withAccuracy:1]);
}

/**
 * Test parse urls.
 */
- (void)testParseURL {
    NSString *originalUrl = @"https://advswift.com/api/v1?page=url+components";
    NSURL *url = [UAUtils parseURL:originalUrl];
    XCTAssertNotNil(url);
    XCTAssertEqualObjects(originalUrl, url.absoluteString);
    
    originalUrl = @"rtlmost://szakaszó.com/main/típus/v1?page=azonosító";
    NSString *encodedUrl = @"rtlmost://szakasz%C3%B3.com/main/t%C3%ADpus/v1?page=azonos%C3%ADt%C3%B3";
    url = [UAUtils parseURL:originalUrl];
    XCTAssertNotNil(url);
    XCTAssertEqualObjects(encodedUrl, url.absoluteString);
    
    
    //Decode the url
    NSString *decodedUrl = url.absoluteString.stringByRemovingPercentEncoding;
    XCTAssertNotNil(decodedUrl);
    XCTAssertEqualObjects(originalUrl, decodedUrl);
}

@end
