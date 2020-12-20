import SwiftUI
import UIKit

public struct AttributedText: View {
	private var attributedText: NSAttributedString
	@State private var box: CGSize = .zero
	
	public init(_ attributedText: NSAttributedString) {
		self.attributedText = attributedText
	}
	
	public var body: some View {
		AttributedTextWrapperView(attributedText)
			.background(GeometryReader { geo in
				Color.clear.preference(key: SizedTextPreferenceKey.self,
															 value: SizedTextContent(attributedText: attributedText, size: geo.size))
			})
			
			.if(box.width > 0) { $0.frame(width: box.width, height: box.height) }
			.onPreferenceChange(SizedTextPreferenceKey.self) { value in
				// minimize updates
				if value.size.width > 0 && value.size.height > 0 &&
						(value.size.width != box.width || value.size.height != box.height) {
					self.box = value.size
				}
			}
	}
}

struct AttributedText_Previews: PreviewProvider {
	static var previews: some View {
		AttributedText(NSAttributedString(string: "Hello World!"))
	}
}

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

private struct SizedTextContent: Equatable {
	let attributedText: NSAttributedString
	let size: CGSize
	
	static let empty = SizedTextContent(
		attributedText: NSAttributedString(string: ""),
		size: .zero)
	
	func with(height: CGFloat) -> SizedTextContent {
		SizedTextContent(attributedText: attributedText, size: CGSize(width: size.width, height: height))
	}
}

private struct SizedTextPreferenceKey: PreferenceKey {
	static let defaultValue: SizedTextContent = .empty
	static func reduce(value: inout Value, nextValue: () -> Value) {
		var val = nextValue()
		if val.size.width > 0 {   // this is called multiple times with the default size value and we only need to recalculate for a "valid" width
			let height = AttributedTextWrapperView.boxHeight(attributedText: val.attributedText, width: val.size.width)
			val = value.with(height: height)
		}
		value = val
	}
}

private struct AttributedTextWrapperView: UIViewRepresentable {
	let attributedText: NSAttributedString
	
	init(_ attributedText: NSAttributedString) {
		self.attributedText = attributedText
	}
	
	func makeUIView(context: Context) -> AttributedUITextView {
		let view = AttributedUITextView()
		view.attributedText = attributedText
		return view
	}
	
	func updateUIView(_ uiView: AttributedUITextView, context: Context) {
		uiView.attributedText = attributedText
	}
	
	static func boxHeight(attributedText: NSAttributedString, width: CGFloat) -> CGFloat {
		let box = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
		let storage = NSTextStorage(attributedString: attributedText)
		let container = NSTextContainer(size: box)
		let manager = NSLayoutManager()
		manager.addTextContainer(container)
		storage.addLayoutManager(manager)
		container.maximumNumberOfLines = 0
		container.lineFragmentPadding = 0
		manager.glyphRange(forBoundingRect: CGRect(origin: .zero, size: box), in: container)
		return ceil(manager.usedRect(for: container).size.height)
	}
}

private class AttributedUITextView: UITextView {
	required init?(coder: NSCoder) { fatalError() }
	
	init () {
		super.init(frame: .zero, textContainer: nil)
		backgroundColor = .clear
		textContainer.maximumNumberOfLines = 0
		textContainer.lineFragmentPadding = 0
		textContainerInset = .zero
		isScrollEnabled = false
		setContentHuggingPriority(.required, for: .horizontal)
		setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
	}
	
	override var intrinsicContentSize: CGSize {
		print(bounds.size.width)
		return sizeThatFits(CGSize(
									width: bounds.size.width,
									height: CGFloat.greatestFiniteMagnitude))
	}
}
