import Cocoa

class DelayView: NSView {
    
    @IBOutlet weak var timeSlider: CircularSlider!
    @IBOutlet weak var amountSlider: TickedCircularSlider!
    @IBOutlet weak var feedbackSlider: TickedCircularSlider!
    
    @IBOutlet weak var cutoffSlider: CutoffFrequencySlider!
    
    private var sliders: [EffectsUnitSliderProtocol] = []
    
    @IBOutlet weak var lblTime: NSTextField!
    @IBOutlet weak var lblAmount: NSTextField!
    @IBOutlet weak var lblFeedback: NSTextField!
    @IBOutlet weak var lblCutoff: NSTextField!
    
    var time: Double {
        return timeSlider.doubleValue
    }
    
    var amount: Int {
        return amountSlider.integerValue
    }
    
    var cutoff: Float {
        return cutoffSlider.frequency
    }
    
    var feedback: Int {
        return feedbackSlider.integerValue
    }
    
    override func awakeFromNib() {
//        sliders = [timeSlider, amountSlider, cutoffSlider, feedbackSlider]
        sliders = [timeSlider, amountSlider, feedbackSlider]
    }
    
    func initialize(_ stateFunction: (() -> EffectsUnitState)?) {
        
        for var slider in sliders {
            
            slider.stateFunction = stateFunction
            slider.updateState()
        }
//
//        (cutoffSlider.cell as? CutoffFrequencySliderCell)?.filterType = .lowPass
    }
    
    func setState(_ time: Double, _ timeString: String, _ amount: Float, _ amountString: String, _ feedback: Float, _ feedbackString: String, _ cutoff: Float, _ cutoffString: String) {
        
//        setTime(time, timeString)
//        setAmount(amount, amountString)
//        setFeedback(feedback, feedbackString)
//        setCutoff(cutoff, cutoffString)
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        
        for var slider in sliders {
            slider.unitState = state
        }
    }
    
    func setTime(_ time: Double, _ timeString: String) {
        
        timeSlider.doubleValue = time
        lblTime.stringValue = timeString
    }
    
    func timeChanged(_ timeString: String) {
        lblTime.stringValue = timeString
    }
    
    func setAmount(_ amount: Float, _ amountString: String) {
        
        amountSlider.floatValue = amount
        lblAmount.stringValue = amountString
    }
    
    func setFeedback(_ feedback: Float, _ feedbackString: String) {
        
        feedbackSlider.floatValue = feedback
        lblFeedback.stringValue = feedbackString
    }
    
    func setCutoff(_ cutoff: Float, _ cutoffString: String) {
        
        cutoffSlider.setFrequency(cutoff)
        lblCutoff.stringValue = cutoffString
    }
    
    func stateChanged() {
        sliders.forEach({$0.updateState()})
    }
    
    func applyPreset(_ preset: DelayPreset) {
        
        amountSlider.floatValue = preset.amount
        lblAmount.stringValue = ValueFormatter.formatDelayAmount(preset.amount)
        
        timeSlider.doubleValue = preset.time
        lblTime.stringValue = ValueFormatter.formatDelayTime(preset.time)
        
        feedbackSlider.floatValue = preset.feedback
        lblFeedback.stringValue = ValueFormatter.formatDelayFeedback(preset.feedback)
        
        cutoffSlider.setFrequency(preset.lowPassCutoff)
        lblCutoff.stringValue = ValueFormatter.formatDelayLowPassCutoff(preset.lowPassCutoff)
        
        for var slider in sliders {
            slider.unitState = preset.state
        }
    }
    
    func redrawSliders() {
        
        sliders.forEach {
            ($0 as? NSView)?.redraw()
        }
    }
}
