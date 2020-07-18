//
//  ViewController.swift
//  Touch
//
//  Created by Patrick McElroy on 7/18/20.
//  Copyright © 2020 Patrick McElroy. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool { return true }

    @IBOutlet weak var numOnline: UILabel!
    
    @IBAction func tappedScreen(_ sender: Any) {
        let ref = Database.database().reference()
        ref.child("online/\(getUUID())/pressed").setValue(1)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: {_ in
            ref.child("online/\(self.getUUID())/pressed").setValue(0)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numOnline.text = ""
        let haptic = UINotificationFeedbackGenerator()
        
        let ref = Database.database().reference()
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {_ in
            ref.child("online/\(self.getUUID())/time").setValue(self.getTime())
        })
        
        ref.child("online/\(getUUID())/pressed").setValue(0)
        
//        ref.child(".info").child("connected").observe(.value, with: { snapshot in
//            if let connected = snapshot.value as? Bool, connected {
//                self.connectedToDatabase = true
//            } else {
//                self.connectedToDatabase = false
//            }
//        })
        
        ref.child("online").observe(.value, with: { snapshot in
            self.numOnline.text = String(snapshot.childrenCount)
            if let onlineDictionary = snapshot.value as? NSDictionary {
                for user in onlineDictionary {
                    if let userDict = user.value as? NSDictionary {
                        if userDict.value(forKey: "pressed") as? Int ?? 0 == 1 {
                            haptic.notificationOccurred(.error)
                        }
                        if userDict.value(forKey: "time") as? Int ?? 0 < self.getTime() - 10 {
                            ref.child("online/\(user.key)").removeValue()
                        }
                    }
                }
            }
        })
    }
    
    func getUUID() -> String {
//        var possUUID = UserDefaults.standard.string(forKey: "UUID") ?? "not logged"
//        if possUUID == "not logged" {
//            possUUID =
//            UserDefaults.standard.set(possUUID, forKey: "UUID")
//        }
        return UIDevice.current.identifierForVendor!.uuidString
    }
        
    func getTime() -> Int {
        return Int(Date().timeIntervalSinceReferenceDate)
    }

}

