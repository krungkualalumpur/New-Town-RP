import requests
import json

FILE_PATH = "./src/Shared/Balancing/" 

DATA_NAME = "WheelDataBalancing"

SHEET_ID = "18LW1YyVwR_LporJwX4BHPJYOC_RWHktCXrizNzhnzxA"
PAGE_ID = "2077587884"

URL_BASE = "https://docs.google.com/spreadsheets/d/"+ SHEET_ID +"/gviz/tq?tqx=out:json&gid=" + PAGE_ID

response = requests.get(URL_BASE, headers= {
    "X-DataSource-Auth": "true"
})

LUA_CODE = ""
if response.status_code == 200:
    t = response.text.replace("'", '"').replace(')]}"', "")
    jContent = json.loads(t)
    #for k, v in jContent["table"].items():
        #print("----------- \n" , k , " : " , v , "\n ------------")
    TYPE_NAME = DATA_NAME + "Data"
    LUA_CODE += "--!strict \nexport type " + TYPE_NAME + " = {"
    for colIndex, colInfo in enumerate(jContent["table"]["cols"]):
        LUA_CODE += "\n\t" + colInfo["label"].replace(" ", "") + " : " + colInfo["type"] + ","
    LUA_CODE += "\n}"

    LUA_CODE += "\nreturn {"

    for rowInfo in jContent["table"]["rows"]:
        #print(rowInfo)
        LUA_CODE += "\n\t{"
        for colIndex, colInfo in enumerate(jContent["table"]["cols"]):            
            #print(colInfo["label"] ,rowInfo["c"][colIndex]["v"])
            _value = rowInfo["c"][colIndex]["v"] if colInfo["type"] != "string" else '"'+  rowInfo["c"][colIndex]["v"] +'"'
            #print(_value, )
            LUA_CODE += f'\n\t\t{colInfo["label"].replace(" ", "")} = {_value},'
        LUA_CODE += "\n\t} :: " + TYPE_NAME + ","

    LUA_CODE += "\n}"
else:
    print("ERROR " + str(response.status_code))

file = open(FILE_PATH + DATA_NAME + ".lua", "w")
file.write(LUA_CODE)
file.close()