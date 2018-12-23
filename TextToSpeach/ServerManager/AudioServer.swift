//
//  AudioServer.swift
//  TextToSpeach
//
//  Created by Nathan Ranghel on 23/12/18.
//  Copyright © 2018 Nathan Ranghel. All rights reserved.
//

import Speech

class AudioServer: NSObject, SFSpeechRecognizerDelegate {
    
    public static let share = AudioServer()
    
    public let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "pt-BR"))  //1
    public var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    public var recognitionTask: SFSpeechRecognitionTask?
    public let audioEngine = AVAudioEngine()
    
    
    override private init(){
        super.init()
        setupSpeech(completion: { success in })
    }
    
    public func setupSpeech(completion: @escaping(Bool) -> Void){
        //        micphoneButton.isEnabled = false  //2
        speechRecognizer?.delegate = self  //3
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            var isButtonEnabled = false
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            //            OperationQueue.main.addOperation() {
            //                self.micphoneButton.isEnabled = isButtonEnabled
            completion(isButtonEnabled)
            //            }
        }
    }
    
    
    public func startRecording(completion: @escaping(_ isFinal: Bool, _ getText: String) -> Void) {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
//           try audioSession.setCategory(AVAudioSession.Category.record, mode: <#T##AVAudioSession.Mode#>, policy: <#T##AVAudioSession.RouteSharingPolicy#>, options: <#T##AVAudioSession.CategoryOptions#>)
         //try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode as AVAudioInputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch let err {
            print("audioEngine couldn't start because of an error: \(err)")
        }
        //        textView.text = placeHolder
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            var getTxt = ""
            print("recognitionRequest isFinal = \(isFinal)") // TODO: rmeove this!!!
            if result != nil {  // MARK: -  get current result and put into textView
                getTxt = result?.bestTranscription.formattedString ?? ""
                print("[AUDIO] audioServer get result text = \(getTxt)")
                //                self.textView.text = getTxt
                isFinal = (result?.isFinal)!
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                //                self.micphoneButton.isEnabled = true
            }
            
            completion(isFinal, getTxt)
        })
        
    }
    
    public func stopRecording(){
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        //        micphoneButton.isEnabled = available
        print("SFSpeechRecognizer, availabilityDidChange available = \(available)")
    }
    
    
    
}
