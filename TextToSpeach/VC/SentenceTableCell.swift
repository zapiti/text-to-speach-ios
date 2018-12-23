//
//  SentenceTableCell.swift
//  TextToSpeach
//
//  Created by Nathan Ranghel on 23/12/18.
//  Copyright © 2018 Nathan Ranghel. All rights reserved.
//


import UIKit

class SentenceTableCell: UITableViewCell {
    
    let timeLabel: UILabel = {
        let b = UILabel()
        b.textColor = .lightGray
        b.font = UIFont.systemFont(ofSize: 14)
        return b
    }()
    
    let textView: UITextView = {
        let t = UITextView()
        t.font = UIFont.systemFont(ofSize: 16)
        return t
    }()
    
    var sentence: Sentence? {
        didSet {
            updateViewInfoForSentence()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupTimeLabel()
        setupTextView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTimeLabel() {
        addSubview(timeLabel)
        timeLabel.addConstraints(left: leftAnchor, top: topAnchor, right: nil, bottom: nil, leftConstent: 10, topConstent: 10, rightConstent: 0, bottomConstent: 0, width: 0, height: 0)
    }
    
    private func setupTextView() {
        addSubview(textView)
        textView.addConstraints(left: leftAnchor, top: timeLabel.bottomAnchor, right: rightAnchor, bottom: bottomAnchor, leftConstent: 20, topConstent: 0, rightConstent: 20, bottomConstent: 10, width: 0, height: 0)
    }
    
    private func updateViewInfoForSentence() {
        guard let s = sentence else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:MM:SS"
        let d = Date(timeIntervalSince1970: s.timestamp)
        timeLabel.text = formatter.string(from: d)
        textView.text = s.string
    }
    
}
