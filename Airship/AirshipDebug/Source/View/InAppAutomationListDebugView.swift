/* Copyright Airship and Contributors */

import Combine
import SwiftUI

#if canImport(AirshipCore)
import AirshipCore
#elseif canImport(AirshipKit)
import AirshipKit
#endif

struct InAppAutomationListDebugView: View {

    @StateObject
    private var viewModel = ViewModel()

    var body: some View {
        Form {
            Section(header: Text("")) {
                List(self.viewModel.messagePayloads, id: \.self) { payload in
                    let title = parseTitle(payload: payload)
                    NavigationLink(
                        destination: InAppMessageDetailsView(
                            payload: payload,
                            title: title
                        )
                    ) {
                        VStack(alignment: .leading) {
                            Text(title)
                            Text(parseID(payload: payload))
                        }
                    }
                }
            }
        }
        .navigationTitle("In-App Automations".localized())
    }

    func parseTitle(payload: [String: AnyHashable]) -> String {
        let message = payload["message"] as? [String: AnyHashable]
        return message?["name"] as? String ?? parseType(payload: payload)
    }

    func parseType(payload: [String: AnyHashable]) -> String {
        return payload["type"] as? String ?? "Unknown"
    }

    func parseID(payload: [String: AnyHashable]) -> String {
        return payload["id"] as? String ?? "MISSING_ID"
    }

    class ViewModel: ObservableObject {
        @Published private(set) var messagePayloads: [[String: AnyHashable]] =
            []
        private var cancellable: AnyCancellable? = nil

        init() {
            if Airship.isFlying {
                self.cancellable = AirshipDebugManager.shared
                    .inAppAutomationsPublisher
                    .receive(on: RunLoop.main)
                    .sink { incoming in
                        self.messagePayloads = incoming
                    }
            }
        }
    }
}

private struct InAppMessageDetailsView: View {
    let payload: [String: AnyHashable]
    let title: String

    @ViewBuilder
    var body: some View {
        let description = try? JSONUtils.string(
            payload,
            options: .prettyPrinted
        )
        Form {
            Section(header: Text("Message details".localized())) {
                Text(description ?? "ERROR!")
            }
        }
        .navigationTitle(title)
    }
}
