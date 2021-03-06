import SwiftUI
import NioKit

import CommonMarkAttributedString

struct MarkdownText: View {
    private let markdown: String
    private let textColor: UXColor

    @State private var contentSizeThatFits: CGSize = .zero

    private let textAttributes: TextAttributes
    private let linkColor: UXColor

  #if os(macOS)
  #else
    #warning("Is onLinkInteraction needed?")
    private let onLinkInteraction: (((URL, UITextItemInteraction) -> Bool))?
  #endif

  #if os(macOS)
    public init(
        markdown: String,
        textColor: UXColor,
        textAttributes: TextAttributes = .init(),
        linkColor: UXColor,
        dummyLinkInteraction: ((URL, String) -> Bool)? = nil
    ) {
        self.markdown = markdown

        self.textColor = textColor.resolvedColor(with: .current)
        self.textAttributes = textAttributes
        self.linkColor = linkColor
    }
  #else
    public init(
        markdown: String,
        textColor: UXColor,
        textAttributes: TextAttributes = .init(),
        linkColor: UXColor,
        onLinkInteraction: (((URL, UITextItemInteraction) -> Bool))? = nil
    ) {
        self.markdown = markdown

        self.textColor = textColor.resolvedColor(with: .current)
        self.textAttributes = textAttributes
        self.linkColor = linkColor
        self.onLinkInteraction = onLinkInteraction
    }
  #endif

    internal var attributes: [NSAttributedString.Key: Any] {
        [
            NSAttributedString.Key.font: UXFont.preferredFont(forTextStyle: .body),
            NSAttributedString.Key.foregroundColor: self.textColor,
        ]
    }

    internal var attributedText: NSAttributedString {
        let markdownString = markdown.trimmingCharacters(in: .whitespacesAndNewlines)
          .replacingOccurrences(of: "<", with: "&lt;")
        let attributedString = try? NSAttributedString(
            commonmark: markdownString,
            attributes: attributes
        )
        return attributedString ?? NSAttributedString(
            string: markdownString,
            attributes: attributes
        )
    }

    private var textContainerInset: UXEdgeInsets {
        .init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }

    private var lineFragmentPadding: CGFloat {
        0.0
    }

    var body: some View {
      #if os(macOS)
        // Until we have something better
        Text(verbatim: attributedText.string)
      #else
        GeometryReader { geometry in
            let size = MessageTextView(attributedString: attributedText,
                                            linkColor: linkColor,
                                            maxSize: geometry.size).intrinsicContentSize

            MessageTextViewWrapper(attributedString: attributedText, linkColor: linkColor, maxSize: geometry.size)
                .preference(key: ContentSizeThatFitsKey.self, value: size)
        }
        .onPreferenceChange(ContentSizeThatFitsKey.self) {
            contentSizeThatFits = $0
        }
        .frame(
            maxWidth: self.contentSizeThatFits.width,
            minHeight: self.contentSizeThatFits.height,
            maxHeight: self.contentSizeThatFits.height,
            alignment: .leading
        )
      #endif
    }
}

struct MarkdownText_Previews: PreviewProvider {
    static var previews: some View {
        let markdownString = #"""
        # [Universal Declaration of Human Rights][udhr]

        ## Article 1.

        All human beings are born free and equal in dignity and rights.
        They are endowed with reason and conscience
        and should act towards one another in a spirit of brotherhood.

        [udhr]: https://www.un.org/en/universal-declaration-human-rights/ "View full version"
        """#
        return MarkdownText(
            markdown: markdownString,
            textColor: .messageTextColor(for: .light, isOutgoing: false),
            linkColor: .blue
        ) { url, _ in
            print("Tapped URL:", url)
            return true
        }
            .padding(10.0)
    }
}
