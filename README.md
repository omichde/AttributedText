# AttributedText

Using this view in SwiftUI is a simple as `AttributedText(attributedString)` and hence closely resembles the simplicity of `Text`.
The content of the text is width-constrained (it grows in height) and self-contained (no other dependancies).

There is an example where some more fancy attributed strings are shown and how the content:

- properly word wrap into its width constrained container
- show custom font assignment
- show word-by-word styling including links (which open externally)
- show an image alongside a text

The background colors and bars are for testing purposes:

![Screenshot](/screenshot.png)

## Considerations

The view internally is using the following "layers":

- `AttributedText` is embedding `WrappedTextView` only for its size calculation by means of a `GeometryReader` and the usual `PreferenceKey` dance.
- `WrappedTextView` is the `UIViewRepresentable` bridging between SwiftUI and UIKit
- `WrappedTextView` uses the final `AttributedUITextView` to render the attributed string as a subclass from `UITextView`

Although this code is used in production, it has some weaknesses I'd like to point out:

- "sometimes" SwiftUI complains of repeated size calculations (but succeeds anyway). I've tried to minimize the size calculations but please report any bugs in that regard.
- a static extension on `NSAttributedString` is used to calculate the final height, this is according to Apples sample code but conceptionally decoupled from the UITextView rendering the text - meh.
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
