import SpriteKit

class Spectrogram: AuralSKView, VisualizerViewProtocol {
    
    let type: VisualizationType = .spectrogram
    
    var data: FrequencyData!
    
    var bars: [SpectrogramBar] = []
    
    var xMargin: CGFloat = 25
    var yMargin: CGFloat = 20
    
    lazy var spacing: CGFloat = spacing_10Band
    let spacing_10Band: CGFloat = 10
    let spacing_31Band: CGFloat = 2
    
    var numberOfBands: Int = 10 {
        
        didSet {
            
            updateSemaphore.wait()
            defer {updateSemaphore.signal()}
            
            self.isPaused = true
            
            SpectrogramBar.numberOfBands = numberOfBands
            spacing = numberOfBands == 10 ? spacing_10Band : spacing_31Band
            
            bars.removeAll()
            scene?.removeAllChildren()
            
            for i in 0..<numberOfBands {
            
                let bar = SpectrogramBar(position: NSPoint(x: (CGFloat(i) * (SpectrogramBar.barWidth + spacing)) + xMargin, y: yMargin))
                bars.append(bar)
                scene?.addChild(bar)
            }
            
            self.isPaused = false
        }
    }
    
    func presentView() {
        
        if self.scene == nil {
            
            let scene = SKScene(size: self.bounds.size)
            scene.anchorPoint = CGPoint.zero
            scene.backgroundColor = NSColor.black
            presentScene(scene)
            
            numberOfBands = 10
        }

        scene?.alpha = 0
        scene?.run(SKAction.fadeIn(withDuration: 1))
        
        scene?.isPaused = false
        scene?.isHidden = false
        show()
    }
    
    func dismissView() {

        scene?.isPaused = true
        scene?.isHidden = true
        hide()
    }
    
    func setColors(startColor: NSColor, endColor: NSColor) {
        SpectrogramBar.setColors(startColor: startColor, endColor: endColor)
    }
    
    private let updateSemaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    // TODO: Test this with random mags (with a button to trigger an iteration)
    
    func update() {
        
        updateSemaphore.wait()
        defer {updateSemaphore.signal()}
        
        for i in bars.indices {
            bars[i].magnitude = CGFloat(FrequencyData.bands[i].maxVal.clamp(to: fftMagnitudeRange))
        }
    }
}
