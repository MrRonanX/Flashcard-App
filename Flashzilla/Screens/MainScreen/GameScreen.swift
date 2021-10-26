//
//  ContentView.swift
//  Flashzilla
//
//  Created by Roman Kavinskyi on 7/11/21.
//

import SwiftUI

struct GameScreen: View {
    @StateObject var viewModel = GameViewModel()
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    @State private var isShowingEditScreen       = false
    @State private var isShowingSettingsScreen   = false

    
    var body: some View {
        GeometryReader { geo in
        ZStack {
            backgroundImage
            MainScreenButton(imageName: "gearshape.2", horizontalPosition: .leading) { isShowingSettingsScreen = true }
                .layoutPriority(1)
            MainScreenButton(imageName: "plus.circle", horizontalPosition: .trailing) { isShowingEditScreen = true }
                .layoutPriority(1)
            VStack {
                Text(viewModel.timeLabel)
                    .timerStyle()
                    .onChange(of: viewModel.timeRemaining, perform: viewModel.timesOutRemoveAllCards)
                ZStack {
                    ForEach(0..<viewModel.cards.count, id: \.self) { index in
                        
                            CardView(card: viewModel.cards[index], size: geo.size) { answerValidation in
                            withAnimation {
                                viewModel.removeCard(at: index, answerIsCorrect: answerValidation)
                            }
                        }
                        .stacked(at: index, in: viewModel.cards.count)
                        .allowsHitTesting(index == viewModel.cards.count - 1)
                        .accessibility(hidden: index < viewModel.cards.count - 1)
                        
                    }.allowsHitTesting(viewModel.canTapCards)
                    
                    if viewModel.cards.isEmpty {
                        startAgainButton
                    }
                }
            }
            if differentiateWithoutColor || accessibilityEnabled {
                differentiateWithoutColorView
            }
        }
        .sheet(isPresented: $isShowingEditScreen, onDismiss: viewModel.resetCards) { AddCardsScreen(size: geo.size).environmentObject(viewModel) }
        .sheet(isPresented: $isShowingSettingsScreen, onDismiss: viewModel.resetCards) { SettingsView() }
        .onAppear(perform: viewModel.resetCards)
        .onReceive(viewModel.timer) { _ in viewModel.timerAction() }
        .onReceive(applicationWillEnterBackground) { _ in viewModel.stopTimer() }
        .onReceive(applicationEnterForeground) { _ in viewModel.resumeTimer() }
        }
    }
    
    var applicationWillEnterBackground: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
    }
    
    var applicationEnterForeground: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
    }
    
    var differentiateWithoutColorView: some View {
        VStack {
            Spacer()
            
            HStack {
                Button { withAnimation {
                    viewModel.removeCard(at: viewModel.cards.count - 1, answerIsCorrect: .wrong) }
                } label : {
                    Image(systemName: "xmark.circle")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .clipShape(Circle())
                }
                .accessibility(label: Text("Wrong"))
                .accessibility(hint: Text("Mark your answer as incorect"))
                
                Spacer()
                
                Button { withAnimation {
                    viewModel.removeCard(at: viewModel.cards.count - 1, answerIsCorrect: .correct)}
                } label: {
                    Image(systemName: "checkmark.circle")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .clipShape(Circle())
                }
                .accessibility(label: Text("Correct"))
                .accessibility(hint: Text("Mark your answer as correct one"))
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            
            Spacer()
        }
    }
    
    var backgroundImage: some View {
        Image(decorative: "background")
            .resizable()
            .scaledToFill()
            .edgesIgnoringSafeArea(.all)
    }
    
    var startAgainButton: some View {
        Button(viewModel.cardsLoadedFromAppStorage ? "Start again" : "New Game", action: viewModel.cardsLoadedFromAppStorage ? viewModel.resetCards : showEditCards)
            .padding()
            .background(Color.white)
            .foregroundColor(.black)
            .clipShape(Capsule())
    }
    
    
    
    func showEditCards() {
        isShowingEditScreen = true
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameScreen()
    }
}







