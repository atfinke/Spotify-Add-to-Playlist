//
//  AuthenticationManager.swift
//  SpotifyAddToPlaylist
//
//  Created by Andrew Finke on 9/18/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import Cocoa

class AuthenticationManager {

    // MARK: - Properties

    private var authorizationCode: String? {
        get {
            return UserDefaults.standard.string(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }

    private var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }

    private var accessTokenExpiration: Date? {
        get {
            return UserDefaults.standard.object(forKey: #function) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }

    private var refreshToken: String? {
        get {
            return UserDefaults.standard.string(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }

    private var isAccessTokenValid: Bool {
        if accessToken != nil,
            let date = accessTokenExpiration,
            date.timeIntervalSinceNow > 60 {
            return true
        } else {
            return false
        }
    }

    // MARK: - Authorization Code

    private func requestAuthorizationCode () {
        print(#function)

        guard !isAccessTokenValid else { return }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "accounts.spotify.com"
        components.path = "/authorize"

        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: Configuration.shared.clientID),
            URLQueryItem(name: "scope", value: "playlist-modify-private playlist-modify-public"),
            URLQueryItem(name: "redirect_uri", value: Configuration.shared.redirectURI)
        ]

        guard let url = components.url else { fatalError() }
        NSWorkspace.shared.open(url)
    }

    func handleOpenURL(_ components: URLComponents) {
        print(#function)

        guard components.queryItems?.count == 1,
            let item = components.queryItems?.first,
            item.name == "code",
            let code = item.value else {
                Result.error("Invalid open url scheme")
                return
        }
        authorizationCode = code
        requestAccessToken()

        Result.error("[Expected] Got first code, try again")
    }

    // MARK: - Access Code

    //swiftlint:disable:next function_body_length
    func requestAccessToken(completion: ((String?) -> Void)? = nil) {
        print(#function)

        if isAccessTokenValid, let token = accessToken {
            completion?(token)
            return
        }

        let additionalQueryItems: [URLQueryItem]
        if let token = refreshToken {
            additionalQueryItems = [
                URLQueryItem(name: "grant_type", value: "refresh_token"),
                URLQueryItem(name: "refresh_token", value: token)
            ]
        } else if let code = authorizationCode {
            additionalQueryItems = [
                URLQueryItem(name: "grant_type", value: "authorization_code"),
                URLQueryItem(name: "code", value: code)
            ]
        } else {
            requestAuthorizationCode()
            completion?(nil)
            return
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "accounts.spotify.com"
        components.path = "/api/token"

        components.queryItems = [
            URLQueryItem(name: "redirect_uri", value: Configuration.shared.redirectURI),
            URLQueryItem(name: "client_id", value: Configuration.shared.clientID),
            URLQueryItem(name: "client_secret", value: Configuration.shared.clientSecret)
        ]
        components.queryItems?.append(contentsOf: additionalQueryItems)

        guard let url = components.url else { fatalError() }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(response as Any)
                print(error)
                Result.error("Failed to fetch access token")
                completion?(nil)
            } else if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let accessToken = json??["access_token"] as? String,
                    let expiresIn = json??["expires_in"] as? Int else {
                        Result.error("Invalid access token json")
                        return
                }

                self.accessToken = accessToken
                self.accessTokenExpiration = Date(timeIntervalSinceNow: TimeInterval(expiresIn))
                self.refreshToken = (json??["refresh_token"] as? String) ?? self.refreshToken

                completion?(accessToken)
            }
        }
        task.resume()
    }

}
