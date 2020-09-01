import AVFoundation

class FilterUnit: FXUnit, FilterUnitProtocol {
    
    private let node: FlexibleFilterNode = FlexibleFilterNode()
    
    override var avNodes: [AVAudioNode] {return [node]}
    
    init() {
        
        super.init(.filter)
        
//        node.addBands(filterState.bands)
    }
    
    var bands: [FilterBand] {
        
        get {return node.allBands()}
        set(newValue) {node.setBands(newValue)}
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    func getBand(_ index: Int) -> FilterBand {
        return node.getBand(index)
    }
    
    func addBand(_ band: FilterBand) -> Int {
        return node.addBand(band)
    }
    
    func updateBand(_ index: Int, _ band: FilterBand) {
        node.updateBand(index, band)
    }
    
    func removeBands(_ indexSet: IndexSet) {
        node.removeBands(indexSet)
    }
    
    func removeAllBands() {
        node.removeAllBands()
    }
}
