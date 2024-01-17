from datetime import datetime
from math import sin
import re
import json

date_string = "2022-01-16 12:30:45"
format_string = "%Y-%m-%d %H:%M:%S"

print(datetime.strptime(date_string, format_string) < datetime.now())
