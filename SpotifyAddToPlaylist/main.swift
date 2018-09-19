//
//  main.swift
//  SpotifyAddToPlaylist
//
//  Created by Andrew Finke on 9/19/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
