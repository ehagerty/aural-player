import SpriteKit

class Spectrogram: SKView, VisualizerViewProtocol {
    
    let type: VisualizationType = .spectrogram
    override var mouseDownCanMoveWindow: Bool {true}
    
    var data: SpectrogramFFTData = SpectrogramFFTData()
    
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
            
            data.numberOfBands = numberOfBands
            
            // TODO: Be more careful setting/resetting this flag
            SpectrogramBar.numberOfBands = numberOfBands
            spacing = numberOfBands == 10 ? spacing_10Band : spacing_31Band
            
            bars.removeAll()
            scene?.removeAllChildren()
            
            for i in 0..<numberOfBands {
            
                let bar = SpectrogramBar(position: NSPoint(x: (CGFloat(i) * (SpectrogramBar.barWidth + spacing)) + xMargin, y: yMargin))
                bars.append(bar)
                scene?.addChild(bar)
            }
        }
    }
    
    func presentView(with fft: FFT) {
        
        data.setUp(fft: fft, numberOfBands: numberOfBands)
        
        if self.scene == nil {
            
            let scene = SKScene(size: self.bounds.size)
            scene.anchorPoint = CGPoint.zero
            scene.backgroundColor = NSColor.black
            presentScene(scene)
            
            // TODO: This will eventually come from VisualizerUIPersistentState.options (i.e. self.options)
            SpectrogramBar.numberOfBands = numberOfBands
            spacing = spacing_10Band
            
            bars.removeAll()
            scene.removeAllChildren()
            
            for i in 0..<numberOfBands {
            
                let bar = SpectrogramBar(position: NSPoint(x: (CGFloat(i) * (SpectrogramBar.barWidth + spacing)) + xMargin, y: yMargin))
                bars.append(bar)
                scene.addChild(bar)
            }
        }

        isPaused = false
    }
    
    func dismissView() {
        
        scene?.removeAllActions()
        bars.forEach {$0.removeAllActions()}

        isPaused = true
    }
    
    func setColors(startColor: NSColor, endColor: NSColor) {
        SpectrogramBar.setColors(startColor: startColor, endColor: endColor)
    }
    
    private let updateSemaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    func update(with fft: FFT) {
        
        data.update(with: fft)
        
        updateSemaphore.wait()
        defer {updateSemaphore.signal()}
        
        for i in bars.indices {
            bars[i].magnitude = CGFloat(data.bands[i].maxVal)
        }
    }
}
