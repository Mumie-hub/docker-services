#!/usr/bin/env python3

import json
from urllib.request import urlopen

url = "https://www.server-residenz.com/tools/ts3versions.json"
response = urlopen(url)
data = json.loads(response.read().decode("utf-8"))
print(data['latest'])