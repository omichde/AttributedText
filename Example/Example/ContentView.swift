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
		let font = UIFont.systemFont(ofSize: 32)
		let attributes = [NSAttributedString.Key.font: font]
		return NSAttributedString(string: quote, attributes: attributes)
	}()

	var body: some View {
		VStack {
			Color.blue.frame(height: 10)
			HStack {
				Color.red.frame(width: 50, height: 10)
				AttributedText(basicText)
					.background(Color.green.opacity(0.5))
				Color.red.frame(width: 150, height: 10)
			}
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
