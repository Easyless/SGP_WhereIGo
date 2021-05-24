import UIKit
import Speech

class ViewController: UIViewController {
    
    var selectedCategory : String = ""
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))!
    private var speechRecognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var isRecord = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var speechButtonOutlet: UIButton!
   
    @IBAction func speechButton(_ sender: Any) {
        if(!isRecord){
            isRecord = true
            try! startSession()
        }
        else{
            isRecord = false
            if audioEngine.isRunning{
                audioEngine.stop()
                speechRecognitionRequest?.endAudio()
            }
        }
    }
    
    @IBAction func restorantButton(_ sender: Any) {
        selectedCategory = "음식"
    }
    
    @IBAction func AccommodationButton(_ sender: Any) {
        selectedCategory = "숙박"
    }
    @IBAction func ETCButton(_ sender: Any) {
        selectedCategory = "생활서비스"
    }
    
    func startSession() throws{
        if let recognitionTask = speechRecognitionTask{
            recognitionTask.cancel()
            self.speechRecognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSession.Category.record)
        
        speechRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = speechRecognitionRequest else{
            fatalError("SFSpeechAudioBufferRecognitionRequest object creation failed")
        }
        
        let inputNode = audioEngine.inputNode
        
        recognitionRequest.shouldReportPartialResults = true
        
        speechRecognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest){
            result, error in
            var finished = false
            
            if let result = result{
                self.searchBar.text = result.bestTranscription.formattedString
                finished = result.isFinal
            }
            
            if error != nil || finished{
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.speechRecognitionRequest = nil
                self.speechRecognitionTask = nil
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat){
            (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.speechRecognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is Parsing_Radius{
            let dest = segue.destination as? Parsing_Radius
            dest?.pascategory = self.selectedCategory
        }
    }
}

