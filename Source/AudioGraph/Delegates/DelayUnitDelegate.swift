//
//  DelayUnitDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A delegate representing the Delay effects unit.
///
/// Acts as a middleman between the Effects UI and the Delay effects unit,
/// providing a simplified interface / facade for the UI layer to control the Delay effects unit.
///
/// - SeeAlso: `DelayUnit`
/// - SeeAlso: `DelayUnitDelegateProtocol`
///
class DelayUnitDelegate: EffectsUnitDelegate<DelayUnit>, DelayUnitDelegateProtocol {
    
    var presets: DelayPresets {return unit.presets}
    
    var amount: Float {
        
        get {unit.amount}
        set {unit.amount = newValue}
    }
    
    var formattedAmount: String {return ValueFormatter.formatDelayAmount(amount)}
    
    var time: Double {
        
        get {unit.time}
        set {unit.time = newValue}
    }
    
    var formattedTime: String {return ValueFormatter.formatDelayTime(time)}
    
    var feedback: Float {
        
        get {unit.feedback}
        set {unit.feedback = newValue}
    }
    
    var formattedFeedback: String {return ValueFormatter.formatDelayFeedback(feedback)}
    
    var lowPassCutoff: Float {
        
        get {unit.lowPassCutoff}
        set {unit.lowPassCutoff = newValue}
    }
    
    var formattedLowPassCutoff: String {return ValueFormatter.formatDelayLowPassCutoff(lowPassCutoff)}
}

