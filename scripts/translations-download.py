#!/usr/bin/python
# -*- coding: utf8 -*-

from lib.onesky import download
import argparse
import os


ONESKY_FILE = "TinkLinkUI.strings"


PROJECTS = [
    {
        'name': 'TinkLinkUI',
        'project_id': '170340', # Tink - SDK iOS
        'locales': ['en-US', 'sv-SE']
    }
]


def makepath(root_directory, project, locale):
    return os.path.join(root_directory, "sources", project, "Translations.bundle", "%s.lproj" % locale, ONESKY_FILE)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Download translations from Onesky.')
    parser.add_argument('--api-key', type=str)
    parser.add_argument('--api-secret', type=str)
    args = parser.parse_args()

    onesky_api_key = args.apikey
    onesky_api_secret = args.apisecret

    script_directory = os.path.dirname(__file__)
    root_directory = os.path.dirname(script_directory)

    for project in PROJECTS:
        for locale in project['locales']:
            try:
                file = makepath(root_directory, project['name'], locale)
                if not os.path.exists(os.path.dirname(file)):
                    file = makepath(root_directory, project['name'], locale.split("-")[0])

                download(onesky_api_key, onesky_api_secret, project['project_id'], ONESKY_FILE, locale, file)
                print '✅  %s -> %s' % (locale, file)
            except Exception as e:
                print '🚨  %s' % locale
                print e
