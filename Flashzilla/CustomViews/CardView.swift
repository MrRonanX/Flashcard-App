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
                    cardTextView
                    
                }
            }
            .padding()
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
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
    
    var cardTextView: some View {
        Group {
            Text(card.prompt)
                .cardTextStyle()
            if isShowingAnswer {
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
        CardView(card: Card.example)
    }
}
