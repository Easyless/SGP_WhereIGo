import UIKit
import Speech
import CoreLocation

class ViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var micButton: UIButton!
    
    
    var audioController = AudioController()
    var selectedCategory : String = ""
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))!
    private var speechRecognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var isRecord = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var images = [UIImage]()
        let mic1img = UIImage(named: "animatedimg/mic1.png")!
        let mic2img = UIImage(named: "animatedimg/mic2.png")!
        images.append(mic1img)
        images.append(mic2img)
        micButton.imageView!.animationImages = images
        micButton.imageView!.animationDuration = 0.9
        micButton.imageView!.animationRepeatCount = 10
        audioController.preloadAudioEffects(audioFileNames: AudioEffectFiles)
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var speechButtonOutlet: UIButton!
   
    @IBAction func speechButton(_ sender: Any) {
        audioController.playerEffect(name: SoundDing)
        if(!isRecord){
            isRecord = true
            try! startSession()
            
            micButton.imageView?.startAnimating()
        }
        else{
            isRecord = false
            if audioEngine.isRunning{
                audioEngine.stop()
                speechRecognitionRequest?.endAudio()
            }
            micButton.imageView?.stopAnimating()
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
    
    @IBAction func StoreButton(_ sender: Any) {
        selectedCategory = "소매"
    }
    
    @IBAction func EduButton(_ sender: Any) {
        selectedCategory = "학문/교육"
    }
    
    @IBAction func REButton(_ sender: Any) {
        selectedCategory = "부동산"
    }
    
    @IBAction func AllButton(_ sender: Any) {
        selectedCategory = ""
    }
    
    @IBAction func SearchButton(_ sender: Any) {
        selectedCategory = searchBar.text!
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        selectedCategory = searchBar.text!
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "mapView") as! Parsing_Radius
        vc.pascategory = searchBar.text!
        present(vc,animated: true, completion: nil)
        self.view.endEditing(true)
    }
    
}


