/*
    Utilities for formatting numerical values into user-friendly displayable representations with units (e.g. "20 Hz" for frequency values)
 */

import Foundation

class ValueFormatter {
    
    private static var numberFormatter = { () -> NumberFormatter in
        
       let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.minimumIntegerDigits = 1
        
        return formatter
    }()
    
    // Time values in seconds
    static let oneMin = 60
    static let oneHour = 60 * oneMin
    
    // Given the elapsed time, in seconds, for a playing track, and its duration (also in seconds), returns 2 formatted strings: 1 - Formatted elapsed time, and 2 - Formatted time remaining. See formatSecondsToHMS()
    static func formatTrackTimes(_ elapsedSeconds: Double, _ duration: Double, _ percentageElapsed: Double,
                                 _ timeDisplayType: SeekTimeDisplayType = .formatted) -> String {
        
        var elapsedString: String?
        var remainingString: String?
        
        switch timeDisplayType {
         
        case .formatted:

            elapsedString = formatSecondsToHMS(elapsedSeconds)
            remainingString = formatSecondsToHMS(roundedInt(duration) - roundedInt(elapsedSeconds), true)

        case .seconds:

            let elapsedSecondsInt = roundedInt(elapsedSeconds)
            elapsedString = String(format: "%@ sec", commaSeparatedInt(elapsedSecondsInt))
            remainingString = String(format: "- %@ sec", commaSeparatedInt(roundedInt(duration) - elapsedSecondsInt))

//        case .percentage:

//            elapsedString = String(format: "%d%%", floorInt(percentageElapsed))
//
//            let percentageRemaining = 100 - floorInt(percentageElapsed)
//            remainingString = String(format: "- %d%%", percentageRemaining)
//
//            case .duration_formatted:
//
//            remainingString = formatSecondsToHMS(duration)
//
//            case .duration_seconds:
//
//            let durationInt = roundedInt(duration)
//            let secStr = commaSeparatedInt(durationInt)
//
//            remainingString = String(format: "%@ sec", secStr)
            
        default:
            
            return ""

        }
         
        if let theElapsedString = elapsedString, let theRemainingString = remainingString {
            return String(format: "%@ / %@", theElapsedString, theRemainingString)
            
        } else if let theElapsedString = elapsedString {
            return theElapsedString
            
        } else if let theRemainingString = remainingString {
            return theRemainingString
        }
        
        return ""
    }
    
    // Given the elapsed time, in seconds, for a playing track, and its duration (also in seconds), returns 2 formatted strings: 1 - Formatted elapsed time, and 2 - Formatted time remaining. See formatSecondsToHMS()
    static func formatTrackTimes(_ elapsedSeconds: Double, _ duration: Double, _ percentageElapsed: Double, _ timeElapsedDisplayType: TimeElapsedDisplayType = .formatted, _ timeRemainingDisplayType: TimeRemainingDisplayType = .formatted) -> (elapsed: String, remaining: String) {
        
        var elapsedString: String
        var remainingString: String
        
        switch timeElapsedDisplayType {
         
        case .formatted:

        elapsedString = formatSecondsToHMS(elapsedSeconds)

        case .seconds:

        let elapsedSecondsInt = roundedInt(elapsedSeconds)
        let secStr = commaSeparatedInt(elapsedSecondsInt)
        elapsedString = String(format: "%@ sec", secStr)

        case .percentage:

        elapsedString = String(format: "%d%%", floorInt(percentageElapsed))

        }

        switch timeRemainingDisplayType {

        case .formatted:

        let elapsedSecondsInt = roundedInt(elapsedSeconds)
        let durationInt = roundedInt(duration)
        
        remainingString = formatSecondsToHMS(durationInt - elapsedSecondsInt, true)

        case .seconds:

        let elapsedSecondsInt = roundedInt(elapsedSeconds)
        let durationInt = roundedInt(duration)
        let secStr = commaSeparatedInt(durationInt - elapsedSecondsInt)
        
        remainingString = String(format: "- %@ sec", secStr)

        case .percentage:

        let percentageRemaining = 100 - floorInt(percentageElapsed)
        remainingString = String(format: "- %d%%", percentageRemaining)

        case .duration_formatted:

        remainingString = formatSecondsToHMS(duration)

        case .duration_seconds:

        let durationInt = roundedInt(duration)
        let secStr = commaSeparatedInt(durationInt)
        
        remainingString = String(format: "%@ sec", secStr)
            
        }
         
        return (elapsedString, remainingString)
    }
    
    /* Formats a duration (time interval) from seconds to a displayable string showing hours, minutes, and seconds. For example, 500 seconds becomes "8:20", and 3675 seconds becomes "1:01:15".
     
        The "includeMinusPrefix" indicates whether or not to include a prefix of "-" in the formatted string returned.
    */
    static func formatSecondsToHMS(_ timeSecondsDouble: Double, _ includeMinusPrefix: Bool = false) -> String {
        return formatSecondsToHMS(roundedInt(timeSecondsDouble))
    }
    
    static func formatSecondsToHMS(_ timeSeconds: Int, _ includeMinusPrefix: Bool = false) -> String {
        
        let secs = timeSeconds % oneMin
        let mins = (timeSeconds / oneMin) % oneMin
        let hrs = timeSeconds / oneHour
        
        return hrs > 0 ? String(format: "%@%d:%02d:%02d", includeMinusPrefix ? "- " : "", hrs, mins, secs) : String(format: "%@%d:%02d", includeMinusPrefix ? "- " : "", mins, secs)
    }
    
    static func formatDurationSummary(_ timeSecondsDouble: Double) -> String {
        
        let timeSeconds = roundedInt(timeSecondsDouble)
        
        let secs = timeSeconds % oneMin
        let mins = (timeSeconds / oneMin) % oneMin
        let hrs = timeSeconds / oneHour
        
        return hrs > 0 ? String(format: "%d hr %02d min %02d sec", hrs, mins, secs) : String(format: "%d min %02d sec", mins, secs)
    }
    
    // Formats a duration (time interval) from seconds to a displayable string showing minutes, and seconds. For example, 500 seconds becomes "8 min 20 sec", 120 seconds becomes "2 min", and 36 seconds becomes "36 sec"
    static func formatSecondsToHMS_minSec(_ duration: Int) -> String {
        
        let secs = duration % oneMin
        let mins = duration / oneMin
        
        return mins > 0 ? (secs > 0 ? String(format: "%d min %d sec", mins, secs) : String(format: "%d min", mins)) : String(format: "%d sec", secs)
    }
    
    // Formats a duration (time interval) from seconds to a displayable string showing minutes, and seconds. For example, 500 seconds becomes "8 min 20 sec", 120 seconds becomes "2 min", and 36 seconds becomes "36 sec"
    static func formatSecondsToHMS_hrMinSec(_ duration: Int) -> String {
        
        let hrs = duration / oneHour
        let mins = (duration - (hrs * oneHour)) / oneMin
        let secs = duration % oneMin
        
        var hrsStr = ""
        
        if hrs > 0 {
            hrsStr = String(format: "%d hr ", hrs)
        }
        
        var secsStr = "0 sec"
        
        if secs > 0 {
            secsStr = String(format: "%d sec", secs)
        } else {
            secsStr = ""
        }
        
        var minsStr = ""
        
        if mins > 0 {
            minsStr = String(format: "%d min ", mins)
        } else {
            minsStr = hrs > 0 ? (secs > 0 ?  "0 min " : "") : ""
        }
        
        let fStr = String(format: "%@%@%@", hrsStr, minsStr, secsStr)
        
        return fStr
    }
    
    static func formatVolume(_ value: Float) -> String {
        return String(format: "%d%%", Int(round(value)))
    }
    
    static func formatPan(_ value: Float) -> String {
        
        let panVal = Int(round(value))
        
        if (panVal < 0) {
            
            // Left of center
            
            let absVal = abs(panVal)
            return absVal < 100 ? String(format: "Left %d%%", absVal) : "Left"
            
        } else if (panVal > 0) {
            
            // Right of center
            
            let absVal = abs(panVal)
            return absVal < 100 ? String(format: "Right %d%%", absVal) : "Right"
            
        } else {
            
            // Center
            return "Center"
        }
    }
    
    static func formatPitch(_ value: Float) -> String {
        return formatValueWithUnits(NSNumber(value: value), 1, Units.pitchOctaves, true)
    }
    
    static func formatPitchShift(_ shift: PitchShift) -> String {
        
        let absCents = shift.asCents
        
        if absCents == 0 {
            return "0"
        }
        
        let sign = absCents > 0 ? "+" : "-"
        
        var octavesStr = ""
        
        if shift.octaves != 0 {
            octavesStr = String(format: "%d 8ve  ", abs(shift.octaves))
        }
        
        var centsStr = ""
        
        if shift.cents != 0 {
            centsStr = String(format: "%d cents", abs(shift.cents))
        }
        
        var semitonesStr = ""
        
        if shift.semitones != 0 {
            semitonesStr = String(format: "%d m2  ", abs(shift.semitones))
            
        } else {
            semitonesStr = shift.octaves != 0 ? (shift.cents != 0 ?  "0 m2  " : "") : ""
        }
        
        return String(format: "%@%@%@%@", sign, octavesStr, semitonesStr, centsStr)
    }
    
    static func formatOverlap(_ value: Float) -> String {
        return ValueFormatter.formatValue(NSNumber(value: value), 1)
    }
    
    static func formatTimeStretchRate(_ value: Float) -> String {
        return ValueFormatter.formatValueWithUnits(NSNumber(value: value), 2, Units.timeStretchRate, false)
    }
    
    static func formatReverbAmount(_ value: Float) -> String {
        
        switch value {
            
        case 0:
            
            return String(format: "100%% %@", Units.reverbDryAmount)
            
        case 100:
            
            return String(format: "100%% %@", Units.reverbWetAmount)
            
        default:
            
            let wet = roundedInt(value)
            return String(format:"%d / %d", 100 - wet, wet)
        }
    }
    
    static func formatDelayTime(_ value: Double) -> String {
        return ValueFormatter.formatValueWithUnits(NSNumber(value: value), 2, Units.delayTimeSecs, true)
    }
    
    static func formatDelayAmount(_ value: Float) -> String {
        return formatReverbAmount(value)
    }
    
    static func formatDelayFeedback(_ value: Float) -> String {
        return ValueFormatter.formatValueWithUnits(NSNumber(value: value), 0, Units.delayFeedbackPerc, false)
    }
    
    static func formatDelayLowPassCutoff(_ value: Float) -> String {
        return formatFrequency(value)
    }
    
    static func formatFilterFrequencyRange(_ value1: Double, _ value2: Double) -> String {
        return String(format: "[ %d %@ - %d %@ ]", Int(value1), Units.frequencyHz, Int(value2), Units.frequencyHz)
    }
    
    static func formatFilterFrequencyRange(_ value1: Float, _ value2: Float) -> String {
        return String(format: "[ %d %@ - %d %@ ]", Int(value1), Units.frequencyHz, Int(value2), Units.frequencyHz)
    }
    
    static func formatFrequency(_ value: Float) -> String {
        return String(format: "%d %@", Int(value), Units.frequencyHz)
    }
    
    static func formatValueWithUnits(_ value: NSNumber, _ decimalDigits: Int, _ unit: String, _ includeSpace: Bool) -> String {
        
        numberFormatter.maximumFractionDigits = decimalDigits
        
        var numStr = numberFormatter.string(from: value)!
        
        if (numStr == "-0") {
            numStr = "0"
        }
        
        return includeSpace ? String(format: "%@ %@", numStr, unit) : String(format: "%@%@", numStr, unit)
    }
    
    static func formatValue(_ value: NSNumber, _ decimalDigits: Int) -> String {
        
        numberFormatter.locale = Locale(identifier: "en_US_POSIX")
        numberFormatter.maximumFractionDigits = decimalDigits
        numberFormatter.minimumIntegerDigits = 1
        
        return numberFormatter.string(from: value)!
    }
    
    static func formatPixels(_ value: Float) -> String {
        
        return formatValueWithUnits(NSNumber(value: value), 0, Units.screenRealEstatePixel, false)
    }
    
    // Provides a comma separated String representation of an integer, that is easy to read. For ex, 15700900 -> "15,700,900"
    static func readableLongInteger(_ num: Int64) -> String {
        
        let numString = String(num)
        var readableNumString: String = ""
        
        // Last index of numString
        let numDigits: Int = numString.count - 1
        
        var c = 0
        for eachCharacter in numString {
            readableNumString.append(eachCharacter)
            if (c < numDigits && (numDigits - c) % 3 == 0) {
                readableNumString.append(",")
            }
            c += 1
        }
        
        return readableNumString
    }
    
    static func commaSeparatedInt(_ num: Int) -> String {
        
        let numString = String(num)
        var readableNumString: String = ""
        
        // Last index of numString
        let numDigits: Int = numString.count - 1
        
        var c = 0
        for eachCharacter in numString {
            readableNumString.append(eachCharacter)
            if (c < numDigits && (numDigits - c) % 3 == 0) {
                readableNumString.append(",")
            }
            c += 1
        }
        
        return readableNumString
    }
    
    struct Units {

        // Units for different effects parameters
        
        static let eqGainDB: String = "dB"
        static let pitchOctaves: String = "8ve"
        static let timeStretchRate: String = "x"
        static let reverbWetAmount: String = "wet"
        static let reverbDryAmount: String = "dry"
        static let delayTimeSecs: String = "sec"
        static let delayFeedbackPerc: String = "%"
        static let frequencyHz: String = "Hz"
        static let frequencyKHz: String = "KHz"
        static let screenRealEstatePixel: String = "px"
    }
}
