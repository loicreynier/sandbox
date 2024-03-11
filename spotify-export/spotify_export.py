"""Spotify playlist export script.

Usage:

    python ./spotify_export.py <playlists URLs>

Requires a `.env` file in the local directory containing a Spotify app
Client ID and Client Secret:

    CLIENT_ID=...
    CLIENT_SECRET=...

These variables are loaded using `python-dotenv`. Why?
I wanted to try it since I never used it before writing this script,
and also because writing secrets in the command line is never a good idea.
"""

import csv
import re
import urllib

from pathlib import Path

import dotenv
import spotipy
import typer


def spotify_session(dotenv_file: Path = "./.env") -> spotipy.Spotify:
    """Spotify session using client ID and secret from `dotenv_file`."""
    dotenv_file = Path(dotenv_file)
    if not dotenv_file.exists():
        raise FileNotFoundError(f"'{dotenv_file}' does not exists.")

    vars = dotenv.dotenv_values()
    return spotipy.Spotify(
        client_credentials_manager=spotipy.oauth2.SpotifyClientCredentials(
            client_id=vars["CLIENT_ID"], client_secret=vars["CLIENT_SECRET"]
        )
    )


def is_valid_url(url: str) -> bool:
    """Whether the URL seems valid.

    Not used, replaced the implementation in `playlist_uri_from_link`.
    """
    is_valid = False

    try:
        result = urllib.parse.urlparse(url)
        is_valid = all([result.scheme, result.netloc])
    except AttributeError:
        is_valid = False

    return is_valid


def playlist_uri_from_link(url) -> str:
    """Spotify playlist URI from playlist's URL."""
    match = re.search(
        r"spotify:playlist:(.+)|https://open.spotify.com/playlist/(.+)\?",
        url,
    )

    if not match:
        raise ValueError(f"Invalid Spotify playlist URL: {url}")

    return match.group(1) or match.group(2)


def export_to_csv(uri: str, session: spotipy.Spotify) -> None:
    """Export Spotify playlist identified with `uri` to a CSV of the same name."""
    name = session.playlist(uri)["name"]
    with open(Path(name).with_suffix(".csv"), "w", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(["track", "artist"])

        for track in session.playlist_tracks(uri)["items"]:
            name = track["track"]["name"]
            artists = ", ".join(
                [artist["name"] for artist in track["track"]["artists"]]
            )
            writer.writerow([name, artists])


def main(playlist_urls: list[str]) -> None:
    """Export tracks from `playlist_urls` to CSV files."""
    session = spotify_session()

    for url in playlist_urls:
        export_to_csv(playlist_uri_from_link(url), session)


if __name__ == "__main__":
    typer.run(main)
