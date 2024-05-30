import argparse

argumentParser = argparse.ArgumentParser(
    prog="Generate",
    description="Static Site Generator",
)

argumentParser.add_argument('action', help="Action to perform", type='str', choices=[
    "live",
    "build",
    "clean",
])