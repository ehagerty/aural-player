public enum SeekTimeDisplayType: String {
    
    // Displayed as hh:mm:ss
    case formatted
    case formatted_elapsed
    case formatted_remaining
    case formatted_elapsed_withDuration
    
    // Displayed as "xyz sec"
    case seconds
    case seconds_elapsed
    case seconds_remaining
    case seconds_elapsed_withDuration
    
    // Displayed as "xyz %"
    case percentage_elapsed
    case percentage_elapsed_withDurationFormatted
    case percentage_elapsed_withDurationSeconds
    case percentage_remaining

    func toggle() -> SeekTimeDisplayType {

        switch self {

        case .formatted:    return .formatted_elapsed
            
        case .formatted_elapsed:    return .formatted_remaining
            
        case .formatted_remaining:    return .formatted_elapsed_withDuration
            
        case .formatted_elapsed_withDuration:    return .seconds

        case .seconds:      return .seconds_elapsed
            
        case .seconds_elapsed:      return .seconds_remaining

        case .seconds_remaining:   return .seconds_elapsed_withDuration
            
        case .seconds_elapsed_withDuration:   return .percentage_elapsed
            
        case .percentage_elapsed:   return .percentage_elapsed_withDurationFormatted
            
        case .percentage_elapsed_withDurationFormatted:   return .percentage_elapsed_withDurationSeconds
            
        case .percentage_elapsed_withDurationSeconds:   return .percentage_remaining
            
        case .percentage_remaining:   return .formatted

        }
    }
}

// Enumeration of all possible formats in which the elapsed seek time is displayed.
public enum TimeElapsedDisplayType: String {

    // Displayed as hh:mm:ss
    case formatted
    
    // Displayed as "xyz sec"
    case seconds
    
    // Displayed as "xyz %"
    case percentage

    func toggle() -> TimeElapsedDisplayType {

        switch self {

        case .formatted:    return .seconds

        case .seconds:      return .percentage

        case .percentage:   return .formatted

        }
    }
}

// Enumeration of all possible formats in which the remaining seek time is displayed.
public enum TimeRemainingDisplayType: String {

    // Remaining seek time is displayed as "- hh:mm:ss"
    case formatted

    // Track duration is displayed as hh:mm:ss
    case duration_formatted
    
    // Track duration is displayed as "xyz sec"
    case duration_seconds
    
    // Remaining seek time is displayed as "- xyz sec"
    case seconds
    
    // Remaining seek time is displayed as "- xyz %"
    case percentage

    func toggle() -> TimeRemainingDisplayType {

        switch self {

        case .formatted:    return .seconds

        case .seconds:      return .percentage

        case .percentage:   return .duration_formatted

        case .duration_formatted:     return .duration_seconds

        case .duration_seconds:     return .formatted

        }
    }
}
