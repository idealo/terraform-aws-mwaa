import json
import logging
import os
import re
from html import escape
from urllib.error import URLError, HTTPError
from urllib.request import Request, urlopen

HOOK_URL = os.environ['HookUrl']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

airflow_message_keys_to_filter = ("Log", "Host", "Log file", "Mark success")


def lambda_handler(event, context):
    logger.info("Event: " + str(event))
    subject = event['Records'][0]['Sns']['Subject']
    message = event['Records'][0]['Sns']['Message']
    # logger.info("Message: " + str(message))

    message_lines = message.split('\n')
    airflow_dict = extract_keys(message_lines, airflow_message_keys_to_filter)
    message_lines = filter_lines_starting_with_prefix(message_lines, airflow_message_keys_to_filter)
    message_lines = [l for l in message_lines if l.strip()]

    ms_teams_message = {
        "@context": "https://schema.org/extensions",
        "@type": "MessageCard",
        "themeColor": "d63333",  # green: "64a837",
        "title": escape(subject),
        "text": '<br>'.join([escape(line) for line in message_lines]),
        "potentialAction": [
            {
                "@type": "OpenUri",
                "name": "View Log",
                "targets": [
                    {"os": "default", "uri": airflow_dict["Log"]}
                ]
            }
        ] if "Log" in airflow_dict else []
    }

    req = Request(HOOK_URL, json.dumps(ms_teams_message).encode('utf-8'))
    try:
        response = urlopen(req)
        response.read()
        logger.info("Message posted")
        return {"status": "200 OK"}
    except HTTPError as e:
        logger.error("Request failed: %d %s", e.code, e.reason)
    except URLError as e:
        logger.error("Server connection failed: %s", e.reason)


def extract_keys(strings, keys_to_extract):
    p = re.compile('^(' + '|'.join(keys_to_extract) + '): (.*)$')
    key_dict = {}
    for str in strings:
        m = p.match(str)
        if m:
            key_dict[m.group(1)] = m.group(2)
    return key_dict


def filter_lines_starting_with_prefix(strings, prefixes):
    return [s for s in strings if not s.startswith(tuple([p + ": " for p in prefixes]))]