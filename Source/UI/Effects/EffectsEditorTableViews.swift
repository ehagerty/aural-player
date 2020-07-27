import Cocoa

class EffectsUnitEditorCell: NSTableCellView {
    
    @IBInspectable @IBOutlet weak var icon: NSImageView!
    @IBInspectable @IBOutlet weak var lblName: NSTextField!
    
    @IBInspectable @IBOutlet weak var btnBypass: EffectsUnitTriStateBypassButton!
    
    private var fxUnit: FXUnitDelegateProtocol!
    
    func initializeForUnit(_ fxUnit: FXUnitDelegateProtocol) {
        
        self.fxUnit = fxUnit
        
        btnBypass.stateFunction = fxUnit.stateFunction
        btnBypass.updateState()
        
        lblName.stringValue = fxUnit.unitDescription.replacingOccurrences(of: " ", with: "  ")
        lblName.font = Fonts.Constants.captionFont_14
    }
}
