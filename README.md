# AttributedText

Using this view in SwiftUI is a simple as `AttributedText(attributedString)` and hence closely resembles the simplicity of `Text`.
The content of the text is width-constrained (it grows in height) and self-contained (no other dependencies).

There is an example where some more fancy attributed strings are shown and how the content:

- properly word wrap into its width constrained container
- show custom font assignment
- show word-by-word styling including links (which open externally)
- show an image alongside a text

## Example

This simplified code contains background colors and bars for testing purposes only:

```swift
let weirdText: NSAttributedString = {
	let quote = "The quick brown fox jumps over the lazy 🐕."
	let str = NSMutableAttributedString(string: quote)
	str.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: NSRange(location: 4, length: 5))
	str.addAttribute(.foregroundColor, value: UIColor.brown, range: NSRange(location: 10, length: 5))
	str.addAttribute(.link, value: NSURL(string: "http://apple.com")!, range: NSRange(location: 16, length: 3))
	str.addAttribute(.underlineStyle, value: 1, range: NSRange(location: 16, length: 3))
	str.addAttribute(.baselineOffset, value: 4, range: NSRange(location: 26, length: 4))
	return str
}()

var body: some View {
	VStack {
		//...
		Color.blue.frame(height: 10)
		HStack {
			Color.red.frame(width: 10, height: 10)
			AttributedText(weirdText)
				.background(Color.green.opacity(0.5))
			Color.red.frame(width: 150, height: 10)
		}
		Color.blue.frame(height: 10)
		//...
	}
}
```

![Screenshot](/screenshot.png)

## Considerations

The view internally is using the following "layers":

- `AttributedText` is embedding `WrappedTextView` only for its size calculation by means of a `GeometryReader` and the usual `PreferenceKey` dance.
- `WrappedTextView` is the `UIViewRepresentable` bridging between SwiftUI and UIKit
- `WrappedTextView` uses the final `AttributedUITextView` to render the attributed string
- `AttributedUITextView` is a subclass from `UITextView`

Although this code is used in production, it has some weaknesses I'd like to point out:

- "sometimes" SwiftUI complains of repeated size calculations (but succeeds anyway). I've tried to minimize the size calculations but please report any bugs in that regard.
- a static extension on `NSAttributedString` is used to calculate the final height, this is according to Apples sample code but conceptionally decoupled from the UITextView rendering the text - meh
- this code does not deal with building `NSAttributedString` - there are other libraries (e.g. https://github.com/psharanda/Atributika) doing that.
- in particular, converting html to attributed strings is not covered here.
- modifying the content by means of SwiftUI modifiers (e.g. `.foreground(Color.red)`) is not supported (as I have no idea how to propagate these changes down to a `UIViewPresentable` - get in contact if you know how)

## Contact

Please report any feedback, bugs, ideas as a PR or email:

omichde - Oliver Michalak - oliver@werk01.de

## Installation

Embed it as a SwiftPM package: `https://github.com/omichde/AttributedText` - it should work in iOS 13 and above... 

## License

AttributedText is available under the MIT license:

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
