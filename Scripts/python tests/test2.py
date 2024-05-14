from datetime import datetime
from math import sin
import re
import json

date_string = "2024-05-13 12:30:45"
format_string = "%Y-%m-%d %H:%M:%S"

test = {
    1 : 2
}
print("eeh"+'2')

try:
    print("eeh" + 2)
    print(test[2] + 1)

except:
    print("Doesnt print?")
print((datetime.timestamp(datetime.now()) - datetime.timestamp(datetime.strptime(date_string, format_string)))/(24*60*60))
