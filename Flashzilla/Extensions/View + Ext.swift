//
//  View + Ext.swift
//  Flashzilla
//
//  Created by Roman Kavinskyi on 7/15/21.
//

import SwiftUI

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 10))
    }
    
    func timerStyle() -> some View {
        self.modifier(TimerStyle())
    }
    
    func cardTextStyle() -> some View {
        self.modifier(CardTextStyle())
    }
    
    func cardMovementAnimation(with offset: CGSize) -> some View {
        self.modifier(CardMovementAnimation(offset: offset))
    }
}
