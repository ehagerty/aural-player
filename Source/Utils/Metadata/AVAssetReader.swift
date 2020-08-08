import Cocoa
import AVFoundation

class AVAssetReader {
    
    static var allParsers: [AVAssetParser] = []
    
    static func initialize(_ commonAVAssetParser: CommonAVAssetParser, _ id3Parser: ID3Parser, _ iTunesParser: ITunesParser, _ audioToolboxParser: AudioToolboxParser) {

        let osVersion = SystemUtils.osVersion

        if (osVersion.majorVersion == 10 && osVersion.minorVersion >= 13) || osVersion.majorVersion > 10 {
            self.allParsers = [commonAVAssetParser, id3Parser, iTunesParser, audioToolboxParser]

        } else {
            self.allParsers = [commonAVAssetParser, id3Parser, iTunesParser]
        }
    }
    
    static func buildMap(for asset: AVURLAsset) -> AVFMetadataMap {
        
        let mapForTrack = AVFMetadataMap(for: asset)
        allParsers.forEach {$0.mapTrack(mapForTrack)}
        
        return mapForTrack
    }
    
    static func getPrimaryMetadata(from map: AVFMetadataMap) -> PrimaryMetadata {
        
        let title = nilIfEmpty(getTitle(from: map))
        let artist = nilIfEmpty(getArtist(from: map))
        let album = nilIfEmpty(getAlbum(from: map))
        let genre = nilIfEmpty(getGenre(from: map))
        
        let duration = getDuration(from: map)
        let art = getArt(from: map)
        
        return PrimaryMetadata(title: title, artist: artist, album: album, genre: genre, duration: duration, coverArt: art)
    }
    
    private static func nilIfEmpty(_ string: String?) -> String? {
        return StringUtils.isStringEmpty(string) ? nil : string
    }
    
    static func getDuration(from map: AVFMetadataMap) -> Double {

        // TODO: Packet table for raw streams ?
        
        var maxDuration: Double = map.asset.duration.seconds
        
        for parser in allParsers {
            
            if let duration = parser.getDuration(map), duration > maxDuration {
                maxDuration = duration
            }
        }
        
        return maxDuration
    }
    
    private static func getTitle(from map: AVFMetadataMap) -> String? {
        
        for parser in allParsers {
            
            if let title = parser.getTitle(map) {
                return title
            }
        }
        
        return nil
    }
    
    private static func getArtist(from map: AVFMetadataMap) -> String? {
        
        for parser in allParsers {
            
            if let artist = parser.getArtist(map) {
                return artist
            }
        }
        
        return nil
    }
    
    private static func getAlbum(from map: AVFMetadataMap) -> String? {
        
        for parser in allParsers {
            
            if let album = parser.getAlbum(map) {
                return album
            }
        }
        
        return nil
    }
    
    private static func getGenre(from map: AVFMetadataMap) -> String? {
        
        for parser in allParsers {
            
            if let genre = parser.getGenre(map) {
                return genre
            }
        }
        
        return nil
    }
    
    static func getSecondaryMetadata(from map: AVFMetadataMap) -> SecondaryMetadata {
        
        let discInfo = getDiscNumber(from: map)
        let trackInfo = getTrackNumber(from: map)
        let lyrics = nilIfEmpty(getLyrics(from: map))
        
        return SecondaryMetadata(discNumber: discInfo?.number, totalDiscs: discInfo?.total, trackNumber: trackInfo?.number, totalTracks: trackInfo?.total, lyrics: lyrics)
    }
    
    private static func getDiscNumber(from map: AVFMetadataMap) -> (number: Int?, total: Int?)? {
        
        for parser in allParsers {
            
            if let discNum = parser.getDiscNumber(map) {
                return discNum
            }
        }
        
        return nil
    }
    
    private static func getTrackNumber(from map: AVFMetadataMap) -> (number: Int?, total: Int?)? {
        
        for parser in allParsers {
            
            if let trackNum = parser.getTrackNumber(map) {
                return trackNum
            }
        }
        
        return nil
    }
    
    private static func getLyrics(from map: AVFMetadataMap) -> String? {
        
        if let lyrics = map.asset.lyrics {
            return lyrics
        }
        
        for parser in allParsers {
            
            if let lyrics = parser.getLyrics(map) {
                return lyrics
            }
        }
        
        return nil
    }
    
    // TODO: Revisit this static func and the use cases needing it
    static func getDurationForFile(_ file: URL) -> Double {
        return AVURLAsset(url: file, options: nil).duration.seconds
    }
    
    static func getAllMetadata(from map: AVFMetadataMap) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for parser in allParsers {
            
            let parserMetadata = parser.getGenericMetadata(map)
            parserMetadata.forEach({(k,v) in metadata[k] = v})
        }
        
        return metadata
    }
    
    static func getArt(from map: AVFMetadataMap) -> CoverArt? {
        
        for parser in allParsers {
            
            if let art = parser.getArt(map) {
                return art
            }
        }
        
        return nil
    }
    
    static func getArt(_ file: URL) -> CoverArt? {
        return getArt(AVURLAsset(url: file, options: nil))
    }
    
    // Retrieves artwork for a given track, if available
    private static func getArt(_ asset: AVURLAsset) -> CoverArt? {
        
        for parser in allParsers {
            
            if let art = parser.getArt(asset) {
                return art
            }
        }
        
        return nil
    }
    
    // Reads all chapter metadata for a given track
    // NOTE - This code does not account for potential overlaps in chapter times due to bad metadata ... assumes no overlaps
    static func getChapters(_ track: Track) -> [Chapter] {

        // On older systems (Sierra/HighSierra), the end times are not properly read by AVFoundation
        // So, use start times to compute end times / duration
//        let fileExtension = track.file.pathExtension.lowercased()
//        let useAlternativeComputation = SystemUtils.osVersion.minorVersion < 14 && !["m4a", "m4b"].contains(fileExtension)
//
//        if useAlternativeComputation {
//            return getChapters_olderSystems(track)
//        }
        
        var chapters: [Chapter] = []
        
//        if let asset = track.avfTrackInfo, let langCode = asset.availableChapterLocales.first?.languageCode {
//
//            let chapterMetadataGroups = asset.chapterMetadataGroups(bestMatchingPreferredLanguages: [langCode])
//
//            // Each group represents one chapter
//            for group in chapterMetadataGroups {
//
//                let title: String = getChapterTitle(group.items) ?? ""
//
//                let timeRange = group.timeRange
//                let start = timeRange.start.seconds
//                let end = timeRange.end.seconds
//                let duration = timeRange.duration.seconds
//
//                // Validate the time fields for NaN and negative values
//                let correctedStart = (start.isNaN || start < 0) ? 0 : start
//                let correctedEnd = (end.isNaN || end < 0) ? 0 : end
//                let correctedDuration = (duration.isNaN || duration < 0) ? nil : duration
//
//                chapters.append(Chapter(title, correctedStart, correctedEnd, correctedDuration))
//            }
//
//            // Sort chapters by start time, in ascending order
//            chapters.sort(by: {(c1, c2) -> Bool in c1.startTime < c2.startTime})
//
//            // Correct the (empty) chapter titles if required
//            for index in 0..<chapters.count {
//
//                // If no title is available, create a default one using the chapter index
//                if chapters[index].title.trim().isEmpty {
//                    chapters[index].title = String(format: "Chapter %d", index + 1)
//                }
//            }
//        }
        
        return chapters
    }
    
    // On older systems (Sierra/HighSierra), the end times are not properly read by AVFoundation
    // So, use start times to compute end times / duration
    static func getChapters_olderSystems(_ track: Track) -> [Chapter] {
        
        // TODO: BUG - This code assumes chapters are sorted by startTime.
        // First sort by startTime, then use start times to compute end times / durations.
        
        var chapters: [Chapter] = []
        
//        if let asset = track.avfTrackInfo, let langCode = asset.availableChapterLocales.first?.languageCode {
//
//            let chapterMetadataGroups = asset.chapterMetadataGroups(bestMatchingPreferredLanguages: [langCode])
//
//            // Collect title and start time from each group
//            var titlesAndStartTimes: [(title: String, startTime: Double)] =
//                chapterMetadataGroups.map {(getChapterTitle($0.items) ?? "", $0.timeRange.start.seconds)}
//
//            if titlesAndStartTimes.isEmpty {return chapters}
//
//            // Start times must be in ascending order
//            titlesAndStartTimes.sort(by: {$0.startTime < $1.startTime})
//
//            for index in 0..<titlesAndStartTimes.count {
//
//                let title = titlesAndStartTimes[index].title
//                let start = titlesAndStartTimes[index].startTime
//
//                // Use start times to compute end times and durations
//
//                let end = index == titlesAndStartTimes.count - 1 ? track.duration : titlesAndStartTimes[index + 1].startTime
//                let duration = end - start
//
//                // Validate the time fields for NaN and negative values
//                let correctedStart = (start.isNaN || start < 0) ? 0 : start
//                let correctedEnd = (end.isNaN || end < 0) ? 0 : end
//                let correctedDuration = (duration.isNaN || duration < 0) ? nil : duration
//
//                chapters.append(Chapter(title, correctedStart, correctedEnd, correctedDuration))
//            }
//
//            // Sort chapters by start time, in ascending order
//            chapters.sort(by: {(c1, c2) -> Bool in c1.startTime < c2.startTime})
//
//            // Correct the (empty) chapter titles if required
//            for index in 0..<chapters.count {
//
//                // If no title is available, create a default one using the chapter index
//                if chapters[index].title.trim().isEmpty {
//                    chapters[index].title = String(format: "Chapter %d", index + 1)
//                }
//            }
//        }
        
        return chapters
    }
    
    // Delegates to all parsers to try and find title metadata among the given items
    private static func getChapterTitle(_ items: [AVMetadataItem]) -> String? {

        for parser in allParsers {
            
            if let title = parser.getChapterTitle(items) {
                // Found
                return title
            }
        }
        
        // Not found
        return nil
    }
}

extension Data {
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

class AVFMetadataMap {
    
    let asset: AVURLAsset
    
    var map: [String: AVMetadataItem] = [:]
    var genericItems: [AVMetadataItem] = []
    
    init(for asset: AVURLAsset) {
        self.asset = asset
    }
}

extension AVMetadataItem {
    
    var commonKeyAsString: String? {
        return commonKey?.rawValue ?? nil
    }
    
    var keyAsString: String? {
        
        if let key = self.key as? String {
            return StringUtils.cleanUpString(key).trim()
        }
        
        if let id = self.identifier {
            
            let tokens = id.rawValue.split(separator: "/")
            if tokens.count == 2 {
                return StringUtils.cleanUpString(String(tokens[1].trim().replacingOccurrences(of: "%A9", with: "@"))).trim()
            }
        }
        
        return nil
    }
    
    var valueAsString: String? {

        if !StringUtils.isStringEmpty(self.stringValue) {
            return self.stringValue
        }
        
        if let number = self.numberValue {
            return String(describing: number)
        }
        
        if let data = self.dataValue {
            return String(data: data, encoding: .utf8)
        }
        
        if let date = self.dateValue {
            return String(describing: date)
        }
        
        return nil
    }
    
    var valueAsNumericalString: String {
        
        if !StringUtils.isStringEmpty(self.stringValue), let num = Int(self.stringValue!) {
            return String(describing: num)
        }
        
        if let number = self.numberValue {
            return String(describing: number)
        }
        
        if let data = self.dataValue, let num = Int(data.hexEncodedString(), radix: 16) {
            return String(describing: num)
        }
        
        return "0"
    }
}
