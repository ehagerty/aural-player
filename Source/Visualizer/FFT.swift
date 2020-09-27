import Foundation
import Accelerate
import AVFoundation

let fftMagnitudeRange: ClosedRange<Float> = 0...1

class FFT {
    
    init() {}
    
    private var fftSetup: FFTSetup!
    
    private var log2n: UInt = 9
    
    private var bufferSizePOT: Int = 512
    private var bufferSizePOT_Float: Float = 512
    
    private var halfBufferSize: Int = 256
    private var halfBufferSize_Int32: Int32 = 256
    private var halfBufferSize_UInt: UInt = 256
    private var halfBufferSize_Float: Float = 256
    
    private let vsMulScalar: [Float] = [Float(1.0) / Float(150.0)]
    
    private var realp: [Float] = []
    private var imagp: [Float] = []
    private var output: DSPSplitComplex!
    
    private var transferBuffer: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>.allocate(capacity: 0)
    private var window: [Float] = []
    private var windowSize: Int = 512
    private var windowSize_vDSPLength: vDSP_Length = 512
    
    private let fftRadix: Int32 = Int32(kFFTRadix2)
    private let vDSP_HANN_NORM_Int32: Int32 = Int32(vDSP_HANN_NORM)
    private let fftDirection: FFTDirection = FFTDirection(FFT_FORWARD)
    private var zeroDBReference: Float = 0.1
    
    private var magnitudes: [Float] = []
    private var normalizedMagnitudes: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>.allocate(capacity: 0)
    
    private(set) var bufferSize: Int = 512 {
        
        didSet {
            
            log2n = UInt(round(log2(Double(bufferSize))))
            
            bufferSizePOT = Int(1 << log2n)
            bufferSizePOT_Float = Float(bufferSizePOT)
            
            halfBufferSize = bufferSizePOT / 2
            halfBufferSize_Int32 = Int32(halfBufferSize)
            halfBufferSize_UInt = UInt(halfBufferSize)
            halfBufferSize_Float = Float(halfBufferSize)
            
            fftSetup = vDSP_create_fftsetup(log2n, fftRadix)!
            
            realp = [Float](repeating: 0, count: halfBufferSize)
            imagp = [Float](repeating: 0, count: halfBufferSize)
            output = DSPSplitComplex(realp: &realp, imagp: &imagp)
            
            windowSize = bufferSizePOT
            windowSize_vDSPLength = vDSP_Length(windowSize)
            
            transferBuffer = UnsafeMutablePointer<Float>.allocate(capacity: windowSize)
            window = [Float](repeating: 0, count: windowSize)
            
            magnitudes = [Float](repeating: 0, count: halfBufferSize)
            normalizedMagnitudes = UnsafeMutablePointer<Float>.allocate(capacity: halfBufferSize)
        }
    }
    
    func setUp(sampleRate: Float, bufferSize: Int, numBands: Int? = nil) {
        
        self.bufferSize = bufferSize
        FrequencyData.setUp(sampleRate: sampleRate, bufferSize: bufferSize, numBands: numBands)
    }
    
    func analyze(_ buffer: AudioBufferList) {
        
        let bufferPtr: UnsafePointer<Float> = UnsafePointer(buffer.mBuffers.mData!.assumingMemoryBound(to: Float.self))
        
        // Hann windowing to reduce frequency leakage
        vDSP_hann_window(&window, windowSize_vDSPLength, vDSP_HANN_NORM_Int32)
        vDSP_vmul(bufferPtr, 1, window, 1, transferBuffer, 1, windowSize_vDSPLength)
        
        transferBuffer.withMemoryRebound(to: DSPComplex.self, capacity: windowSize) {dspComplexStream in
            vDSP_ctoz(dspComplexStream, 2, &output, 1, halfBufferSize_UInt)
        }
        
        // Perform the FFT
        vDSP_fft_zrip(fftSetup, &output, 1, log2n, fftDirection)
        
        // Convert FFT output to magnitudes
        vDSP_zvmags(&output, 1, &magnitudes, 1, halfBufferSize_UInt)
        
        // Convert to dB and scale.
        vDSP_vdbcon(&magnitudes, 1, &zeroDBReference, normalizedMagnitudes, 1, halfBufferSize_UInt, 1)
        vDSP_vsmul(normalizedMagnitudes, 1, vsMulScalar, normalizedMagnitudes, 1, halfBufferSize_UInt)
        
        // Determine peak magnitudes for each of the bands we are interested in.
        for band in FrequencyData.bands {
            vDSP_maxv(normalizedMagnitudes.advanced(by: band.minIndex), 1, &band.maxVal, band.indexCount)
        }

        // Bass bands peak
        vDSP_maxv(FrequencyData.bassBands.map {$0.maxVal}, 1, &FrequencyData.peakBassMagnitude, UInt(FrequencyData.bassBands.count))
    }
    
    deinit {
        
        if fftSetup != nil {
            vDSP_destroy_fftsetup(fftSetup)
        }
        
        transferBuffer.deallocate()
        normalizedMagnitudes.deallocate()
    }
}

class FrequencyData {
    
    static func setUp(sampleRate: Float, bufferSize: Int, numBands: Int? = nil) {
        
        Self.bufferSize = bufferSize
        Self.sampleRate = sampleRate
        
        Self.numBands = numBands ?? 10
    }
    
    private(set) static var sampleRate: Float = 44100 {

        didSet {
            fftFrequencies = (0..<halfBufferSize).map {Float($0) * nyquistFrequency / halfBufferSize_Float}
        }
    }
    
    static var nyquistFrequency: Float {
        sampleRate / 2
    }
    
    private(set) static var bufferSize: Int = 512 {
        
        didSet {
            
            bufferSize_Float = Float(bufferSize)
            halfBufferSize = bufferSize / 2
        }
    }
    
    private(set) static var bufferSize_Float: Float = 512
    
    private(set) static var halfBufferSize: Int = 512 {
        
        didSet {
            halfBufferSize_Float = Float(halfBufferSize)
        }
    }
    
    private(set) static var halfBufferSize_Float: Float = 512
    
    private(set) static var fftFrequencies: [Float] = []
    
    static var numBands: Int = 10 {
        
        didSet {
            bands = numBands == 10 ? bands_10 : bands_31
        }
    }
    
    static var bassBands: [Band] {
        numBands == 10 ? [bands[0], bands[1], bands[2]] : [bands[0], bands[1], bands[2], bands[3], bands[4]]
    }
    
    private(set) static var bands: [Band] = []
    
    static var bands_10: [Band] {
        
        let arr: [Float] = [31, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
        
        let tpb: Float = 2
        let firstFrequency: Float = fftFrequencies[1]
        
        var bands: [Band] = []
        
        for index in 0..<arr.count {
            
            let f = arr[index]
            let minF: Float = index > 0 ? bands[index - 1].maxF : sqrt((f * f) / tpb)
            let maxF: Float = sqrt((f * f) / tpb) * tpb
            
            let minIndex: Int = Int(round(minF / firstFrequency))
            let maxIndex: Int = Int(round(maxF / firstFrequency)) - 1
            
            bands.append(Band(minF: minF, maxF: maxF, minIndex: minIndex, maxIndex: maxIndex))
        }

        return bands
    }
    
    static var bands_31: [Band] {
        
        // 20/25/31.5/40/50/63/80/100/125/160/200/250/315/400/500/630/800/1K/1.25K/1.6K/ 2K/ 2.5K/3.15K/4K/5K/6.3K/8K/10K/12.5K/16K/20K
        
        let arr: [Float] = [20, 31.5, 63, 100, 125, 160, 200, 250, 315, 400, 500, 630, 800,
                            1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000, 10000, 12500, 16000, 20000]

        var bands: [Band] = []
        let firstFrequency: Float = fftFrequencies[1]
        
        let tpb: Float = pow(2, 1.0/3.0)

        // NOTE: These bands assume a buffer size of 2048, i.e. 1024 FFT output data points, AND a sample rate of 48KHz.
        
        bands.append(Band(minF: sqrt((20 * 20) / tpb), maxF: sqrt((20 * 20) / tpb) * tpb, minIndex: 0, maxIndex: 0))
        bands.append(Band(minF: sqrt((31.5 * 31.5) / tpb), maxF: sqrt((31.5 * 31.5) / tpb) * tpb, minIndex: 1, maxIndex: 2))
        bands.append(Band(minF: bands[1].maxF, maxF: sqrt((63 * 63) / tpb) * tpb, minIndex: 3, maxIndex: 3))
        bands.append(Band(minF: bands[2].maxF, maxF: sqrt((100 * 100) / tpb) * tpb, minIndex: 4, maxIndex: 4))
        bands.append(Band(minF: bands[3].maxF, maxF: sqrt((125 * 125) / tpb) * tpb, minIndex: 5, maxIndex: 6))
        bands.append(Band(minF: bands[4].maxF, maxF: sqrt((160 * 160) / tpb) * tpb, minIndex: 7, maxIndex: 7))
        
        for index in 6..<arr.count {
            
            let f = arr[index]
            let minF: Float = bands[index - 1].maxF
            let maxF: Float = sqrt((f * f) / tpb) * tpb
            
            var minIndex: Int = Int(round(minF / firstFrequency))
            var maxIndex: Int = min(Int(round(maxF / firstFrequency)) - 1, halfBufferSize - 1)
            
            if maxIndex < minIndex {
                minIndex = 0
                maxIndex = 0
            }
            
            bands.append(Band(minF: minF, maxF: maxF, minIndex: minIndex, maxIndex: maxIndex))
        }
        
        return bands
    }
    
    static var peakBassMagnitude: Float = 0
}

class Band {
    
    let minF: Float
    let maxF: Float
    
    let minIndex: Int
    let maxIndex: Int
    let indexCount: UInt
    
    var avgVal: Float = 0
    var maxVal: Float = 0
    
    init(minF: Float, maxF: Float, minIndex: Int, maxIndex: Int) {
        
        self.minF = minF
        self.maxF = maxF
        
        self.minIndex = minIndex
        self.maxIndex = maxIndex
        self.indexCount = UInt(maxIndex - minIndex + 1)
    }
    
    func toString() -> String {
//        return "minF: \(minF), maxF: \(maxF), minIndex: \(minIndex), maxIndex: \(maxIndex), avg: \(avgVal), max: \(maxVal)"
        return "minF: \(minF), maxF: \(maxF), minIndex: \(minIndex), maxIndex: \(maxIndex)"
    }
}

struct BandFRange {
    
    let minF: Float
    let maxF: Float
    
    let minIndex: Int
    let maxIndex: Int
}

extension Array where Element: FloatingPoint {
    
    func fastMin() -> Float {
        
        let floats = self as! [Float]
        var min: Float = 0
        vDSP_minv(floats, 1, &min, UInt(count))
        return min
    }
    
    func fastMax() -> Float {
        
        let floats = self as! [Float]
        var max: Float = 0
        vDSP_maxv(floats, 1, &max, UInt(count))
        return max
    }
    
    func avg() -> Float {
        
        let floats = self as! [Float]
        var mean: Float = 0
        vDSP_meanv(floats, 1, &mean, UInt(count))
        return mean
    }
}

