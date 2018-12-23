//
//  SpeachTextVC.swift
//  TextToSpeach
//
//  Created by Nathan Ranghel on 23/12/18.
//  Copyright © 2018 Nathan Ranghel. All rights reserved.
//

import UIKit

class SpeachTextVC: UIViewController {
    
    
    func updateTableContentInset() {
        let numRows = tableView(self.tableView, numberOfRowsInSection: 0)
        var contentInsetTop = self.tableView.bounds.size.height
        for i in 0..<numRows {
            let rowRect = self.tableView.rectForRow(at: IndexPath(item: i, section: 0))
            contentInsetTop -= rowRect.size.height
            if contentInsetTop <= 0 {
                contentInsetTop = 0
            }
        }
        self.tableView.contentInset = UIEdgeInsets(top: contentInsetTop, left: 0, bottom: 0, right: 0)
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.sentences.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    let placeHolder = "clicke no botao e diga algo"
    
    lazy var textView : UITextView = {
        let t = UITextView()
        t.delegate = self
        t.font = UIFont.systemFont(ofSize: 26)
        t.layer.borderColor = UIColor.lightGray.cgColor
        t.layer.borderWidth = 1
        t.layer.cornerRadius = 20
        return t
    }()
    
    var timer: Timer!
    var lastText: String = ""
    var sentences: [Sentence] = []
    
    let tableView = UITableView()
    let cellId = "tableCellId"
    
    lazy var micphoneButton : UIButton = {
        let b = UIButton()
        b.addTarget(self, action: #selector(micphonButtonTapped), for: .touchUpInside)
        b.setImage(#imageLiteral(resourceName: "micphone"), for: .normal)
        b.contentMode = .scaleAspectFill
        b.layer.cornerRadius = 25
        b.layer.masksToBounds = true
        return b
    }()
    
    var pulsatingLayer: CAShapeLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupButtonPulsLayer()
        setupMicphoneButton()
        setupTextView()
        
        setupTableView()
        
        
        setupTimer()
        
        AudioServer.share.setupSpeech { (success) in
            //
        }
    }
    
    private func setupTextView(){
        textView.text = placeHolder
        textView.allowsEditingTextAttributes = false
        textView.isUserInteractionEnabled = true
        view.addSubview(textView)
        textView.addConstraints(left: view.leftAnchor, top: nil, right: view.rightAnchor, bottom: micphoneButton.topAnchor, leftConstent: 10, topConstent: 20, rightConstent: 10, bottomConstent: 20, width: 0, height: 40)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(SentenceTableCell.self, forCellReuseIdentifier: cellId)
        view.addSubview(tableView)
        
        
        
        let transition = CATransition()
        transition.type = CATransitionType.push
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.fillMode = CAMediaTimingFillMode.forwards
        transition.duration = 0.5
        transition.subtype = CATransitionSubtype.fromTop
        self.tableView.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
        // Update your data source here
        
        
        tableView.addConstraints(left: view.leftAnchor, top: view.topAnchor, right: view.rightAnchor, bottom: textView.topAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 0, width: 0, height: 0)
    }
    
    private func setupMicphoneButton(){
        view.addSubview(micphoneButton)
        micphoneButton.addConstraints(left: nil, top: nil, right: nil, bottom: view.bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 35, width: 50, height: 50)
        micphoneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupButtonPulsLayer() {
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 30, startAngle: -CGFloat.pi / 2.0, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        // startAngle: [ -pi/2: 0'oclock, 0: 3'oclock, pi/2 = 6'oclock]
        
        // add pulsatingLayer:
        pulsatingLayer = CAShapeLayer()
        pulsatingLayer.path = circularPath.cgPath
        pulsatingLayer.strokeColor = UIColor.clear.cgColor // line color
        pulsatingLayer.fillColor = UIColor.orange.cgColor // in circle color
        view.layer.addSublayer(pulsatingLayer)
        pulsatingLayer.position = CGPoint(x: view.center.x, y: view.bounds.height - 60)
        
        animatePulsatingLayer()
    }
    
    private func animatePulsatingLayer() {
        let animate = CABasicAnimation(keyPath: "transform.scale")
        animate.toValue = 1.2
        animate.duration = 2.0
        animate.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animate.repeatCount = Float(Int.max)
        animate.autoreverses = true
        pulsatingLayer.add(animate, forKey: "pulsing")
    }
    
    internal func setupTimer() {
        if timer != nil {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(checkVoiceText), userInfo: nil, repeats: true)
    }
    
    @objc func checkVoiceText() {
        if AudioServer.share.audioEngine.isRunning {
            if let newText = self.textView.text, !newText.isEmpty, newText == self.lastText { // finished
                print("[TIMER] 1. timeup, textView.text = \(newText), lastText = \(self.lastText)")
                //self.micphonButtonTapped() // stop recording
                self.sentences.append(Sentence(string: newText))
                self.tableViewReloadData()
                
                self.textView.text = ""
                //self.micphonButtonTapped() // start recording again
                
            } else {
                self.lastText = self.textView.text
            }
        } else {
            //print("[TIMER] 0. AudioEngine is NOT running.")
        }
    }
    
    internal func tableViewReloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("get error: didReceiveMemoryWarning()...")
    }
}


extension SpeachTextVC {
    
    @objc func micphonButtonTapped() {
        if AudioServer.share.audioEngine.isRunning {
            print("[AUDIO] ------ stop ------")
            AudioServer.share.stopRecording()
            micphoneButton.setImage(#imageLiteral(resourceName: "micphone"), for: .normal)
            pulsatingLayer.fillColor = UIColor.orange.cgColor
            lastText = ""
        } else {
            print("[AUDIO] ------ start ------")
            AudioServer.share.startRecording(completion: { (isFinal, getText) in
                self.textView.text = getText
            })
            micphoneButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            pulsatingLayer.fillColor = UIColor.yellow.cgColor
        }
    }
    
    
}

extension SpeachTextVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        print("[GET] textViewDidChange: text = \(textView.text)")
    }
    
}



extension SpeachTextVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sentences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SentenceTableCell
        cell.sentence = sentences[indexPath.row]
        cell.selectionStyle = .none
        print("[TABLEVIEW] setup cell sentence = \(cell.sentence!)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

extension SpeachTextVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let approximateWidthOfTextView = view.frame.width - 40
        let sz = CGSize(width: approximateWidthOfTextView, height: 600)
        let atts = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        let estimateFrame = NSString(string: sentences[indexPath.row].string).boundingRect(with: sz, options: .usesLineFragmentOrigin, attributes: atts, context: nil)
        return estimateFrame.height + 50
    }
    
    
}


