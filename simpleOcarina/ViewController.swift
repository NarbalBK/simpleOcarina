//
//  ViewController.swift
//  simpleOcarina
//
//  Created by Péricles Narbal on 16/06/19.
//  Copyright © 2019 Péricles Narbal. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var ocarina: UIImageView!
    
    @IBOutlet weak var buttonInfDir: UIButton!
    @IBOutlet weak var buttonSupDir: UIButton!
    @IBOutlet weak var buttonInfEsq: UIButton!
    @IBOutlet weak var buttonSupEsq: UIButton!
    
    var buttonInfDirCicle: UIImageView?
    var buttonSupDirCicle: UIImageView?
    var buttonInfEsqCicle: UIImageView?
    var buttonSupEsqCicle: UIImageView?
    
    @IBOutlet weak var switchWind: UISwitch!
    @IBOutlet weak var imageWind: UIImageView!
    
    var recorder: AVAudioRecorder?
    let audioSession = AVAudioSession.sharedInstance()
    var levelTimer: Timer? = nil
    var level: Float?
    let clip: Float = -10.0
    var audioPlayer: AVAudioPlayer?
    var note: Int?
    
    var activeCall: Bool = false
    var activePlay: Bool = false
    
    var references: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(ocarina)
        setConstraintsForOcarina()
        
        view.addSubview(buttonInfDir)
        view.addSubview(buttonSupDir)
        view.addSubview(buttonInfEsq)
        view.addSubview(buttonSupEsq)
        setConstraintsForOcarinaButtons()
        
        buttonInfDirCicle = UIImageView(image: nil)
        buttonSupDirCicle = UIImageView(image: nil)
        buttonInfEsqCicle = UIImageView(image: nil)
        buttonSupEsqCicle = UIImageView(image: nil)
        view.addSubview(buttonInfDirCicle!)
        view.addSubview(buttonSupDirCicle!)
        view.addSubview(buttonInfEsqCicle!)
        view.addSubview(buttonSupEsqCicle!)
        
        setConstraintsForButtonsCicle()
        settingsForOcarinaButtons()
        
        view.addSubview(switchWind)
        view.addSubview(imageWind)
        
        settingsForScreenButtons()
        
        let url = directoryUrl()
        let recordSettings = recordConfig()
        audioSessionStart()
        recordStart(url, recordSettings)
        recordMonitorStart()
        audioPlayer = AVAudioPlayer()
        references = ["C", "D", "E", "F", "G", "A", "B", "C6", "Bb", "Ab", "Gb"]
        
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func levelTimerCallback() {
        recorder!.updateMeters()
        level = recorder!.averagePower(forChannel: 0)
        if ((level! > clip) || (activeCall)){
            DispatchQueue.main.async {
                self.ocarinaEngine()
            }
        }else{
            if activePlay{
                self.audioPlayer?.stop()
            }
        }
    }
    
    func setConstraintsForOcarina(){
        ocarina?.translatesAutoresizingMaskIntoConstraints = false
        ocarina.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ocarina.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -33).isActive = true
        ocarina?.widthAnchor.constraint(equalToConstant: CGFloat(400)).isActive = true
        ocarina?.heightAnchor.constraint(equalToConstant: CGFloat(500)).isActive = true
    }
    
    func setConstraintsForOcarinaButtons(){
        
        let sizeMultiplier = 0.8
        
        buttonInfDir?.translatesAutoresizingMaskIntoConstraints = false
        buttonInfDir?.centerXAnchor.constraint(equalTo: ocarina!.centerXAnchor, constant: 63).isActive = true
        buttonInfDir?.centerYAnchor.constraint(equalTo: ocarina!.centerYAnchor, constant: 30).isActive = true
        buttonInfDir?.widthAnchor.constraint(equalToConstant: CGFloat(71*sizeMultiplier)).isActive = true
        buttonInfDir?.heightAnchor.constraint(equalToConstant: CGFloat(71*sizeMultiplier)).isActive = true
        
        buttonSupDir?.translatesAutoresizingMaskIntoConstraints = false
        buttonSupDir?.centerXAnchor.constraint(equalTo: ocarina!.centerXAnchor, constant: 72).isActive = true
        buttonSupDir?.centerYAnchor.constraint(equalTo: ocarina!.centerYAnchor, constant: -78).isActive = true
        buttonSupDir?.widthAnchor.constraint(equalToConstant: CGFloat(56*sizeMultiplier)).isActive = true
        buttonSupDir?.heightAnchor.constraint(equalToConstant: CGFloat(56*sizeMultiplier)).isActive = true
        
        buttonInfEsq?.translatesAutoresizingMaskIntoConstraints = false
        buttonInfEsq?.centerXAnchor.constraint(equalTo: ocarina!.centerXAnchor, constant: -65).isActive = true
        buttonInfEsq?.centerYAnchor.constraint(equalTo: ocarina!.centerYAnchor, constant: 30).isActive = true
        buttonInfEsq?.widthAnchor.constraint(equalToConstant: CGFloat(95*sizeMultiplier)).isActive = true
        buttonInfEsq?.heightAnchor.constraint(equalToConstant: CGFloat(94*sizeMultiplier)).isActive = true
        
        buttonSupEsq?.translatesAutoresizingMaskIntoConstraints = false
        buttonSupEsq?.centerXAnchor.constraint(equalTo: ocarina!.centerXAnchor, constant: -70).isActive = true
        buttonSupEsq?.centerYAnchor.constraint(equalTo: ocarina!.centerYAnchor, constant: -76).isActive = true
        buttonSupEsq?.widthAnchor.constraint(equalToConstant: CGFloat(82*sizeMultiplier)).isActive = true
        buttonSupEsq?.heightAnchor.constraint(equalToConstant: CGFloat(83*sizeMultiplier)).isActive = true
    }
    
    func setConstraintsForButtonsCicle(){
        
        let sizeMultiplier = 1.2
        
        buttonInfDirCicle?.translatesAutoresizingMaskIntoConstraints = false
        buttonInfDirCicle?.centerXAnchor.constraint(equalTo: ocarina!.centerXAnchor, constant: 66).isActive = true
        buttonInfDirCicle?.centerYAnchor.constraint(equalTo: ocarina!.centerYAnchor, constant: 33).isActive = true
        buttonInfDirCicle?.widthAnchor.constraint(equalToConstant: CGFloat(73*sizeMultiplier)).isActive = true
        buttonInfDirCicle?.heightAnchor.constraint(equalToConstant: CGFloat(73*sizeMultiplier)).isActive = true
        
        buttonSupDirCicle?.translatesAutoresizingMaskIntoConstraints = false
        buttonSupDirCicle?.centerXAnchor.constraint(equalTo: ocarina!.centerXAnchor, constant: 74).isActive = true
        buttonSupDirCicle?.centerYAnchor.constraint(equalTo: ocarina!.centerYAnchor, constant: -76).isActive = true
        buttonSupDirCicle?.widthAnchor.constraint(equalToConstant: CGFloat(64*sizeMultiplier)).isActive = true
        buttonSupDirCicle?.heightAnchor.constraint(equalToConstant: CGFloat(64*sizeMultiplier)).isActive = true
        
        buttonInfEsqCicle?.translatesAutoresizingMaskIntoConstraints = false
        buttonInfEsqCicle?.centerXAnchor.constraint(equalTo: ocarina!.centerXAnchor, constant: -61).isActive = true
        buttonInfEsqCicle?.centerYAnchor.constraint(equalTo: ocarina!.centerYAnchor, constant: 32).isActive = true
        buttonInfEsqCicle?.widthAnchor.constraint(equalToConstant: CGFloat(95*sizeMultiplier)).isActive = true
        buttonInfEsqCicle?.heightAnchor.constraint(equalToConstant: CGFloat(94*sizeMultiplier)).isActive = true
        
        buttonSupEsqCicle?.translatesAutoresizingMaskIntoConstraints = false
        buttonSupEsqCicle?.centerXAnchor.constraint(equalTo: ocarina!.centerXAnchor, constant: -68).isActive = true
        buttonSupEsqCicle?.centerYAnchor.constraint(equalTo: ocarina!.centerYAnchor, constant: -74).isActive = true
        buttonSupEsqCicle?.widthAnchor.constraint(equalToConstant: CGFloat(86*sizeMultiplier)).isActive = true
        buttonSupEsqCicle?.heightAnchor.constraint(equalToConstant: CGFloat(87*sizeMultiplier)).isActive = true
    }
    
    func settingsForOcarinaButtons(){
        buttonInfDir?.setImage(UIImage(named: "buttonInfDir"), for: .normal)
        buttonInfDir?.addTarget(self, action: #selector(buttonInfDirAction), for: .touchDown)
        buttonInfDir?.addTarget(self, action: #selector(buttonInfDirStop), for: .touchUpInside)
        buttonInfDir?.addTarget(self, action: #selector(buttonInfDirStop), for: .touchDragExit)
        
        buttonSupDir?.setImage(UIImage(named: "buttonSupDir"), for: .normal)
        buttonSupDir?.addTarget(self, action: #selector(buttonSupDirAction), for: .touchDown)
        buttonSupDir?.addTarget(self, action: #selector(buttonSupDirStop), for: .touchUpInside)
        buttonSupDir?.addTarget(self, action: #selector(buttonSupDirStop), for: .touchDragExit)
        
        buttonInfEsq?.setImage(UIImage(named: "buttonInfEsq"), for: .normal)
        buttonInfEsq?.addTarget(self, action: #selector(buttonInfEsqAction), for: .touchDown)
        buttonInfEsq?.addTarget(self, action: #selector(buttonInfEsqStop), for: .touchUpInside)
        buttonInfEsq?.addTarget(self, action: #selector(buttonInfEsqStop), for: .touchDragExit)
        
        
        buttonSupEsq?.setImage(UIImage(named: "buttonSupEsq"), for: .normal)
        buttonSupEsq?.addTarget(self, action: #selector(buttonSupEsqAction), for: .touchDown)
        buttonSupEsq?.addTarget(self, action: #selector(buttonSupEsqStop), for: .touchUpInside)
        buttonSupEsq?.addTarget(self, action: #selector(buttonSupEsqStop), for: .touchDragExit)
    }
    
    
    @objc func buttonInfDirAction(){
        DispatchQueue.main.async {
            self.buttonInfDirCicle?.image = UIImage(named: "buttonInfDirCicle")
        }
        
    }
    
    @objc func buttonSupDirAction(){
        DispatchQueue.main.async {
             self.buttonSupDirCicle?.image = UIImage(named: "buttonSupDirCicle")
        }
       
        
    }
    
    @objc func buttonInfEsqAction(){
        DispatchQueue.main.async {
            self.buttonInfEsqCicle?.image = UIImage(named: "buttonInfEsqCicle")
        }
        
    }
    
    @objc func buttonSupEsqAction(){
        DispatchQueue.main.async {
            self.buttonSupEsqCicle?.image = UIImage(named: "buttonSupEsqCicle")
        }
        
    }
    
    @objc func buttonInfDirStop(){
        DispatchQueue.main.async {
            self.buttonInfDirCicle?.image = nil
        }
        
    }
    
    @objc func buttonSupDirStop(){
        DispatchQueue.main.async {
            self.buttonSupDirCicle?.image = nil
        }
        
        
    }
    
    @objc func buttonInfEsqStop(){
        DispatchQueue.main.async {
            self.buttonInfEsqCicle?.image = nil
        }
        
        
    }
    
    @objc func buttonSupEsqStop(){
        DispatchQueue.main.async {
            self.buttonSupEsqCicle?.image = nil
        }
        
    }
    
    func directoryUrl () -> URL{
        let documents = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
        let url = documents.appendingPathComponent("record.caf")
        
        return url
    }
    
    func recordConfig() -> [String: Any]{
        let recordSettings: [String: Any] = [
            AVFormatIDKey:              kAudioFormatAppleIMA4,
            AVSampleRateKey:            44100.0,
            AVNumberOfChannelsKey:      2,
            AVEncoderBitRateKey:        12800,
            AVLinearPCMBitDepthKey:     16,
            AVEncoderAudioQualityKey:   AVAudioQuality.max.rawValue
        ]
        return recordSettings
    }
    
    func audioSessionStart(){
        try? self.audioSession.setCategory(AVAudioSession.Category.playAndRecord)
        try? self.audioSession.setActive(true)
        try? self.audioSession.overrideOutputAudioPort(.speaker)
    }
    
    func recordStart(_ url: URL,_ recordSettings: [String: Any]) {
        try? self.recorder = AVAudioRecorder(url: url, settings: recordSettings)
        if self.recorder != nil{
            self.recorder!.prepareToRecord()
            self.recorder!.isMeteringEnabled = true
            self.recorder!.record()
        }
    }
    
    func recordMonitorStart(){
        DispatchQueue.main.async {
            if self.levelTimer == nil {
                self.levelTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.levelTimerCallback), userInfo: nil, repeats: true)
            }
        }
    }
    
    func recordMonitorStop(){
        if self.levelTimer != nil {
            self.levelTimer!.invalidate()
            self.levelTimer = nil
        }
    }
    
    func ocarinaEngine(){
        if (((buttonInfDirCicle?.image) != nil) && ((buttonSupDirCicle?.image) != nil) && ((buttonInfEsqCicle?.image) != nil) && ((buttonSupEsqCicle?.image) != nil)){
            print ("C")
            if !activePlay {
                self.play(note: 1)
                self.note = 1
            }else{
                if ((!(audioPlayer!.isPlaying)) || (self.note! != 1)){
                    self.play(note: 1)
                    self.note = 1
                }
            }
            
        }
            
        else if (((buttonInfDirCicle?.image) != nil) && ((buttonSupDirCicle?.image) == nil) && ((buttonInfEsqCicle?.image) != nil) && ((buttonSupEsqCicle?.image) != nil)){
            print ("D")
            if !activePlay {
                self.play(note: 2)
                self.note = 2
            }else{
                if ((!(audioPlayer!.isPlaying)) || (self.note! != 2)){
                    self.play(note: 2)
                    self.note = 2
                }
            }
            
        }
            
        else if (((buttonInfDirCicle?.image) == nil) && ((buttonSupDirCicle?.image) != nil) && ((buttonInfEsqCicle?.image) != nil) && ((buttonSupEsqCicle?.image) != nil)){
            print ("E")
            if !activePlay {
                self.play(note: 3)
                self.note = 3
            }else{
                if ((!(audioPlayer!.isPlaying)) || (self.note! != 3)){
                    self.play(note: 3)
                    self.note = 3
                }
            }
            
        }
            
        else if (((buttonInfDirCicle?.image) == nil) && ((buttonSupDirCicle?.image) == nil) && ((buttonInfEsqCicle?.image) != nil) && ((buttonSupEsqCicle?.image) != nil)){
            print ("F")
            if !activePlay {
                self.play(note: 4)
                self.note = 4
            }else{
                if ((!(audioPlayer!.isPlaying)) || (self.note! != 4)){
                    self.play(note: 4)
                    self.note = 4
                }
            }
            
        }
            
        else if (((buttonInfDirCicle?.image) != nil) && ((buttonSupDirCicle?.image) == nil) && ((buttonInfEsqCicle?.image) != nil) && ((buttonSupEsqCicle?.image) == nil)){
            print ("G")
            if !activePlay {
                self.play(note: 5)
                self.note = 5
            }else{
                if ((!(audioPlayer!.isPlaying)) || (self.note! != 5)){
                    self.play(note: 5)
                    self.note = 5
                }
            }
            
        }
            
        else if (((buttonInfDirCicle?.image) == nil) && ((buttonSupDirCicle?.image) == nil) && ((buttonInfEsqCicle?.image) != nil) && ((buttonSupEsqCicle?.image) == nil)){
            print ("A")
            if !activePlay {
                self.play(note: 6)
                self.note = 6
            }else{
                if ((!(audioPlayer!.isPlaying)) || (self.note! != 6)){
                    self.play(note: 6)
                    self.note = 6
                }
            }
            
        }
            
        else if (((buttonInfDirCicle?.image) == nil) && ((buttonSupDirCicle?.image) != nil) && ((buttonInfEsqCicle?.image) == nil) && ((buttonSupEsqCicle?.image) == nil)){
            print ("B")
            if !activePlay {
                self.play(note: 7)
                self.note = 7
            }else{
                if ((!(audioPlayer!.isPlaying)) || (self.note! != 7)){
                    self.play(note: 7)
                    self.note = 7
                }
            }
            
        }
            
        else if (((buttonInfDirCicle?.image) == nil) && ((buttonSupDirCicle?.image) == nil) && ((buttonInfEsqCicle?.image) == nil) && ((buttonSupEsqCicle?.image) == nil)){
            print ("C6")
            if !activePlay {
                self.play(note: 8)
                self.note = 8
            }else{
                if ((!(audioPlayer!.isPlaying)) || (self.note! != 8)){
                    self.play(note: 8)
                    self.note = 8
                }
            }
        }
        
        else if (((buttonInfDirCicle?.image) != nil) && ((buttonSupDirCicle?.image) == nil) && ((buttonInfEsqCicle?.image) == nil) && ((buttonSupEsqCicle?.image) == nil)){
            print ("Bb")
            if !activePlay {
                self.play(note: 9)
                self.note = 9
            }else{
                if ((!(audioPlayer!.isPlaying)) || (self.note! != 9)){
                    self.play(note: 9)
                    self.note = 9
                }
            }
            
        }
        
        else if (((buttonInfDirCicle?.image) == nil) && ((buttonSupDirCicle?.image) != nil) && ((buttonInfEsqCicle?.image) != nil) && ((buttonSupEsqCicle?.image) == nil)){
            print ("Ab")
            if !activePlay {
                self.play(note: 10)
                self.note = 10
            }else{
                if ((!(audioPlayer!.isPlaying)) || (self.note! != 10)){
                    self.play(note: 10)
                    self.note = 10
                }
            }
            
        }
        
        else if (((buttonInfDirCicle?.image) != nil) && ((buttonSupDirCicle?.image) != nil) && ((buttonInfEsqCicle?.image) != nil) && ((buttonSupEsqCicle?.image) == nil)){
            print ("Gb")
            if !activePlay {
                self.play(note: 11)
                self.note = 11
            }else{
                if ((!(audioPlayer!.isPlaying)) || (self.note! != 11)){
                    self.play(note: 11)
                    self.note = 11
                }
            }
            
        }
    }
    
    func play(note: Int) {
        let reference = references![note - 1]
        if let path = Bundle.main.path(forResource: reference, ofType: "wav") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                self.audioPlayer?.volume = 0
                self.audioPlayer!.play()
                self.audioPlayer?.setVolume(1, fadeDuration: 1)
                self.activePlay = true
            }catch{
                print(error)
            }
        }
    }
    
    func settingsForScreenButtons(){
        switchWind?.addTarget(self, action: #selector(switchWindAction), for: .valueChanged)
        
    }
    
    @objc func switchWindAction(){
        if switchWind.isOn {
            activeCall = false
        }else{
            activeCall = true
        }
    }
}
