# `spotify-export`

Python script to export Spotify playlists to CSV files.

<!-- markdownlint-disable MD013 -->

## Usage

1. Create an app on the [Spotify developer portal](https://developer.spotify.com/dashboard).
   The redirect URI is not needed here, so let's use something like `http://localhost:3000`.

2. Go to settings to grab the Client ID and the Client Secret, then put them into a `.env` file:

   ```text
   # .env file
   CLIENT_ID=...
   CLIENT_SECRET=...
   ```

3. Run the script

   ```shell
   python ./spotify_export.py "<playlist_url>"
   ```
