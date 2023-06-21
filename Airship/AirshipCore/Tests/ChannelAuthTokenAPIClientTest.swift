/* Copyright Airship and Contributors */

import XCTest

@testable import AirshipCore

final class ChannelAuthTokenAPIClientTest: AirshipBaseTest {
    
    private var client: ChannelAuthTokenAPIClient!
    private let session = TestAirshipRequestSession()

    override func setUpWithError() throws {
        self.client = ChannelAuthTokenAPIClient(
            config: self.config,
            session: self.session
        )
    }
    
    func testTokenWithChannelID() async throws {
        self.session.data = try JSONUtils.data([
            "token": "abc123",
            "expires_in": 12345
        ] as [String : Any])
        self.session.response = HTTPURLResponse(
            url: URL(string: "https://www.linkedin.com/")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)

        let token = try await self.client.fetchToken(channelID: "channel ID")
        XCTAssertNotNil(token)
        
        let request = try XCTUnwrap(self.session.lastRequest)
        
        XCTAssertEqual(request.method, "GET")
        XCTAssertEqual(request.url!.absoluteString, "\(self.config.deviceAPIURL!)/api/auth/device")
        XCTAssertEqual(
            AirshipRequestAuth.generatedChannelToken(identifier: "channel ID"),
            request.auth
        )
        XCTAssertEqual(request.headers["Accept"], "application/vnd.urbanairship+json; version=3;")
    }
    
    func testTokenWithChannelIDMalformedPayload() async throws {
        self.session.data = try JSONUtils.data([
            "not a token": "abc123",
            "expires_in_3_2_1": 12345
        ] as [String : Any])
        self.session.response = HTTPURLResponse(
            url: URL(string: "https://www.linkedin.com/")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)
        
        do {
            let _ = try await self.client.fetchToken(channelID: "channel ID")
            XCTFail("Should throw")
        } catch {
            XCTAssertNotNil(error)
        }
        
    }
    
    func testTokenWithChannelIDClientError() async throws {
        self.session.data = try JSONUtils.data([
            "too": "bad"
        ])
        self.session.response = HTTPURLResponse(
            url: URL(string: "https://www.linkedin.com/")!,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil)
        
        let response = try await self.client.fetchToken(channelID: "channel ID")
        let unwrapResponse = try XCTUnwrap(response)
        XCTAssertNil(unwrapResponse.result?.token)
        XCTAssertTrue(unwrapResponse.isClientError)
        XCTAssertFalse(unwrapResponse.isSuccess)
    }
}

