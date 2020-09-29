import SpriteKit

class Supernova: SKView, VisualizerViewProtocol {
    
    let type: VisualizationType = .supernova
    override var mouseDownCanMoveWindow: Bool {true}
    
    var data: BassFFTData = BassFFTData()
    
    var ring: SKShapeNode!
    private lazy var gradientImage: NSImage = NSImage(named: "Supernova")!
    private lazy var gradientTexture = SKTexture(image: gradientImage)
    
    private var glowWidth: CGFloat = 50
    
    func presentView(with fft: FFT) {
        
        data.setUp(for: fft)
        
        if self.scene == nil {
            
            let frame = self.frame
            
            let scene = SKScene(size: self.bounds.size)
            scene.backgroundColor = NSColor.black
            scene.anchorPoint = CGPoint.zero
            
            self.ring = SKShapeNode(circleOfRadius: (frame.height / 2) - glowWidth)
            ring.position = NSPoint(x: frame.width / 2, y: frame.height / 2)
            ring.fillColor = NSColor.black
            
            ring.strokeTexture = gradientTexture
            ring.strokeColor = startColor
            ring.lineWidth = 75
            ring.glowWidth = glowWidth
            
//            ring.alpha = 0

            ring.yScale = 1
            ring.blendMode = .replace
            ring.isAntialiased = true
            
            scene.addChild(ring)
            presentScene(scene)
            
//            ring.run(SKAction.fadeIn(withDuration: 1))
        }

        isPaused = false
        show()
    }
    
    func dismissView() {

        isPaused = true
        hide()
    }
    
    var startColor: NSColor = .blue
    var endColor: NSColor = .red
    
    func setColors(startColor: NSColor, endColor: NSColor) {
        
        self.startColor = startColor
        self.endColor = endColor
    }
    
    let updateActionDuration: TimeInterval = 0.05
    let rotationAngle: CGFloat = -piOver180
    
    func update(with fft: FFT) {
        
        data.update(with: fft)
        let magnitude = CGFloat(data.peakBassMagnitude)
        
        ring.strokeColor = startColor.interpolate(endColor, magnitude)
        
        let scaleAction = SKAction.scale(to: magnitude, duration: updateActionDuration)
        let rotateAction = SKAction.rotate(byAngle: rotationAngle, duration: updateActionDuration)
        
        ring.run(SKAction.sequence([scaleAction, rotateAction]))
    }
}
