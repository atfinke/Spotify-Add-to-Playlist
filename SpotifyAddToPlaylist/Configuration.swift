//
//  Configuration.swift
//  SpotifyAddToPlaylist
//
//  Created by Andrew Finke on 9/18/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import Foundation

class Configuration {

    // MARK: - Properties

    static let shared = Configuration()

    let username: String
    let playlistID: String

    let clientID: String
    let clientSecret: String
    let redirectURI: String

    // MARL: - Initialization

    private init() {
        guard let url = Bundle.main.url(forResource: "Configuration", withExtension: "plist"),
            let configuration = NSDictionary(contentsOf: url) as? [String: String],
            let username = configuration["Username"],
            let playlistID = configuration["Playlist ID"],
            let clientID = configuration["Client ID"],
            let clientSecret = configuration["Client Secret"],
            let redirectURI = configuration["Redirect URI"] else {
                fatalError()
        }

        guard clientID.count > 0 && clientSecret.count > 0 else {
            Result.error("Client keys not set")
            fatalError()
        }

        self.username = username
        self.playlistID = playlistID
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
    }
}
