//
//  Siri.swift
//  TextToSpeach
//
//  Created by Nathan Ranghel on 27/12/18.
//  Copyright © 2018 Nathan Ranghel. All rights reserved.
//

import AVFoundation
class Siri {
    
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    func siriSpeak(theText: String) {
        
        myUtterance = AVSpeechUtterance(string: theText)
        myUtterance.rate = 0.5
        myUtterance.pitchMultiplier = 1.3
        myUtterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        synth.speak(myUtterance)
    }
    
}
