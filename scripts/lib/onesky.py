# -*- coding: utf8 -*-

from multipart import MultiPartForm
import urllib2
import urllib
import datetime
import md5


def _authenticate(secret_key):
    timestamp = datetime.datetime.now().strftime("%s")
    dev_hash = md5.md5(timestamp + secret_key).hexdigest()
    return timestamp, dev_hash


def upload(api_key, api_secret, project_id, filename, file):
    timestamp, dev_hash = _authenticate(api_secret)

    form = MultiPartForm()
    form.add_field('api_key', api_key)
    form.add_field('timestamp', timestamp)
    form.add_field('dev_hash', dev_hash)
    form.add_field('is_keeping_all_strings', 'true')
    form.add_field('file_format', 'IOS_STRINGS')

    form.add_file('file', filename, fileHandle=file)

    body = str(form)

    request = urllib2.Request('https://platform.api.onesky.io/1/projects/%s/files' % (project_id))
    request.add_header('content-type', form.get_content_type())
    request.add_header('content-length', len(body))
    request.add_data(body)

    try:
        response = urllib2.urlopen(request)
        #print response.read()
    except urllib2.HTTPError as e:
        raise Exception(e.read())


def download(api_key, api_secret, project_id, filename, locale, file):
    timestamp, dev_hash = _authenticate(api_secret)

    params = {
        'api_key': api_key,
        'timestamp': timestamp,
        'dev_hash': dev_hash,
        'locale': locale,
        'source_file_name': filename,
    }

    # Build the request
    request_params =  urllib.urlencode(params)
    request = urllib2.Request('https://platform.api.onesky.io/1/projects/%s/translations?%s' % (project_id, request_params))

    try:
        response = urllib2.urlopen(request)

        with open(file, 'w') as f:
            f.write(response.read())
    except urllib2.HTTPError as e:
        raise Exception(e.read())
