import Cocoa

class MouseTrackingView: NSView {
    
    private var trackingArea: NSTrackingArea?
    
    private var isTracking: Bool = false
    
    private var inArea: Bool = false
    
    func startTracking() {
        
        stopTracking()
        
        isTracking = true
        updateTrackingAreas()
    }
    
    func stopTracking() {

        isTracking = false
        
        if let area = self.trackingArea {
            self.removeTrackingArea(area)
        }
    }
 
    override func updateTrackingAreas() {
        
        if !isTracking {return}
        
        // Create a tracking area that covers the bounds of the view. It should respond whenever the mouse enters or exits.
        
        self.trackingArea = NSTrackingArea(rect: self.bounds, options: [NSTrackingArea.Options.activeAlways,  NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.mouseMoved], owner: self, userInfo: nil)
        
        // Add the new tracking area to the view
        addTrackingArea(self.trackingArea!)
        
        super.updateTrackingAreas()
    }
    
    override func mouseEntered(with event: NSEvent) {
        
        SyncMessenger.publishNotification(MouseTrackingNotification.mouseEntered)
        inArea = true
    }
    
    override func mouseMoved(with event: NSEvent) {
        
        if (!inArea) {
            
            SyncMessenger.publishNotification(MouseTrackingNotification.mouseEntered)
            inArea = true
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        
        if (!inArea) {
            return
        }
        
        // TODO: There seems to be a bug/issue with false exit events triggered by hovering over some sub-views. So, this redundant validation is necessary to validate the X position.
        
        let loc = event.locationInWindow
        
        let xExit = loc.x < self.bounds.minX || loc.x > self.bounds.maxX
        let yExit = loc.y < self.bounds.minY || loc.y > self.bounds.maxY
        
        if (xExit || yExit) {
            SyncMessenger.publishNotification(MouseTrackingNotification.mouseExited)
            inArea = false
        }
    }
}
