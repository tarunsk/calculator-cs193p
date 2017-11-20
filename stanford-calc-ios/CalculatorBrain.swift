//
//  CalculatorBrain.swift
//  stanford-calc-ios
//
//  Created by Tarun Khubchandani on 19/11/2017.
//  Copyright © 2017 Tarun. All rights reserved.
//

import Foundation

struct CalculatorBrain  {
    
    private var accumulator: Double?
    
    private enum Operation  {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case floatingPoint((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "cos" : Operation.unaryOperation(cos),
        "±" : Operation.unaryOperation({-$0}),
        "×" : Operation.binaryOperation({$0 * $1}),
        "÷" : Operation.binaryOperation({$0 / $1}),
        "+" : Operation.binaryOperation({$0 + $1}),
        "−" : Operation.binaryOperation({$0 - $1}),
        "." : Operation.floatingPoint({$0 + ($1 / 100)}),
        "=" : Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String)    {
        if let operation = operations[symbol]    {
            switch operation    {
            case .constant(let value):
                accumulator = value
            case .unaryOperation(let function):
                if accumulator != nil    {
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                if accumulator != nil   {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                }
            case .floatingPoint(let function):
                if accumulator != nil   {
                    pendingFloatEntry = PendingFloatEntry(function: function, integerComponent: accumulator!)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation()  {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
        }
    }
    
    private var pendingFloatEntry: PendingFloatEntry?
    
    private struct PendingFloatEntry    {
        let function: (Double, Double) -> Double
        let integerComponent: Double
        
        func addDecimal(with decimalComponent: Double) -> Double    {
            return function(integerComponent, decimalComponent)
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation   {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double)  {
        accumulator = operand
    }
    
    var result: Double?  {
        get {
            return accumulator
        }
    }
}
