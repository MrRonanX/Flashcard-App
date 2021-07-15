//
//  MainScreenButton.swift
//  Flashzilla
//
//  Created by Roman Kavinskyi on 7/15/21.
//

import SwiftUI

struct MainScreenButton: View {
    enum HorizontalPosition {
        case leading, trailing
    }
    
    var imageName: String
    var horizontalPosition: HorizontalPosition = .leading
    var action: (() -> Void)? = nil
    var body: some View {
        VStack {
            HStack {
                if horizontalPosition == .leading {
                    actionButton
                    Spacer()
                } else {
                    Spacer()
                    actionButton
                }
            }
            .foregroundColor(.white)
            .font(.title)
            .padding()
            
            Spacer()
        }
    }
    
    var actionButton: some View {
        Button { action?() }
            label: {
                Image(systemName: imageName)
                    .padding(10)
                    .background(Color.black.opacity(0.75))
                    .clipShape(Circle())
            }
    }
}

struct MainScreenButton_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenButton(imageName: "xmark.circle")
    }
}
