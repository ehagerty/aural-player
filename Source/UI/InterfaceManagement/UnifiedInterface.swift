import Cocoa

class UnifiedInterface: InterfaceProtocol {
    
    var type: InterfaceType {.unified}
    
    private lazy var richUIWindowController: RichUIWindowController = RichUIWindowController()
    var richUIWindow: NSWindow {richUIWindowController.window!}
    
    func show() {
        richUIWindow.show()
    }
    
    func hide() {
        richUIWindow.close()
    }
}
