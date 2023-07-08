#!/usr/bin/env python3

"""Script to generate the `README.md`"""

__author__ = ["Loïc Reynier <loic@loicreynier.fr>"]
__version__ = "0.1.0"

import os
import glob
import sys

README = "../README.md"
TEMPLATE = "template.md"


def make_readme() -> None:
    """Make `README.md` from `template.md`."""
    castles = glob.glob("../*/")
    castles.remove("../docs/")
    with open(README, "w", encoding="utf-8") as readme_file:
        # Copy template
        with open(TEMPLATE, "r", encoding="utf-8") as template_file:
            readme_file.write(template_file.read())
        readme_file.write("\n")
        # Generate sand castles list
        for path in castles:
            try:
                with open(
                    path + "README.md", "r", encoding="utf-8"
                ) as src_file:
                    lines = src_file.readlines()
                    title = lines[0][2:-1]
                    desc = lines[2][:-1]
                    readme_file.write(f"- {title}: {desc}\n")
            except FileNotFoundError as error:
                print(error)
                pass


if __name__ == "__main__":
    os.chdir(sys.path[0])
    # print(os.path.basename(__file__) + ": running in " + os.getcwd())
    make_readme()
