import SwiftUI
import UIKit

public struct AttributedText: View {
	private var attributedText: NSAttributedString
	@State private var box: CGSize = .zero
	
	public init(_ attributedText: NSAttributedString) {
		self.attributedText = attributedText
	}
	
	public var body: some View {
		WrappedTextView(attributedText)
			.background(GeometryReader { geo in
				Color.clear.preference(key: SizedTextPreferenceKey.self,
															 value: SizedTextContent(attributedText: attributedText, size: geo.size))
			})
			.if(box.width > 0) {
				$0.frame(width: box.width, height: box.height)
			}
			.onPreferenceChange(SizedTextPreferenceKey.self) { value in
				// minimize updates
				if value.size.width > 0 && value.size.height > 0 &&
						(value.size.width != box.width || value.size.height != box.height) {
					self.box = value.size
				}
			}
	}
}

#if DEBUG
struct AttributedText_Previews: PreviewProvider {
	static let basicText: NSAttributedString = {
		let quote = "Lorem ipsum dolor sit amet, consectetur adipisici elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquid ex ea commodi consequat. Quis aute iure reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint obcaecat cupiditat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
		let font = UIFont(name: "Zapfino", size: 12)!
		let attributes = [NSAttributedString.Key.font: font]
		return NSAttributedString(string: quote, attributes: attributes)
	}()

	static var previews: some View {
		VStack {
			Color.blue.frame(height: 10)
			HStack {
				Color.red.frame(width: 50, height: 10)
				AttributedText(basicText)
					.background(Color.green.opacity(0.5))
				Color.red.frame(width: 100, height: 10)
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

// MARK: - helpers for size calculation

private struct SizedTextContent: Equatable {
	let attributedText: NSAttributedString
	let size: CGSize
	
	static let empty = SizedTextContent(attributedText: NSAttributedString(string: ""), size: .zero)
	
	func with(height: CGFloat) -> SizedTextContent {
		SizedTextContent(attributedText: attributedText, size: CGSize(width: size.width, height: height))
	}
}

private struct SizedTextPreferenceKey: PreferenceKey {
	static let defaultValue: SizedTextContent = .empty
	static func reduce(value: inout Value, nextValue: () -> Value) {
		var val = nextValue()
		if value.size.width > 0 {   // this is called multiple times with the default size value and we only need to recalculate for a "valid" width
			let height = value.attributedText.calculateBoxHeight(value.size.width)
			val = value.with(height: height)
		}
		value = val
	}
}

private extension NSAttributedString {
	// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TextLayout/Tasks/StringHeight.html#//apple_ref/doc/uid/20001809-CJBGBIBB
	func calculateBoxHeight(_ width: CGFloat) -> CGFloat {
		let box = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
		let storage = NSTextStorage(attributedString: self)
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

// MARK: - UIKit wonderland

private struct WrappedTextView: UIViewRepresentable {
	let attributedText: NSAttributedString
	
	init(_ attributedText: NSAttributedString) {
		self.attributedText = attributedText
	}
	
	func makeUIView(context: Context) -> AttributedUITextView {
		AttributedUITextView()
	}
	
	func updateUIView(_ uiView: AttributedUITextView, context: Context) {
		uiView.attributedText = attributedText
	}
}

private class AttributedUITextView: UIView {
	private let textView = UITextView()
	var attributedText: NSAttributedString? {
		set {
			textView.attributedText = newValue
			setNeedsLayout()
		}
		get {
			return textView.attributedText
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	private func setup() {
		addSubview(textView)
		
		textView.textContainer.lineBreakMode = .byWordWrapping
		textView.textContainer.maximumNumberOfLines = 0
		
		textView.textContainer.lineFragmentPadding = 0;
		textView.textContainerInset = .zero;
		textView.isUserInteractionEnabled = false
		textView.isEditable = false
		textView.isScrollEnabled = false
		textView.isSelectable = false
		textView.backgroundColor = nil
		
		textView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			textView.topAnchor.constraint(equalTo: topAnchor),
			textView.bottomAnchor.constraint(equalTo: bottomAnchor),
			textView.leftAnchor.constraint(equalTo: leftAnchor),
			textView.rightAnchor.constraint(equalTo: rightAnchor)
		])
	}
}
