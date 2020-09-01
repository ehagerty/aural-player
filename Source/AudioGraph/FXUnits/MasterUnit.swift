import Foundation

class MasterUnit: FXUnit, NotificationSubscriber {
    
    var slaveUnits: [FXUnit]
    
    var eqUnit: EQUnit
    var pitchUnit: PitchUnit
    var timeUnit: TimeUnit
    var reverbUnit: ReverbUnit
    var delayUnit: DelayUnit
    var filterUnit: FilterUnit

    init(_ slaveUnits: [FXUnit]) {
        
        self.slaveUnits = slaveUnits
        
        eqUnit = slaveUnits.first(where: {$0 is EQUnit})! as! EQUnit
        pitchUnit = slaveUnits.first(where: {$0 is PitchUnit})! as! PitchUnit
        timeUnit = slaveUnits.first(where: {$0 is TimeUnit})! as! TimeUnit
        reverbUnit = slaveUnits.first(where: {$0 is ReverbUnit})! as! ReverbUnit
        delayUnit = slaveUnits.first(where: {$0 is DelayUnit})! as! DelayUnit
        filterUnit = slaveUnits.first(where: {$0 is FilterUnit})! as! FilterUnit
        
        super.init(.master)
        
        Messenger.subscribe(self, .fx_unitActivated, self.ensureActive)
    }
    
    override func toggleState() -> EffectsUnitState {
        
        if super.toggleState() == .bypassed {

            // Active -> Inactive
            // If a unit was active (i.e. not bypassed), mark it as now being suppressed by the master bypass
            slaveUnits.forEach {$0.suppress()}
            
        } else {
            
            // Inactive -> Active
            slaveUnits.forEach {$0.unsuppress()}
        }
        
        return state
    }
}
