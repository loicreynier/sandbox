"""OPUS to MP3 conversion script (for local playback on Spotify).

Usage:

    python ./spotify_opus2mp3.py -- *.opus

This script uses the FFMPEG library (`ffmpeg-python`) to convert OPUS audio files
provided as command-line arguments into MP3 format.
Spotify does not accept lossless audio formats for local files,
necessitating the convsertion to MP3.

The script uses the mutagen library to improve the formatting of artist metadata.
In the absence of this metadata modification, multiple artist would appear
in the Spotify interface as

    Artist1;Artist2;Artist3;

The rectifies this issue, by concataning the `artist` tag to a single string,
resulting in

    Artist1, Artist2, Artist3

in Spotify interface.

The script will produce MP3 files in the same directory as the input OPUS files,
maintaining the same file names but with the `.mp3` extension.

Currently, no tests are implemented to verify whether
the input are indeed in OPUS format or if the artist metadata has proper formatting.
The only implemented test checks whether the input file is not already an MP3
(extension test on the file name).
If that's the case, the conversion is not performed,
and the metadata is updated directly.
"""

from pathlib import Path
from typing import List

import ffmpeg
import mutagen
import typer


def main(files: List[Path]):
    suffix = ".mp3"
    for filename in files:
        filename = Path(filename)
        if filename.suffix != suffix:
            convert(filename, suffix=suffix)
        update_artist(filename.with_suffix(suffix))


def convert(filename: Path, suffix=".mp3") -> None:
    """Convert `filename` to an MP3 file using FFMPEG."""
    (
        ffmpeg.input(
            filename,
        )
        .output(
            str(filename.with_suffix(suffix)),
            acodec="libmp3lame",
            **{
                "qscale:a": 2,  # Let encoder choose quality
                "map_metadata": "0:s:a:0",  # Copy metadata
            },
        )
        .run(
            overwrite_output=True,
            quiet=True,
        )
    )


def update_artist(filename: Path) -> None:
    audio = mutagen.File(
        filename,
        easy=True,  # prevents from using the ID3 interface
    )
    audio["artist"] = [audio["artist"][0].replace(";", ", ")]
    audio.save()
    # print(audio)


if __name__ == "__main__":
    typer.run(main)
