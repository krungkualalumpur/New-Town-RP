#packages
import os
import json
#constants
MONGO_PASSWORD = "0ff3BrdCKJkqgSIs"
#local functions
def download_raw(database: str, collection: str) -> str:
    json_path = "Analytics/output/"+ database + "/" + collection + ".json"
    print(json_path)
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
        json_write_file.write(json.dumps(data, indent=5))

    return json_path



json_path = "Analytics/file.json"
path = os.path.abspath("Analytics/bin/mongoexport.exe")

project = "Analytics"
database1 = "server"
database1collection1 = "performance"
database1collection2 = "population"

database2 = "user"
database2collection1 = "customization"
database2collection2 = "gameplay"
database2collection3 = "map"
database2collection4 = "session"

download_raw(database1, database1collection1)
download_raw(database1, database1collection2)

download_raw(database2, database2collection1)
download_raw(database2, database2collection2)
download_raw(database2, database2collection3)
download_raw(database2, database2collection4)