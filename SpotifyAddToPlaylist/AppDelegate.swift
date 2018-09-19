//
//  AppDelegate.swift
//  SpotifyAddToPlaylist
//
//  Created by Andrew Finke on 9/18/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    // MARK: - NSApplicationDelegate

    func applicationDidFinishLaunching(_ notification: Notification) {
        let eventManager = NSAppleEventManager.shared()
        eventManager.setEventHandler(self,
                                     andSelector: #selector(handleEvent(_:)),
                                     forEventClass: AEEventClass(kInternetEventClass),
                                     andEventID: AEEventID(kAEGetURL))

        guard let bundleID = Bundle.main.bundleIdentifier else { fatalError() }
        LSSetDefaultHandlerForURLScheme("spotify-add-to-playlist" as CFString, bundleID as CFString)

        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()

        start()
    }

    @objc func handleEvent(_ event: NSAppleEventDescriptor) {
        guard let descriptor = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)),
            let stringValue = descriptor.stringValue,
            let components = URLComponents(string: stringValue) else {
                return
        }
        AuthenticationManager.shared.handleOpenURL(components)
    }

    // MARK: - NSUserNotificationCenterDelegate

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }

    // MARK: - Main

    func start() {
        guard let track = NowPlayingFetcher().track else {
            Result.error("Failed to get track")
            return
        }

        AuthenticationManager.shared.requestAccessToken { accessToken in
            guard let token = accessToken else { return }

            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.spotify.com"
            components.path = "/v1/users/" + Configuration.shared.username + "/playlists/" + Configuration.shared.playlistID + "/tracks"

            components.queryItems = [
                URLQueryItem(name: "playlist_id", value: Configuration.shared.playlistID),
                URLQueryItem(name: "uris", value: track.uri)
            ]

            guard let url = components.url else { fatalError() }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print(error)
                    print(response as Any)
                    Result.error("Error when adding track")
                } else if let data = data {
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                        json?["snapshot_id"] != nil else {
                            Result.error("Error when reading snapshot json")
                            return
                    }
                    Result.success("\(track.name) by \(track.artist)")
                }
            }
            task.resume()
        }

    }
}

