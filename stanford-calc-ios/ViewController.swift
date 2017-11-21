//
//  ViewController.swift
//  stanford-calc-ios
//
//  Created by Tarun Khubchandani on 17/11/2017.
//  Copyright © 2017 Tarun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping    {
            let textCurrentlyInDisplay = display.text!
            display.text = (digit == "." && textCurrentlyInDisplay.contains(".")) ? textCurrentlyInDisplay : textCurrentlyInDisplay + digit
        } else  {
            display.text = (digit == ".") ? "0." : digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain: CalculatorBrain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping    {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        userIsInTheMiddleOfTyping = false
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result    {
            displayValue = result
        }
    }
    
    
    
    
}

