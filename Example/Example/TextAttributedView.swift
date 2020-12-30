// Streckenagent

import SwiftUI
import Atributika

struct TextAttributedView: View {
	private let text: String
	private var lineLimit: Int
	@State private var box: CGSize = .zero
	
	init(_ text: String, lineLimit: Int = 0) {
		self.text = text
		self.lineLimit = lineLimit
	}
	
	var body: some View {
		TextAttributedWrapperView(text, lineLimit: lineLimit)
			.background(GeometryReader { geo in
				Color.clear.preference(key: SizePreferenceKey.self,
															 value: SizedTextContent(text: text, lineLimit: lineLimit, size: geo.size))
			})
			.if(box.width > 0) { $0.frame(width: box.width, height: box.height) }
			.onPreferenceChange(SizePreferenceKey.self) { value in
				// minimize updates
				if value.size.width > 0 && value.size.height > 0 &&
						(value.size.width != box.width || value.size.height != box.height) {
					self.box = value.size
				}
			}
	}
}

private struct SizedTextContent: Equatable {
	let text: String
	let lineLimit: Int
	let size: CGSize
	
	static let empty = SizedTextContent(text: "", lineLimit: 0, size: .zero)
	
	func with(height: CGFloat) -> SizedTextContent {
		SizedTextContent(text: text, lineLimit: lineLimit, size: CGSize(width: size.width, height: height))
	}
}

private struct SizePreferenceKey: PreferenceKey {
	static let defaultValue: SizedTextContent = .empty
	static func reduce(value: inout Value, nextValue: () -> Value) {
		var val = nextValue()
		if value.size.width > 0 {   // this is called multiple times with the default size value and we only need to recalculate for a "valid" width
			let height = AttributedTextUIView.boxHeight(text: value.text, width: value.size.width, lineLimit: value.lineLimit)
			val = value.with(height: height)
		}
		value = val
	}
}

private struct TextAttributedWrapperView: UIViewRepresentable {
	let text: String
	let lineLimit: Int
	
	init(_ text: String, lineLimit: Int) {
		self.text = text
		self.lineLimit = lineLimit
	}
	
	func makeUIView(context: Context) -> AttributedTextUIView {
		AttributedTextUIView(frame: .zero, lineLimit: lineLimit)
	}
	
	func updateUIView(_ uiView: AttributedTextUIView, context: Context) {
		uiView.text = text
	}
}

#if DEBUG
struct TextAttributedView_Previews: PreviewProvider {
	static let text = "Bitte tragen Sie einen <b><a href=\"https://www.bahn.de/p/view/service/sicherreisen.shtml\">Mund-<i>Nasen</i>-Schutz</a></b>.<br>Mehr Informationen Zum selber machen finden Sie <a href=\"https://inside.bahn.de/schutzmasken-zugfahrt-selbst-machen/\">hier</a>."
	
	static var previews: some View {
		VStack {
			Color.blue.frame(height: 10)
			HStack {
				Color.red.frame(width: 50, height: 10)
				TextAttributedView(text)
					.background(Color.green.opacity(0.5))
				Color.red.frame(width: 50, height: 10)
			}
			Color.blue.frame(height: 10)
			HStack {
				Color.red.frame(width: 150, height: 10)
				TextAttributedView(text)
					.background(Color.green.opacity(0.5))
				Color.red.frame(width: 10, height: 10)
			}
			Color.blue.frame(height: 10)
			HStack {
				Color.red.frame(width: 10, height: 10)
				TextAttributedView(text, lineLimit: 3)
					.background(Color.green.opacity(0.5))
				Color.red.frame(width: 150, height: 10)
			}
			Color.blue.frame(height: 10)
			HStack {
				Color.red.frame(width: 250, height: 10)
				TextAttributedView(text)
					.background(Color.green.opacity(0.5))
				Color.red.frame(width: 20, height: 10)
			}
			Color.blue.frame(height: 10)
			Spacer().layoutPriority(0.1)
		}
	}
}
#endif

private extension View {
	// https://fivestars.blog/swiftui/conditional-modifiers.html
	@ViewBuilder
	func `if`<Transform: View>(
		_ condition: Bool,
		transform: (Self) -> Transform
	) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
}

private class AttributedTextUIView: AttributedLabel {
	var text: String = "" {
		didSet {
			attributedText = text.dbAttributedString()
		}
	}
	
	static func boxHeight(text: String, width: CGFloat, lineLimit: Int) -> CGFloat {
		let attrText = text.dbAttributedString().attributedString
		let box = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
		let storage = NSTextStorage(attributedString: attrText)
		let container = NSTextContainer(size: box)
		let manager = NSLayoutManager()
		manager.addTextContainer(container)
		storage.addLayoutManager(manager)
		container.maximumNumberOfLines = lineLimit
		container.lineFragmentPadding = 0
		manager.glyphRange(forBoundingRect: CGRect(origin: .zero, size: box), in: container)
		return ceil(manager.usedRect(for: container).size.height)
	}
	
	init(frame: CGRect, lineLimit: Int) {
		super.init(frame: frame)
		
		numberOfLines = lineLimit
		setContentHuggingPriority(.required, for: .horizontal)
		setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		onClick = { label, detection in
			switch detection.type {
			case .phoneNumber(let number):
				if let url = URL(string: "tel://\(number)") {
					url.openExternally()
				}
			case .link(let url):
				url.openExternally()
			case .tag(let tag):
				if tag.name == "a", let href = tag.attributes["href"], let url = URL(string: href) {
					url.openExternally()
				}
			default:
				break
			}
		}
	}
	
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override var intrinsicContentSize: CGSize {
		sizeThatFits(CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
	}
}

fileprivate extension String {
	func dbAttributedString() -> AttributedText {
		let textColor = UIColor.black
		let a = Style("a").foregroundColor(textColor, .highlighted).underlineStyle(.single)
		let font = UIFont(name: "Helvetica", size: 12)!
		let globalStyle = Style.font(font).foregroundColor(textColor)
		return self
			.style(tags: a)
			.styleLinks(a)
			.stylePhoneNumbers(a)
			.styleAll(globalStyle)
	}
}

fileprivate extension URL {
	func openExternally() {
		guard UIApplication.shared.canOpenURL(self) else { return }
		
		UIApplication.shared.open(self, options: [:], completionHandler: nil)
	}
}
