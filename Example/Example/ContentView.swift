//
//  ContentView.swift
//  Example
//
//  Created by Oliver Michalak on 20.12.20.
//

import SwiftUI
import AttributedText

struct ContentView: View {
	let basicText: NSAttributedString = {
		let quote = "The quick brown fox jumps over the lazy dog."
		let font = UIFont.systemFont(ofSize: 20)
		let attributes = [NSAttributedString.Key.font: font]
		return NSAttributedString(string: quote, attributes: attributes)
	}()

	let styledText: NSAttributedString = {
		let quote = "The quick brown fox jumps over the lazy dog."
		let str = NSMutableAttributedString(string: quote)
		for idx in 0..<str.length/2 {
			str.addAttribute(.font, value: UIFont(name: "Chalkduster", size: 32)!, range: NSRange(location: idx * 2, length: 1))
		}
		return str
	}()

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

	let imageText: NSAttributedString = {
		let quote = "epunks for the win..."
		let attachment = NSTextAttachment()
		attachment.image = UIImage(named: "epunk")
		let str = NSMutableAttributedString(attachment: attachment)
		str.append(NSAttributedString(string: quote))
		return str
	}()

	var body: some View {
		VStack {
			Color.blue.frame(height: 10)
			HStack {
				Color.red.frame(width: 50, height: 10)
				AttributedText(basicText)
					.background(Color.green.opacity(0.5))
				Color.red.frame(width: 100, height: 10)
			}
			Color.blue.frame(height: 10)
			HStack {
				Color.red.frame(width: 150, height: 10)
				AttributedText(styledText)
					.background(Color.green.opacity(0.5))
				Color.red.frame(width: 10, height: 10)
			}
			Color.blue.frame(height: 10)
			HStack {
				Color.red.frame(width: 10, height: 10)
				AttributedText(weirdText)
					.background(Color.green.opacity(0.5))
				Color.red.frame(width: 150, height: 10)
			}
			Color.blue.frame(height: 10)
			AttributedText(imageText)
			Color.blue.frame(height: 10)
			Spacer().layoutPriority(0.1)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
