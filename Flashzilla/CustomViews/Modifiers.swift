//
//  Modifiers.swift
//  Flashzilla
//
//  Created by Roman Kavinskyi on 7/15/21.
//

import SwiftUI


struct TimerStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.75)))
    }
}

struct CardTextStyle: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundColor(.black)
    }
}

struct CardMovementAnimation: ViewModifier {
    
    var offset: CGSize
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(Double(offset.width / 5)))
            .offset(x: offset.width * 5, y: 0)
            .opacity(2 - Double(abs(offset.width / 50)))
    }
}



