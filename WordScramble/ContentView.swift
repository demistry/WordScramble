//
//  ContentView.swift
//  WordScramble
//
//  Created by David Ilenwabor on 30/10/2019.
//  Copyright © 2019 Davidemi. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var ErrorTitle = ""
    @State private var ErrorMessage = ""
    @State private var isErrorShown = false
    var body: some View {
        NavigationView{
            VStack{
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                List(usedWords, id: \.self){
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }.navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
                .alert(isPresented: $isErrorShown){
                    Alert(title: Text(ErrorTitle), message: Text(ErrorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else{
            return
        }
        
        guard isOriginal(word: answer) else{
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else{
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isRealWord(word: answer) else{
            wordError(title: "Word not possible", message: "That isn't a real word")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame(){
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsUrl){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
            
            fatalError("Could not load start.txt from bundle")
        }
    }
    
    func isOriginal(word : String)->Bool{
        !usedWords.contains(word)
    }
    
    func isPossible(word : String)->Bool{
        var tempword = rootWord.lowercased()
        
        for letter in word{
            if let pos = tempword.firstIndex(of: letter){
                tempword.remove(at: pos)
            } else{
                return false
            }
        }
        
        return true
    }
    
    func isRealWord(word : String)->Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title : String, message : String){
        ErrorTitle = title
        ErrorMessage = message
        isErrorShown = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
