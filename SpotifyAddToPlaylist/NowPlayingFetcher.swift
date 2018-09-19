//
//  NowPlayingFetcher.swift
//  SpotifyAddToPlaylist
//
//  Created by Andrew Finke on 9/18/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import Foundation

/// Using AppleScript to grab the song so we never have to wait for network request / auth flow

struct NowPlayingFetcher {

    // MARK: - Types

    struct Track {
        let name: String
        let artist: String
        let uri: String
    }

    // MARK: - Properties

    private let script: NSAppleScript = {
        guard let url = Bundle.main.url(forResource: "TrackGetter", withExtension: "scpt"),
            let script = NSAppleScript(contentsOf: url, error: nil) else {
                fatalError()
        }
        return script
    }()

    var track: Track? {
        guard let output = script.executeAndReturnError(nil).stringValue else {
            return nil
        }

        let components = output.components(separatedBy: "||")
        guard components.count == 3 else {
            return nil
        }

        return Track(name: components[0],
                     artist: components[1],
                     uri: components[2])
    }
}
