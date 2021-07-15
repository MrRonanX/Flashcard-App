//
//  SettingsView.swift
//  Flashzilla
//
//  Created by Roman Kavinskyi on 7/14/21.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("AskAgain") var shouldAskAgain = false
    @Environment(\.presentationMode) var presentationMode
    @State private var askAgain = false
    @State private var gameTime = 100
    
    var body: some View {
        NavigationView {
            Form {
                Toggle("Ask Again If Answered Incorrectly", isOn: $askAgain)
            }
            .onAppear(perform: loadSettings)
            .navigationTitle("Settings")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: saveSettings)
                }
            }
        }
    }
    
    func saveSettings() {
        shouldAskAgain = askAgain
        presentationMode.wrappedValue.dismiss()
    }
    
    func loadSettings() {
        askAgain = shouldAskAgain
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
