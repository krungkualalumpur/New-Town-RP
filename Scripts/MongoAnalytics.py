#packages
import os
import json
import pandas
from datetime import datetime 
#constants
MONGO_PASSWORD = "0ff3BrdCKJkqgSIs"
#local functions
def create_session():
    database = "user"
    collection = "session"
    json_path = "Analytics/output/session_ids.json"
    
    path = os.path.abspath("Analytics/bin/mongoexport.exe")

    command_tags = [
        path,
        f"--uri mongodb+srv://aryoseno11:{MONGO_PASSWORD}@analytics.ueyx6uw.mongodb.net/{database}",
        f"--collection {collection}",
        f"--out {json_path}"
    ]
    command = " ".join(command_tags)
    os.system(command)

    session_data = []

    values_to_pop = (
        "_id", 
        "event_name",
        "ping",
        "account_age",
        "language",
        "duration_after_joined",
        "device",
        "is_premium",
        "screen_size",
        "play_duration",
        "is_retained_on_d0",
        "is_retained_on_d1",
        "is_retained_on_d7",
        "is_retained_on_d14",
        "is_retained_on_d28",
    )

    with open (json_path, "r", buffering= -1, encoding='utf-8' ) as file:
        content = file.read()
        for line in content.splitlines():

            data = json.loads(line)
            
            sessionAlreadyExists = False
            user_First_Session = True

            for existing_data in session_data:
                if data["session_id"] == existing_data["session_id"]:
                    sessionAlreadyExists = True
                    break
            
            print(data)
            if not sessionAlreadyExists:
                _id = data["_id"]
                
                timestamp = data["timestamp"] 
                if (type(_id) == dict) and ("$oid" in _id):
                    data["event_id"] = _id["$oid"] 
                
                if (type(timestamp) == dict) and ("$date" in timestamp):
                    data["timestamp"] = timestamp["$date"]

                if "_id" in data:
                    data.pop("_id")
                if "event_name" in data:
                    data.pop("event_name")
                
                for val in values_to_pop:
                    if val in data:
                        data.pop(val)

                data["IsFirstSession"] = user_First_Session

                session_data.append(data)

    for data in session_data:
        for otherData in session_data:
            if (data["user_id"] == otherData["user_id"]) and (data["session_id"] != otherData["session_id"]):
                currentDataTimeStr : str = data["timestamp"]
                otherDataTimeStr : str = otherData["timestamp"]
                currentDataTime_object = datetime.strptime(currentDataTimeStr, f"%Y-%m-%dT%H:%M:%S{'.%f' if '.' in currentDataTimeStr else ''}Z")
                otherDataTime_object = datetime.strptime(otherDataTimeStr, f"%Y-%m-%dT%H:%M:%S{'.%f' if '.' in otherDataTimeStr else ''}Z")

                currentTimestamp = datetime.timestamp(currentDataTime_object)
                otherTimestamp = datetime.timestamp(otherDataTime_object)

                if currentTimestamp > otherTimestamp:
                    data["IsFirstSession"] = False
                    break


    with open (json_path, "w") as file:
        json_data = json.dumps(session_data, indent=10)
        file.write(json_data)
    
    return session_data
        

def download_raw(database: str, collection: str):
    json_path = "Analytics/output/"+ database + "/" + collection + ".json"
    #dir_path = get_dir_path(database, collection)

    #if not os.path.exists(dir_path):
        #os.makedirs(dir_path)

    path = os.path.abspath("Analytics/bin/mongoexport.exe")

    command_tags = [
        path,
        f"--uri mongodb+srv://aryoseno11:{MONGO_PASSWORD}@analytics.ueyx6uw.mongodb.net/{database}",
        f"--collection {collection}",
        f"--out {json_path}"
    ]
    command = " ".join(command_tags)
    os.system(command)

    data = []

    with open(json_path, "r", encoding='utf-8') as json_file:
        content = json_file.read()
        for line in content.splitlines():
            entry = json.loads(line)
            if not "iteration" in entry:
                entry["iteration"] = 0

            #if "build" in entry:
                #build_to_version[str(entry["build"])] = entry["version"]

            if "timestamp" in entry:
                t_data = entry["timestamp"]
                if type(t_data) == dict and "$date" in t_data:
                    entry["timestamp"] = t_data["$date"]        
            if "_id" in entry:
                i_data = entry["_id"]
                if type(i_data) == dict and "$oid" in i_data: 
                    entry["_id"] = i_data["$oid"]        
                entry["event_id"] = entry["_id"]
                entry.pop("_id")

            data.append(entry)

    with open(json_path, "w") as json_write_file:
        json_write_file.write(json.dumps(data, indent=10))

    return json_path



json_path = "Analytics/file.json"
path = os.path.abspath("Analytics/bin/mongoexport.exe")

project = "Analytics"

database1 = "server"
database1collection1 = "performance"
database1collection2 = "population"

database2 = "user"
database2collection1 = "map"
database2collection2 = "session"
database2collection3 = "demography"

database3 = "events"
database3collection1 = "backpack"
database3collection2 = "customization"
database3collection3 = "vehicles"
database3collection4 = "houses"
database3collection5 = "miscs"
database3collection6 = "interface"

create_session()
download_raw(database1, database1collection1)
download_raw(database1, database1collection2)

download_raw(database2, database2collection1)
download_raw(database2, database2collection2)
download_raw(database2, database2collection3)

download_raw(database3, database3collection1)
download_raw(database3, database3collection2)
download_raw(database3, database3collection3)
download_raw(database3, database3collection4)
download_raw(database3, database3collection5)
download_raw(database3, database3collection6)
