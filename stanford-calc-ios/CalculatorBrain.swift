//
//  CalculatorBrain.swift
//  stanford-calc-ios
//
//  Created by Tarun Khubchandani on 19/11/2017.
//  Copyright © 2017 Tarun. All rights reserved.
//

import Foundation

struct CalculatorBrain  {
    
    private var accumulator: (value: Double, description: String)?
    
    private enum Operation  {
        case constant(Double, String)
        case unaryOperation(((Double) -> Double), (String) -> String)
        case binaryOperation(((Double, Double) -> Double), (String, String) -> (String))
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi, "π"),
        "e" : Operation.constant(M_E, "e"),
        "√" : Operation.unaryOperation(sqrt, {"√(\($0))"}),
        "cos" : Operation.unaryOperation(cos, {"cos(\($0))"}),
        "sin" : Operation.unaryOperation(sin, {"sin(\($0))"}),
        "tan" : Operation.unaryOperation(tan, {"tan(\($0))"}),
        "±" : Operation.unaryOperation({-$0}, {"±\($0)"}),
        "×" : Operation.binaryOperation({$0 * $1}, {"\($0) × \($1)"}),
        "÷" : Operation.binaryOperation({$0 / $1}, {"\($0) ÷ \($1)"}),
        "+" : Operation.binaryOperation({$0 + $1}, {"\($0) + \($1)"}),
        "−" : Operation.binaryOperation({$0 - $1}, {"\($0) − \($1)"}),
        "=" : Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String)    {
        if let operation = operations[symbol]    {
            switch operation    {
            case .constant(let value, let symbol):
                accumulator = (value, symbol)
            case .unaryOperation(let function, let operation):
                if accumulator != nil    {
                    accumulator = (function(accumulator!.0), operation(accumulator!.1))
                }
            case .binaryOperation(let function, let descriptor):
                if resultIsPending { performPendingBinaryOperation() }
                if accumulator != nil   {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, description: descriptor, firstOperand: accumulator!)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation()  {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = (pendingBinaryOperation!.perform(with: accumulator!.0), pendingBinaryOperation!.describe(with: accumulator!.1))
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation   {
        let function: ((Double, Double) -> Double)
        let description: ((String, String) -> String)
        let firstOperand: (Double, String)
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand.0, secondOperand)
        }
        
        func describe(with secondOperandDescription: String) -> String {
            return description(firstOperand.1, secondOperandDescription)
        }
    }
    
    mutating func setOperand(_ operand: (Double, String))  {
        accumulator = operand
    }
    
    var resultIsPending: Bool  {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    var result: Double?  {
        get {
            return accumulator?.value
        }
    }
    
    var description: String?  {
        get {
            if resultIsPending  {
                return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.1 ?? "")
            }
            return accumulator?.description
        }
    }
}
