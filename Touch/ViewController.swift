//
//  ViewController.swift
//  Touch
//
//  Created by Patrick McElroy on 7/18/20.
//  Copyright © 2020 Patrick McElroy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool { return true }
    
    var currentTaps = 0

    @IBOutlet weak var numOnline: UILabel!
    
    @IBAction func tappedScreen(_ sender: Any) {
        currentTaps += 1
        let ref = Database.database().reference()
        ref.child("taps").setValue(currentTaps)
        
        numOnline.font = numOnline.font.withSize(220)
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: {_ in
            self.numOnline.font = self.numOnline.font.withSize(250)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numOnline.text = ""
        let haptic = UIImpactFeedbackGenerator(style: .heavy)
        
        let ref = Database.database().reference()
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {_ in
            ref.child("online/\(self.getUUID())").setValue(self.getTime())
        })
        
        ref.child("online").observe(.value, with: { snapshot in
            self.numOnline.text = String(snapshot.childrenCount)
            if let onlineDictionary = snapshot.value as? NSDictionary {
                for user in onlineDictionary {
                    if user.key as? String != self.getUUID() {
                        if user.value as? Int ?? 0 < self.getTime() - 10 {
                            ref.child("online/\(user.key)").removeValue()
                        }
                    }
                }
            }
        })
        
        ref.child("taps").observe(.value, with: { snapshot in
            if let realTaps = snapshot.value as? Int {
                if self.currentTaps == 0 {
                    self.currentTaps = realTaps
                }
                if self.currentTaps < realTaps {
                    haptic.impactOccurred()
                    self.currentTaps = realTaps
                }
            }
        })
    }
    
    func getUUID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
        
    func getTime() -> Int {
        return Int(Date().timeIntervalSinceReferenceDate)
    }

}

