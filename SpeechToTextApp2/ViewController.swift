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

        let currentTranscription = transcriptions[indexPath.row]

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TranscriptCell")

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
        return cell
    
    }
    
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        
            let deletedTranscription = transcriptions[indexPath.row]
            transcriptions.remove(at: indexPath.row)
            TranscriptionStorage.saveTranscriptions(transcriptions)
            
            // Delete the row from table view with animation
            tableView.deleteRows(at: [indexPath], with: .fade)
           
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }

    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
                tableView.delegate = self
     
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

