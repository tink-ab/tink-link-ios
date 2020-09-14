#!/usr/bin/python
# -*- coding: utf8 -*-

from lib.onesky import upload
import argparse
import os


ONESKY_FILE = "TinkLinkUI.strings"

PROJECTS = [
    {
        'name': 'TinkLinkUI',
        'project_id': '170340', # Tink - SDK iOS
    }
]

GENSTRINGS_COMMAND = "find ./sources/TinkLinkUI -name '*.swift' -print0 | xargs -0 genstrings -s NSLocalizedString -o ."


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Upload translations to Onesky.')
    parser.add_argument('--api-key', type=str)
    parser.add_argument('--api-secret', type=str)
    args = parser.parse_args()

    onesky_api_key = args.api_key
    onesky_api_secret = args.api_secret

    script_directory = os.path.dirname(__file__)
    root_directory = os.path.dirname(script_directory)

    import subprocess
    process = subprocess.Popen(GENSTRINGS_COMMAND, cwd=root_directory, stdout=subprocess.PIPE, shell=True)
    output, error = process.communicate()

    if output: print output
    if error: print error

    file = os.path.join(root_directory, ONESKY_FILE)
    os.rename(os.path.join(root_directory, 'Localizable.strings'), file)

    raw_input('Press enter to continue with upload...')

    for project in PROJECTS:
        with open(file, "r") as f:
            try:
                upload(onesky_api_key, onesky_api_secret, project['project_id'], ONESKY_FILE, f)
                print '✅  %s: %s' % (project['name'], ONESKY_FILE)
            except Exception as e:
                print '🚨  %s: %s' % (project['name'], ONESKY_FILE)
                print e

    os.remove(file)
