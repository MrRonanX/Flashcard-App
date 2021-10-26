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
    @State private var chosenImage: UIImage?
    @State private var question = ""
    @State private var answer   = ""
    @State private var isShowingImagePicker = false
    var size: CGSize
    
    
    var body: some View {
        NavigationView{
            List {
                Section(header: Text("Card prompt and answer")) {
                    sectionCell
                }
                Section(header: Text("Your cards")) {
                    ForEach(viewModel.cards) { card in
                        addedCardCell(card)
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
        .sheet(isPresented: $isShowingImagePicker) { ImagePicker(pickedImage: $chosenImage)}
        .onAppear(perform: loadCardFromUserDefaults)
    }
    
    var sectionCell: some View {
        
        HStack {
            VStack{
                TextField("Prompt", text: $question)
                    .font(.title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Answer", text: $answer)
                    .font(.title)
                    .foregroundColor(.secondary)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
                Button("Add", action: addCard)
                    .frame(width: size.width / 5, height: 44)
                    .overlay(RoundedRectangle(cornerRadius: 25.0).stroke(Color.blue, lineWidth: 1.0))
   
            }
            presentImageOrPlaceholder()
                .frame(height: size.width / 5)
                .contentShape(RoundedRectangle(cornerRadius: 25.0))
                .onTapGesture(perform: showImagePicker)
        }
        
    }
    
    func addedCardCell(_ card: Card) -> some View {
        HStack {
            VStack(alignment: .leading){
                Text(card.prompt)
                    .font(.title)
                Text(card.answer)
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if let image = card.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: size.width / 5)
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.secondary, lineWidth: 2))
                    
            }
        }.padding(.horizontal)
    }
    
    
    
    func presentImageOrPlaceholder() -> some View {
        Group {
            if let image = chosenImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.secondary, lineWidth: 2))
            } else {
                RoundedRectangle(cornerRadius: 25).stroke(Color.secondary, lineWidth: 1)
                    .overlay(Text("Add Image"))
            }
        }
        
        
    }
    
    func addCard() {
        let trimmedPrompt = question.trimmingCharacters(in: .whitespaces)
        let trimmedAnswer = answer.trimmingCharacters(in: .whitespaces)
        guard trimmedPrompt.isEmpty == false && trimmedAnswer.isEmpty == false && chosenImage != nil else { return }
        
        let card = Card(prompt: trimmedPrompt, answer: trimmedAnswer)
        saveToDocumentDirectory(imageId: card.id.uuidString)
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
    
    func showImagePicker() {
        isShowingImagePicker = true
    }
    
    func saveToDocumentDirectory(imageId: String) {
        if let image = chosenImage, let data = image.jpegData(compressionQuality: 0.7) {
            print("SAVING....")
            do {
                let filename = getDocumentsDirectory().appendingPathComponent(imageId)
                try data.write(to: filename, options: [[.atomicWrite, .completeFileProtection]])
            } catch {
                print("error saving data")
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
}

struct EditCards_Previews: PreviewProvider {
    static var previews: some View {
        AddCardsScreen(size: CGSize(width: 390, height: 844))
    }
}
