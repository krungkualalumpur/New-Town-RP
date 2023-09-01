import pandas as pd
import pbit
import midas
import midas.playfab as pf
import midas.data_encoder as de
from midas.playfab import PlayFabClient
from midas.data_encoder import BaseStateTree, DecodedRowData, VersionData, IndexData, IdentificationData
from pandas import DataFrame
from typing import Any, TypedDict
import dpath

dpath.options.ALLOW_EMPTY_STRING_KEYS = True

DASHBOARD_PATH = "Analytics/main.pbit"
INPUT_EVENT_JSON_PATH = "Analytics/file.json"
OUTPUT_DIR = "Analytics/output"
OUTPUT_KPI_PATH = OUTPUT_DIR+"/kpi"
EVENTS_JSON = OUTPUT_DIR+"/events.json"
SESSIONS_JSON = OUTPUT_KPI_PATH+"/sessions.json"
USERS_JSON = OUTPUT_KPI_PATH+"/users.json"

def format_data():
    # export data into json
    df = pd.read_json(INPUT_EVENT_JSON_PATH)

    print("READ STUFF")
    events, sessions, users = midas.load(df)

    # # export data
    print("constructing event table")
    event_df = DataFrame(midas.dump(events))
    event_df.to_json(EVENTS_JSON, indent=4, orient="records")

    print("constructing session table")
    session_df = DataFrame(midas.dump(sessions))
    session_df.to_json(SESSIONS_JSON, indent=4, orient="records")

    print("constructing user table")
    session_df = DataFrame(midas.dump(users))
    session_df.to_json(USERS_JSON, indent=4, orient="records")

    
def build_model():
    # construct pbit
    print("loading pbit model")
    model = pbit.load_model(DASHBOARD_PATH)
    model.clear()

    # create user table
    print("creating user table")
    user_table = model.new_table("users")
    user_table.bind_to_json(USERS_JSON, {
        "user_id":"string",
        "timestamp":"dateTime",
        "index": "int64",
        "session_count": "int64",
        "revenue": "int64",
        "duration": "double",
        "is_retained_on_d0": "boolean",
        "is_retained_on_d1": "boolean",
        "is_retained_on_d7": "boolean",
        "is_retained_on_d14": "boolean",
        "is_retained_on_d28": "boolean",
    })

    user_table.new_measure("d0_rr").set_to_retention_rate_tracker("users", "is_retained_on_d0")
    user_table.new_measure("d1_rr").set_to_retention_rate_tracker("users", "is_retained_on_d1")
    user_table.new_measure("d7_rr").set_to_retention_rate_tracker("users", "is_retained_on_d7")
    user_table.new_measure("d14_rr").set_to_retention_rate_tracker("users", "is_retained_on_d14")
    user_table.new_measure("d28_rr").set_to_retention_rate_tracker("users", "is_retained_on_d28")

    # create session table
    print("creating session table")
    session_table = model.new_table("sessions")
    session_table.bind_to_json(SESSIONS_JSON, {
        "user_id":"string",
        "session_id": "string",
        "version_text":"string",
        "index": "int64",
        "event_count": "int64",
        "revenue": "int64",
        "duration": "double"
    })

    session_table.new_dax_column("sessions[duration] / 60", "duration_minutes_unrounded")
    session_table.new_bin("duration_minutes_unrounded", 1, bin_name = "duration_minutes")
    session_table.new_bin("revenue", 25)
    session_table.new_normalized_column("event_count", "duration_minutes", name = "events_per_minute")

    model.new_relationship("sessions", "user_id", "users", "user_id")

    # create event table
    print("creating event table")
    event_table = model.new_table("events")
    event_table.bind_to_json(EVENTS_JSON, {
        "name": "string",
        "session_id": "string",
        "event_id": "string",
        "timestamp":"dateTime",
        "index": "int64",
    })

    model.new_relationship("events", "session_id", "sessions", "session_id")

    # create relationships
    print("creating relationships")
    print("writing model")
    pbit.write_model(DASHBOARD_PATH, model)

    print("pbit model update complete")

format_data()
#build_model()