//
//  GameViewModel.swift
//  Flashzilla
//
//  Created by Roman Kavinskyi on 7/15/21.
//

import SwiftUI
import CoreHaptics


final class GameViewModel: ObservableObject {
    @AppStorage("Cards")    var cardsData       : Data?
    @AppStorage("AskAgain") var shouldAskAgain  = false
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    @Published var cards                     = [Card]()
    @Published var timeRemaining             = 100
    @Published var engine                    : CHHapticEngine?
    @Published var askAgain                  = false
    @Published var isActive                  = true
    @Published var cardsLoadedFromAppStorage = false
    @Published var canTapCards               = true
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var timeLabel: String {
        if !cardsLoadedFromAppStorage {
            return "Have fun!"
        }
        if timeRemaining > 0 {
            return "Time: \(timeRemaining)"
        } else {
            complexHaptic()
            return "Time's out"
        }
    }
    
    func resumeTimer() {
        guard !cards.isEmpty else { return }
        isActive = true
    }
    
    func stopTimer() {
        isActive = false
    }
    
    func timerAction() {
        guard isActive else { return }
        if timeRemaining > 0 {
            timeRemaining -= 1
            guard timeRemaining == 1 else { return }
            prepareHapticEngine()
        }
    }
    
    func prepareHapticEngine() {
        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func removeCard(at index: Int, answerIsCorrect: AnswerValidation) {
        guard index >= 0 else { return }
        if askAgain && answerIsCorrect == .wrong {
            guard cards.count != 0 else { return }
            canTapCards = false
            let card = cards[index]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {  [self] in
                cards.insert(card, at: 0)
                canTapCards = true
                isActive    = true // if it's a last card it will resume a timer
            }
        }
        cards.remove(at: index)
        if cards.isEmpty {
            isActive = false
        }
    }
    
    func timesOutRemoveAllCards(time: Int) {
        if timeRemaining == 0 {
            canTapCards = false
            withAnimation {
                cards.removeAll()
            }
        }
    }
    
    func resetCards() {
        timeRemaining   = 100
        canTapCards     = true
        isActive        = true
        loadFromUserDefaults()
    }
    
    func loadFromUserDefaults() {
        guard let cardsData = cardsData else { return }
        do {
            cards = try JSONDecoder().decode([Card].self, from: cardsData)
            askAgain = shouldAskAgain
            cardsLoadedFromAppStorage = true
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func complexHaptic() {
        // make sure that the device supports haptics
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        // create one intense, sharp tap
        for i in stride(from: 0, to: 1, by: 0.1) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(i))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            events.append(event)
        }
        
        for i in stride(from: 0, to: 1, by: 0.1) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1 - i))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 1 + i)
            events.append(event)
        }
        
        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
            
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}
