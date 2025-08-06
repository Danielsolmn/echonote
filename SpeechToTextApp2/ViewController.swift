//
//  ViewController.swift
//  SpeechToTextApp2
//
//  Created by Daniel Woldetsadik on 8/3/25.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate  {
    
    var transcriptions: [Transcription] = []
    var selectedTranscription: Transcription?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transcriptions.count
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Get the transcription for this row
        let currentTranscription = transcriptions[indexPath.row]

        // Create a cell with subtitle style to show both text and timestamp
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TranscriptCell")

        // Add icon based on type
        let icon = getIconForType(currentTranscription.type)
        let firstLine = currentTranscription.originalText.components(separatedBy: "\n").first ?? "Transcript"
        cell.textLabel?.text = "\(icon) \(firstLine)"

        // Format the date nicely and set it as the subtitle (below the main title)
        let formattedDate = DateFormatter.localizedString(
            from: currentTranscription.date,
            dateStyle: .short,
            timeStyle: .short
        )
        cell.detailTextLabel?.text = formattedDate

        // Return the cell to be displayed in the table view
        return cell
    
    }
    
    // Helper function to get icon
    func getIconForType(_ type: TranscriptionType) -> String {
        switch type {
        case .voice:
            return "🎤"
        case .scan:
            return "📷"
        case .translation:
            return "📝"
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTranscription = transcriptions[indexPath.row]
        performSegue(withIdentifier: "showTranscriptDetail", sender: self)
    }
    
    // Enable swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the transcription from the array
            let deletedTranscription = transcriptions[indexPath.row]
            transcriptions.remove(at: indexPath.row)
            
            // Update storage
            TranscriptionStorage.saveTranscriptions(transcriptions)
            
            // Delete the row from table view with animation
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            print("Deleted transcription: \(deletedTranscription.originalText.prefix(50))...")
        }
    }
    
    // Optional: Customize the delete button text
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }

    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
                tableView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        transcriptions =  TranscriptionStorage.loadTranscriptions()
            tableView.reloadData()
        
        
        }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        transcriptions = TranscriptionStorage.loadTranscriptions()
        tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTranscriptDetail",
               let navController = segue.destination as? UINavigationController,
               let detailVC = navController.topViewController as? TranscriptDetailViewController {
                detailVC.transcription = selectedTranscription
          
           }
       }
   
}

