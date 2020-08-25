import Cocoa

class DelayView: NSView {
    
    @IBOutlet weak var timeSlider: CircularSlider!
    @IBOutlet weak var amountSlider: TickedCircularSlider!
    @IBOutlet weak var feedbackSlider: TickedCircularSlider!
    
    @IBOutlet weak var cutoffSlider: CutoffFrequencyCircularSlider!
    
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
    
    func initialize() {
        
        let delayUnit = ObjectGraph.audioGraphDelegate.delayUnit

        sliders = [timeSlider, amountSlider, cutoffSlider, feedbackSlider]

        for var slider in sliders {

            slider.stateFunction = delayUnit.stateFunction
            slider.updateState()
        }

        timeSlider.setValue(Float(delayUnit.time))
        lblTime.stringValue = delayUnit.formattedTime

        amountSlider.setValue(delayUnit.amount)
        lblAmount.stringValue = delayUnit.formattedAmount

        feedbackSlider.setValue(delayUnit.feedback)
        lblFeedback.stringValue = delayUnit.formattedFeedback

        cutoffSlider.setFrequency(delayUnit.lowPassCutoff)
        lblCutoff.stringValue = delayUnit.formattedLowPassCutoff
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        
        for var slider in sliders {
            slider.unitState = state
        }
    }
    
    func timeChanged(_ timeString: String) {
        lblTime.stringValue = timeString
    }
    
    func amountChanged(_ amountString: String) {
        lblAmount.stringValue = amountString
    }
    
    func feedbackChanged(_ feedbackString: String) {
        lblFeedback.stringValue = feedbackString
    }
    
    func cutoffChanged(_ cutoffString: String) {
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
