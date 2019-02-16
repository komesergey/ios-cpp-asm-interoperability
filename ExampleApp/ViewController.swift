//
//  ViewController.swift
//  ExampleApp
//
//  Created by Edward Hyde on 15/02/2019.
//  Copyright © 2019 Edward Hyde. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var textResult: UITextView!
    
    
    @IBAction func check(_ sender: Any) {
        print(input?.text ?? "No value")
        
        self.result.text = "Is prime?"
        self.progress.text = ""
        
        let checker = PrimeChecker()
        
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        checker.simpleCall({ result, resultLength, observer in
            print("And back to Swift")
            let mySelf = Unmanaged<ViewController>.fromOpaque(observer!).takeUnretainedValue()
            DispatchQueue.main.async{
                print(resultLength)
                let resultStr = NSString(bytesNoCopy: UnsafeMutablePointer<UInt8>(OpaquePointer(result!)), length: Int(resultLength), encoding: String.Encoding.utf8.rawValue, freeWhenDone: true)
                mySelf.textResult.text = resultStr! as String
            }
        }, withTarget: observer)
        
        let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
        
        
        dispatchQueue.async {
            checker.checkIsPrime(self.input?.text, with: { observer in
                let mySelf = Unmanaged<ViewController>.fromOpaque(observer!).takeUnretainedValue()
                DispatchQueue.main.async{
                    let oldValue = mySelf.progress.text!
                    mySelf.progress.text = oldValue + ".."
                }
            }, andWith: { (result : Bool, observer) in
                print("Result...",result)
                let mySelf = Unmanaged<ViewController>.fromOpaque(observer!).takeUnretainedValue()
                DispatchQueue.main.async{
                    let oldValue = mySelf.result.text!
                    mySelf.result.text = oldValue + " " + (result ? "Yes" : "No")
                }
            }, withTarget: observer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkButton.isEnabled = false
        input.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let textVal = textField.text  {
            let text = (textVal as NSString).replacingCharacters(in:range, with: string)
            if Int64(text) != nil {
                checkButton.isEnabled = true
            } else {
                checkButton.isEnabled = false
            }

        }
        return true
    }
}

