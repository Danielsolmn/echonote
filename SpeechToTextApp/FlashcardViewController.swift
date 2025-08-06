//
//  FlashcardViewController.swift
//  SpeechToTextApp
//
//  Created by Daniel Woldetsadik on 8/1/25.
//

import UIKit

class FlashcardViewController: UIViewController {

   
    @IBOutlet weak var questionLabel: UILabel!
    
    
    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    private var currentIndex = 0
    
    @IBOutlet weak var showAnswerButton: UIButton!
    
    @IBAction func showAnswerTapped(_ sender: UIButton) {
        answerLabel.isHidden.toggle()
        sender.setTitle(answerLabel.isHidden ? "Show Answer" : "Hide Answer" , for: .normal)
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        guard !flashcards.isEmpty else { return }
        currentIndex = (currentIndex + 1) % flashcards.count
                showCard(at: currentIndex)
    }
    
     var flashcards: [Flashcard] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Flashcards"
        // only show if there's at least one card
          if !flashcards.isEmpty {
            showCard(at: currentIndex)
          }
        else {
                    questionLabel.text = "No flashcards available"
                    answerLabel.text = "Please go back and generate some flashcards first."
                    answerLabel.isHidden = false
                    nextButton.isEnabled = false
                   showAnswerButton.isEnabled = false
                }
        // Do any additional setup after loading the view.
    }
    
    
        private func showCard(at i: Int) {
            guard i < flashcards.count else { return }
            let card = flashcards[i]
            questionLabel.text = card.question
            answerLabel.text = card.answer
            answerLabel.isHidden = true
            nextButton.isEnabled = flashcards.count > 1
                        showAnswerButton.isEnabled = true
                        showAnswerButton.setTitle("Show Answer", for: .normal)
                        
                        // Update navigation title to show current card number
                        title = "Flashcard \(i + 1) of \(flashcards.count)"
                    }
    
            
          
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
