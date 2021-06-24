//
//  SupportedTypes.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AVFoundation

struct SupportedTypes {
    
    // Supported playlist file types
    
    static let m3u: String = "m3u"
    static let m3u8: String = "m3u8"
    static let playlistExtensions: [String] = [m3u, m3u8]
    
    // Supported audio file types/formats
    
    static let nativeAudioExtensions: [String] = ["aac", "adts", "aif", "aiff", "aifc", "caf", "mp1", "mp2", "mp3", "m4a", "m4b", "m4r", "snd", "au", "sd2", "wav", "ac3", "amr"]
    static let nonNativeAudioExtensions: [String] = ["flac", "oga", "opus", "wma", "dsf", "dsd", "dff", "mpc", "ape", "wv", "mka", "ogg", "tta", "tak", "ra", "rm"]

    static let allAudioExtensions: [String] = nativeAudioExtensions + nonNativeAudioExtensions
    
    // Supported AV Foundation formats
    
    static let avFileTypes: [AVFileType] = [.mp3, .m4a, .aiff, .aifc, .caf, .wav, .ac3, .amr, .au]
    static let avFileTypeStrings: [String] = avFileTypes.map {$0.rawValue}
    
    // File types allowed in the Open file dialog (extensions and UTIs)
    static let all: [String] = allAudioExtensions + playlistExtensions + avFileTypeStrings
}
