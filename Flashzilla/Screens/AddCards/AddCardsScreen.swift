//
//  EditCards.swift
//  Flashzilla
//
//  Created by Roman Kavinskyi on 7/14/21.
//

import SwiftUI

struct AddCardsScreen: View {
    @EnvironmentObject var viewModel: GameViewModel
   
    @Environment(\.presentationMode) var presentationMode
   
    @State private var question = ""
    @State private var answer   = ""
   
    
    var body: some View {
        NavigationView{
            List {
                Section(header: Text("Card prompt and answer")) {
                    TextField("Prompt", text: $question)
                    
                    TextField("Answer", text: $answer)
                    Button("Add", action: addCard)
                }
                Section(header: Text("Your cards")) {
                    ForEach(viewModel.cards) { card in
                        Text(card.prompt)
                            .font(.headline)
                        Text(card.answer)
                            .foregroundColor(.secondary)
                    }
                    .onDelete(perform: deleteCard)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        
        .onAppear(perform: loadCardFromUserDefaults)
    }
    
    func addCard() {
        let trimmedPrompt = question.trimmingCharacters(in: .whitespaces)
        let trimmedAnswer = answer.trimmingCharacters(in: .whitespaces)
        guard trimmedPrompt.isEmpty == false && trimmedAnswer.isEmpty == false else { return }
        let card = Card(prompt: trimmedPrompt, answer: trimmedAnswer)
        viewModel.cards.insert(card, at: 0)
        saveToUserDefaults()
    }
    
    func deleteCard(at offsets: IndexSet) {
        viewModel.cards.remove(atOffsets: offsets)
        saveToUserDefaults()
    }
    
    func saveToUserDefaults() {
        do {
            viewModel.cardsData = try JSONEncoder().encode(viewModel.cards)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadCardFromUserDefaults() {
        guard let cardsData = viewModel.cardsData else { return }
        do {
            viewModel.cards = try JSONDecoder().decode([Card].self, from: cardsData)
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct EditCards_Previews: PreviewProvider {
    static var previews: some View {
        AddCardsScreen()
    }
}
