//
//  CardView.swift
//  Flashzilla
//
//  Created by Roman Kavinskyi on 7/11/21.
//

import SwiftUI

enum AnswerValidation {
    case correct, wrong
}

struct CardView: View {

    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    let card: Card
    let size: CGSize
    @State private var feedback = UINotificationFeedbackGenerator()
    @State var isShowingAnswer = false
    @State var offset = CGSize.zero
    
    var removal: ((AnswerValidation) -> Void)? = nil
    
    
    var body: some View {
        
        ZStack {
            cardBackground
            VStack {
                if accessibilityEnabled {
                    accessibilityTextView
                } else {
                    mainCardView
                    
                }
            }
            .padding()
            .multilineTextAlignment(.center)
        }
        .frame(width: size.width * 0.7, height: size.width * 0.4)
        .cardMovementAnimation(with: offset)
        .accessibility(addTraits: .isButton)
        .gesture(DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                        feedback.prepare()
                    }
                    .onEnded { _ in cardSwiped() })
        .onTapGesture { isShowingAnswer.toggle() }
        .animation(.spring())
        
    }
    
    var cardBackground: some View {
        Color.white
            .cornerRadius(25)
            .opacity(differentiateWithoutColor ? 1 : 1 - Double(abs(offset.width / 50)))
            .background(differentiateWithoutColor
                            ? nil
                            : RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                            .fill(swipeBackgroundColor()))
            .shadow(radius: 10)
    }
    
    var mainCardView: some View {
        Group {
            if !isShowingAnswer {
                VStack {
                    Text(card.prompt)
                        .cardTextStyle()
                    Spacer()
                    if let uiImage = card.image {
                        Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: size.width * 0.3)
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                        .shadow(radius: 10)
                    }
                }
            } else {
                Text(card.answer)
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
        }
    }

    
    var accessibilityTextView: some View {
        Text(isShowingAnswer ? card.answer : card.prompt)
            .cardTextStyle()
    }
    
    func swipeBackgroundColor() -> Color {
        switch offset.width {
        case let x where x > 0:
            return Color.green
        case let x where x < 0:
            return Color.red
        default:
            return Color.white
        }
    }
    
    func cardSwiped() {
        if abs(offset.width) > 100 {
            offset.width > 0 ? swipedRight() : swipedLeft()
        } else {
            offset = .zero }
    }
    
    func swipedLeft() {
        feedback.notificationOccurred(.error)
        removal?(.wrong)
    }
    
    func swipedRight() {
        feedback.notificationOccurred(.success)
        removal?(.correct)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.example, size: CGSize(width: 390, height: 844))
    }
}
