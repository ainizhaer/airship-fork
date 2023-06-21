/* Copyright Airship and Contributors */

import XCTest

@testable
import AirshipCore

final class ExperimentManagerTest: XCTestCase {
    
    private var channelId: String? = "channel-id"
    private var contactId = "some-contact-id"
    
    private let remoteData = MockRemoteDataProvider()
    private var subject: ExperimentManager!

    override func setUpWithError() throws {
        self.subject = ExperimentManager(
            dataStore: PreferenceDataStore(appKey: UUID().uuidString),
            remoteData: remoteData,
            channelIdFetcher: getChannelId,
            stableContactIdFetcher: getContactId
        )
    }
    
    private func getChannelId() -> String? {
        return channelId
    }
    
    private func getContactId() -> String {
        return contactId
    }

    func testManagerParseValidExperimentData() async throws {
        
        let experimentId = "fake-id"
        self.remoteData.payloads = [createPayload([generateExperiment(id: experimentId)])]
        let experiment = await self.subject.getExperiment(id: experimentId)
        
        let reportingMetadata = [
            "experiment_id": "\(experimentId)"
        ]
        
        XCTAssertNotNil(experiment)
        XCTAssertEqual(experimentId, experiment?.id)
        XCTAssertEqual("farm_hash", experiment?.audienceSelector.hash.algorithm.rawValue)
        XCTAssertEqual("contact", experiment?.audienceSelector.hash.property.rawValue)
        XCTAssertEqual(Date(timeIntervalSince1970: 1684868854), experiment?.lastUpdated)
        XCTAssertEqual("Holdout", experiment?.type.rawValue)
        XCTAssertEqual("Static", experiment?.resolutionType.rawValue)
        XCTAssertEqual(reportingMetadata, experiment?.reportingMetadata)
    }
    
    func testExperimentManagerOmitsInvalidExperiments() async {
        let valid = generateExperiment(id: "valid-experiment", hashIdentifier: "channel")
        let invalid = generateExperiment(id: "invalid-experiment", hashIdentifier: "invalid")
        
        self.remoteData.payloads = [createPayload([valid, invalid])]

        let validExperiment = await self.subject.getExperiment(id: "valid-experiment")
        XCTAssertNotNil(validExperiment)
        XCTAssertEqual("valid-experiment", validExperiment?.id)
        XCTAssertEqual("channel", validExperiment?.audienceSelector.hash.property.rawValue)

        let invalidExperiment = await self.subject.getExperiment(id: "invalid-experiment")
        XCTAssertNil(invalidExperiment)
    }

    func testExperimentManagerParseMultipleExperiments() async {
        let experiment1 = generateExperiment(id: "id1")
        let experiment2 = generateExperiment(id: "id2")
        self.remoteData.payloads = [createPayload([experiment1]), createPayload([experiment2])]

        let ex1 = await self.subject.getExperiment(id: "id1")
        XCTAssertNotNil(ex1)

        let ex2 = await self.subject.getExperiment(id: "id2")
        XCTAssertNotNil(ex2)
    }

    func testExperimentManagerHandleNoExperimentsPayload() async {
        self.remoteData.payloads = [createPayload(["{}"])]

        let experiment = await self.subject.getExperiment(id: "id")
        XCTAssertNil(experiment)
    }

    func testExperimentManagerHandleInvalidPayload() async {
        let experiment = "{\"invalid\": \"experiment\"}"
        self.remoteData.payloads = [createPayload([experiment])]

        let result = await subject.getExperiment(id: "id")
        XCTAssertNil(result)
    }
    
    func testHoldoutGroupEvaluationWorks() async {
        let json = generateExperiment(id: "fake-id", hashIdentifier: "channel")
        self.remoteData.payloads = [createPayload([json])]
        
        let result = await subject.evaluateGlobalHoldouts(info: MessageInfo.empty, contactId: nil)
        XCTAssertNotNil(result)
        XCTAssertEqual("fake-id", result?.experimentId)
        XCTAssertEqual(contactId, result?.contactId)
        XCTAssertEqual(channelId, result?.channelId)
        XCTAssertEqual(["experiment_id": "fake-id"], result?.reportingMetadata)
    }
    
    func testHoldoutGroupEvaluationRespectHashBuckets() async {
        let activeContactId = "active-contact-id"
        
        self.remoteData.payloads = [createPayload([
            generateExperiment(id: "unmatched", bucketMax: 1239),
            generateExperiment(id: "matched", bucketMin: 1239)
        ])]
        
        let result = await subject.evaluateGlobalHoldouts(info: MessageInfo.empty, contactId: activeContactId)
        
        XCTAssertNotNil(result)
        XCTAssertEqual("matched", result?.experimentId)
        XCTAssertEqual(activeContactId, result?.contactId)
    }
    
    func testHoldoutGroupEvaluationPicksFirstMatchingExperiment() async {
        self.remoteData.payloads = [createPayload([
            generateExperiment(id: "first"),
            generateExperiment(id: "second")
        ])]

        let result = await subject.evaluateGlobalHoldouts(info: MessageInfo.empty, contactId: nil)
        XCTAssertNotNil(result)
        XCTAssertEqual("first", result?.experimentId)
    }

    func testHoldoutEvaluationRespectsMessageExclusion() async {
        self.remoteData.payloads = [createPayload([
            generateExperiment(id: "unmatched"),
            generateExperiment(id: "matched", messageTypeToExclude: "none")
        ])]

        let result = await subject.evaluateGlobalHoldouts(info: MessageInfo(messageType: "Transactional"), contactId: nil)

        XCTAssertNotNil(result)
        XCTAssertEqual("matched", result?.experimentId)
    }

    func testHoldoutEvaluationRespectOverridesForHash() async {
        contactId = "default-contact-id"
        
        let unmatched = generateExperiment(
            id: "unmatched",
            hashOverrides: "{\"\(contactId)\": \"overriden\"}",
            bucketMax: 2337)

        self.remoteData.payloads = [createPayload([
            unmatched,
            generateExperiment(id: "matched", bucketMax: 2337)
        ])]

        let result = await subject.evaluateGlobalHoldouts(info: MessageInfo(messageType: ""), contactId: nil)

        XCTAssertNotNil(result)
        XCTAssertEqual("matched", result?.experimentId)
    }
    
    private func generateExperiment(
        id: String,
        hashIdentifier: String = "contact",
        hashAlgorithm: String = "farm_hash",
        hashOverrides: String? = nil,
        bucketMin: Int = 0,
        bucketMax: Int = 16384,
        messageTypeToExclude: String = "Transactional"
    ) -> String {
        
        let overrides: String
        if let value = hashOverrides {
            overrides = ",\"hash_identifier_overrides\": \(value)"
        } else {
            overrides = ""
        }
        
        return """
        {
            "id": "\(id)",
            "experimentType": "Holdout",
            "last_updated": "2023-05-23T19:07:34Z",
            "reporting_metadata": {
                "experiment_id": "\(id)"
            },
            "type": "Static",
            "audience_selector": {
                "hash": {
                    "audience_hash": {
                        "hash_prefix": "e66a2371-fecf-41de-9238-cb6c28a86cec:",
                        "num_hash_buckets": 16384,
                        "hash_identifier": "\(hashIdentifier)",
                        "hash_algorithm": "\(hashAlgorithm)"
                        \(overrides)
                    },
                    "audience_subset": {
                        "min_hash_bucket": \(bucketMin),
                        "max_hash_bucket": \(bucketMax)
                    }
                }
            },
            "message_exclusions": [
                {
                    "message_type": {
                        "value": {
                            "equals": "\(messageTypeToExclude)"
                        }
                    }
                }
            ]
        }
        """
    }
    
    private func createPayload(_ json: [String], type: String = "experiments") -> RemoteDataPayload {
        let wrapped = "{\"\(type)\": [\(json.joined(separator: ","))]}"
        let data =
            try! JSONSerialization.jsonObject(
                with: wrapped.data(using: .utf8)!,
                options: []
            ) as! [AnyHashable: Any]

        return RemoteDataPayload(
            type: type,
            timestamp: Date(),
            data: try! AirshipJSON.wrap(data),
            remoteDataInfo: nil
        )
    }
}

private extension MessageInfo {
    static let empty = MessageInfo(messageType: "")
}
