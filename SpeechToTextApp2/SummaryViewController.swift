//
//  SummaryViewController.swift
//  SpeechToTextApp2
//
//  Created by Daniel Woldetsadik on 8/4/25.
//

import UIKit

class SummaryViewController: UIViewController {

    @IBAction func saveSummaryTapped(_ sender: UIButton) {
        
        guard let summaryText = summaryText, !summaryText.isEmpty else { return }
            
            // Create a new transcription with the summary
            let newTranscription = Transcription(
                id: UUID(),
                originalText: summaryText,
                text: summaryText,
                date: Date(),
                edits: [],
                type: .translation
            )
            
            // Load existing transcriptions and add the new one
            var allTranscriptions = TranscriptionStorage.loadTranscriptions()
            allTranscriptions.insert(newTranscription, at: 0)
            TranscriptionStorage.saveTranscriptions(allTranscriptions)
        
       
        // 2) Programmatically tell Home to reload right now
        if let tabs = tabBarController?.viewControllers,
           let homeNav = tabs.first as? UINavigationController,
           let homeVC = homeNav.viewControllers.first as? ViewController {
            homeVC.transcriptions = TranscriptionStorage.loadTranscriptions()
            homeVC.tableView.reloadData()
        }

            
            // Show success alert
        let alert = UIAlertController(title: "Saved", message: "Summary saved to home.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                // ① Switch to the first (home) tab:
                self.tabBarController?.selectedIndex = 0
            })
            present(alert, animated: true)
    }
    
    
    @IBOutlet weak var textView: UITextView!
    var summaryText: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        textView.text = summaryText
        
        

        // Do any additional setup after loading the view.
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
