# Spotify - Add to Playlist

This is a simple macOS app that when launched, attempts to add the currently playing song in Spotify to a specified playlist. It then swiftly exits, presenting a success/failure notification. This was designed to be used as a service (w/ Automator) so you can quickly save a song, no matter what app you're in.

## Configuration

To use this, you'll need to set the keys in the configuration.plist file in the app bundle. You'll need your Spotify username, the playlist id to save songs to, and a Spotify application client ID + secret.
