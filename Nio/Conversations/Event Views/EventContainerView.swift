import SwiftUI
import SwiftMatrixSDK

struct EventContainerView: View {
    var event: MXEvent
    var reactions: [Reaction]
    var connectedEdges: ConnectedEdges
    var showSender: Bool
    var contextMenuModel: EventContextMenuModel

    private var topPadding: CGFloat {
        connectedEdges.contains(.topEdge) ? 2.0 : 8.0
    }

    private var bottomPadding: CGFloat {
        connectedEdges.contains(.bottomEdge) ? 2.0 : 8.0
    }

    var body: some View {
        switch MXEventType(identifier: event.type) {
        case .roomMessage:
            guard !event.isRedactedEvent() else {
                let redactor = event.redactedBecause["sender"] as? String ?? "unknown"
                let reason = (event.redactedBecause["content"] as? [AnyHashable: Any])?["body"] as? String
                return AnyView(
                    RedactionEventView(model: .init(sender: event.sender, redactor: redactor, reason: reason))
                )
            }

            // FIXME: remove
            // swiftlint:disable:next force_try
            let messageModel = try! MessageViewModel(event: event,
                                                     reactions: reactions,
                                                     showSender: showSender)
            return AnyView(
                MessageView(
                    model: .constant(messageModel),
                    contextMenuModel: contextMenuModel,
                    connectedEdges: connectedEdges
                )
                .padding(.top, topPadding)
                .padding(.bottom, bottomPadding)
            )
        case .roomMember:
            let affectedUser = (event.content["displayname"] as? String)
            let membership = (event.content["membership"] as? String) ?? ""
            return AnyView(
                RoomMemberEventView(sender: event.sender, affectedUser: affectedUser, membership: membership)
            )
        default:
            return AnyView(
                GenericEventView(text: "\(event.type!)\n\(event.content!)")
                    .padding(.top, 10)
            )
        }
    }
}
