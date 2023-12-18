import sys
import os
import pandas as pd
import time
from azure.kusto.data import KustoClient, KustoConnectionStringBuilder, ClientRequestProperties
from adal import AuthenticationContext
from pandas import DataFrame
from pandas import Timestamp
from datetime import datetime
#import midas.playfab as playfab
#import midas.data_encoder as data_encoder
import keyring
import json
import math
#from midas.playfab import PlayFabClient
CLUSTER = "https://insights.playfab.com"

DEFAULT_QUERY ="['events.all'] | limit 100"

PLAYFAB_DATE_FORMAT = "%Y-%m-%d %H:%M:%S.%f%z"
PLAYFAB_DATE_FORMAT_WITHOUT_FRACTION = '%Y-%m-%d %H:%M:%S%z'
PLAYFAB_DATE_FORMAT_WITH_FRACTION_NO_TZ = '%Y-%m-%d %H:%M:%S.%f'

CREDENTIAL_USERNAME = os.path.abspath("") + "Midas"
TREE_ENCODING_PATH = "midas.cache"

TITLE_ID = "F303E"
DEV_SECRET_KEY = "8MWPBTO9AOFZUUZUJT4EEDRGWU54D874KN33B51653U68K1SKZ"
TENANT_ID = "bec4273e-68ea-4d20-93da-5d86069f8215"
CLIENT_ID = "fbd92855-43b2-4fad-82bb-cd7555ff6e2e"
CLIENT_SECRET = "lXE8Q~fTCBQdJOGys5thfALUlkXbXnfsvbz-5aQD"

def queryFunc(query=DEFAULT_QUERY):
    print("executing query")
    context = AuthenticationContext("https://login.microsoftonline.com/" + TENANT_ID)
    token_response = context.acquire_token_with_client_credentials("https://help.kusto.windows.net", CLIENT_ID, CLIENT_SECRET)
    token = None
    if token_response:
        if token_response['accessToken']:
            token = token_response['accessToken']

    kcsb = KustoConnectionStringBuilder.with_aad_application_token_authentication(CLUSTER, token)
    kqClient = KustoClient(kcsb)

    sys.stdout = open(os.devnull, 'w')
    response = kqClient.execute(TITLE_ID, query)
    sys.stdout = sys.__stdout__

    # Response processing
    result = str(response[0])
    print("loading response")
    df = pd.DataFrame(json.loads(result)["data"])
    print("finished creating df")

    return df.to_dict(orient='records')


def format_json_str(text) -> str:
	# text = text.replace("'\":", "`\":")
	# text = text.replace("\"'", "\"`")
	# text = text.replace("\"", "'")
	# text = text.replace("'", "\"")
	# text = text.replace("`", "'")
	text = text.replace("\\\"", "\"")
	text = text.replace("False", "false")
	text = text.replace("True", "true")
	
	return text

def decode(encoded_data, encoding_config):

	encoding_dict = encoding_config["dictionary"]
	encoding_property_dict = encoding_dict["properties"]
	encoding_value_dict = encoding_dict["values"]
	encoding_arrays = encoding_config["arrays"]
	encoding_marker = encoding_config["marker"]

	def restore_keys(data):
		out = {}
		for k in data:
			v = data[k]

			if type(v) == dict:
				v = restore_keys(v)

			decoded_key = k
			if k.startswith(encoding_marker):
				for original_key, encoded_key in encoding_property_dict.items():
					if k.replace(encoding_marker, "") == encoded_key.replace(encoding_marker, ""):
						decoded_key = original_key
						break

			out[decoded_key] = v

		return out

	def restore_binary_list(encoded_str: str, bin_array: list[str]):
		restored_data = {}
		for i, key in enumerate(bin_array):
			v = encoded_str[i+len(encoding_marker)]
			if v == "1":
				restored_data[key] = True
			else:
				restored_data[key] = False
					
		return restored_data

	def restore_values(data, val_dict, bin_array_reg):
		out = {}

		for k in data:
			nxt_bin_array_reg = {}
			if k in bin_array_reg:
				nxt_bin_array_reg = bin_array_reg[k]

			v = data[k]
			if type(v) == dict:
				if k in val_dict:
					v = restore_values(v, val_dict[k], nxt_bin_array_reg)
				else:
					v = restore_values(v, {}, nxt_bin_array_reg)
			else:
				if type(v) == str:
					if encoding_marker in v:
						if type(nxt_bin_array_reg) == list:
							v = restore_binary_list(v, nxt_bin_array_reg)
						elif k in val_dict:
							for orig_v in val_dict[k]:
								alt_v = val_dict[k][orig_v]
								if v.replace(encoding_marker, "") == alt_v.replace(encoding_marker, ""):
									v = orig_v

			out[k] = v

		return out

	return restore_values(restore_keys(encoded_data), encoding_value_dict, encoding_arrays)

def decode_raw_df(raw_df: DataFrame, encoding_config) -> DataFrame:
	untyped_raw_df = raw_df
	raw_record_list = untyped_raw_df.to_dict(orient="records")

	decoded_record_list = []
	for raw_row_data in raw_record_list:
		event_data = {}
		if type(raw_row_data["EventData"]) == str:

			encoded_data_str = format_json_str(raw_row_data["EventData"])
	
			event_data = json.loads(encoded_data_str)
		else:
			event_data = raw_row_data["EventData"]
		encoded_state_data = event_data["State"]
		decoded_state_data = decode(encoded_state_data, encoding_config)

		event_data["State"] = decoded_state_data
		decoded_row_data = {
				"EventData": event_data,
				"SessionId": raw_row_data["SessionId"],
				"Time": raw_row_data["Time"],
				"Timestamp": raw_row_data["Timestamp"],
				"PlayFabUserId": raw_row_data["PlayFabUserId"],
				"EventName": raw_row_data["EventName"],
				"EventId": raw_row_data["EventId"],
		}
		decoded_record_list.append(decoded_row_data)

	return DataFrame(decoded_record_list)

def get_datetime_from_playfab_str(playfab_str: str):
	if type(playfab_str) == str:
		try:
			return datetime.strptime(playfab_str, PLAYFAB_DATE_FORMAT)
		except:
			try: 
				return datetime.strptime(playfab_str, PLAYFAB_DATE_FORMAT_WITHOUT_FRACTION)
			except:
				return datetime.strptime(playfab_str, PLAYFAB_DATE_FORMAT_WITH_FRACTION_NO_TZ)
	elif type(playfab_str) == Timestamp:
		return playfab_str.to_pydatetime()
	else:
		raise ValueError(str(type(playfab_str))+" is not a Timestamp or str")

def get_playfab_str_from_datetime(datetime: datetime) -> str:
	return datetime.strftime(PLAYFAB_DATE_FORMAT)

def query_user_data_list(user_join_floor: datetime, join_window_in_days: int, user_limit=100000):
		query = f"""let filter_users_who_joined_before= datetime("{get_playfab_str_from_datetime(user_join_floor)}");
            let join_window_in_days = {join_window_in_days};
            let user_limit = {user_limit+1};
            let filter_users_who_joined_after = datetime_add("day", join_window_in_days, filter_users_who_joined_before);
            let all_users = materialize(
            ['events.all']
            | where Timestamp  > filter_users_who_joined_before
            | project-rename PlayFabUserId=EntityLineage_master_player_account
            );
            let users_by_join_datetime = all_users
            | where FullName_Name == "player_added_title"
            | where Timestamp < filter_users_who_joined_after
            | summarize JoinTimestamp = min(Timestamp) by PlayFabUserId
            | where JoinTimestamp > filter_users_who_joined_before
            | order by rand()
            | take user_limit
            ;
            let users_by_event_count = all_users
            | where FullName_Namespace == "title.{TITLE_ID}"
            | summarize EventCount=count() by PlayFabUserId
            ;
            users_by_join_datetime
            | join kind=inner users_by_event_count on PlayFabUserId
            | project-away PlayFabUserId1
            | sort by EventCount
        """
		return queryFunc(query)

def get_auth_config():
	title_id = TITLE_ID
	dev_secret_key = DEV_SECRET_KEY
	client_id = CLIENT_ID
	client_secret = CLIENT_SECRET
	tenant_id = TENANT_ID
	cookie = keyring.get_password("cookie", CREDENTIAL_USERNAME)

	if not title_id:
		title_id = ""

	if not dev_secret_key:
		dev_secret_key = ""

	if not client_id:
		client_id = ""
		
	if not client_secret:
		client_secret = ""

	if not tenant_id:
		tenant_id = ""
		
	if not cookie:
		cookie = ""

	auth_config = {
		"playfab": {
			"title_id": title_id,
			"dev_secret_key": dev_secret_key,
		},
		"aad": {
			"client_id": client_id,
			"client_secret": client_secret,
			"tenant_id": tenant_id,
		},
		"roblox": {
			"cookie": cookie,
		}
	}
	return auth_config

def update_based_on_success(
	is_success: bool, 
	event_limit: int, 
	fail_delay: int, 
	original_list_limit: int, 
	event_update_increment: int, 
	delay_update_increment: int
):
	if is_success:
		if original_list_limit >= event_limit + event_update_increment:
			event_limit += event_update_increment
		if fail_delay-delay_update_increment > 0:
			fail_delay -= delay_update_increment 
	else:
		if event_limit - event_update_increment >= event_update_increment:
			event_limit -= event_update_increment
		fail_delay += delay_update_increment 
	return event_limit, fail_delay

def query_events_from_user_data(playfab_user_ids: list[str], user_join_floor: datetime):
		query = f"""let playfab_user_ids = dynamic({json.dumps(playfab_user_ids)});
let only_events_after = datetime("{get_playfab_str_from_datetime(user_join_floor)}");
let session_list = ['events.all']
| where FullName_Name == "player_logged_in"
| project-keep Timestamp, EventId, EntityLineage_master_player_account
| project-rename SessionId=EventId,PlayFabUserId=EntityLineage_master_player_account
| where PlayFabUserId in (playfab_user_ids)
| sort by Timestamp
// | join kind=inner users_by_event_count on PlayFabUserId
;
let all_events = ['events.all']
| where Timestamp > only_events_after
| where FullName_Namespace  == "title.{TITLE_ID}"
| project-rename PlayFabUserId=EntityLineage_master_player_account
| where PlayFabUserId in (playfab_user_ids)
| project-rename EventName=FullName_Name
| project-keep EventData, Timestamp, PlayFabUserId, EventName, EventId
;
let session_events = all_events
| join kind=fullouter  (
    session_list
    | project-rename SessionTimestamp=Timestamp
) on PlayFabUserId
| project-away PlayFabUserId1
| extend Time = todouble(todouble(datetime_diff("millisecond", Timestamp, SessionTimestamp))/todouble(1000))
| extend EventSessionId = strcat(EventId, Time)
| where Time >= 0.0
;
let final_events = session_events
| join kind=inner  (
    session_events 
    | summarize min(Time) by EventId
    | extend EventSessionId = strcat(EventId, min_Time)
) on EventSessionId
| project-keep Timestamp, Time, SessionId, EventData, EventName, PlayFabUserId, EventId
;
final_events
"""
		return queryFunc(query)

def recursively_query_events(
    user_data_list, 
    event_limit: int, 
    fail_delay: int, 
    original_list_limit: int, 
    event_update_increment: int, 
    delay_update_increment: int,
    user_join_floor: datetime,
    start_tick: float,
    total_events: int,
    completed_events=0,
    start_index=0
):
    current_query_event_count = 0
    current_playfab_user_ids = []
    event_data_list = []

    for i, user_data in enumerate(user_data_list):
        if i >= start_index:
            if current_query_event_count + user_data["EventCount"] < event_limit:
                current_query_event_count += user_data["EventCount"]
                current_playfab_user_ids.append(user_data["PlayFabUserId"])

    if len(current_playfab_user_ids) == 0:
        print("no more users")
        return []
    
    print(f"downloading {current_query_event_count} events for users {start_index+1} -> {start_index+len(current_playfab_user_ids)}")

    try:
        current_event_data_list = query_events_from_user_data(current_playfab_user_ids, user_join_floor)
        print("success")
        event_limit, fail_delay = update_based_on_success(True, event_limit, fail_delay, original_list_limit, event_update_increment, delay_update_increment)
        start_index += len(current_playfab_user_ids)
        event_data_list.extend(current_event_data_list)
        completed_events += current_query_event_count	
        if len(current_event_data_list) == 0:
            print("no more events")
            return []
    except:
        print("failed")
        event_limit, fail_delay = update_based_on_success(False, event_limit, fail_delay, original_list_limit, event_update_increment, delay_update_increment)
        print("waiting ", fail_delay)
        time.sleep(fail_delay)
        print("re-attempting with an event limit of: ", event_limit)
    
    
    print(f"{round(1000*completed_events/total_events)/10}% complete.")
    seconds_since_start = time.time()-start_tick
    seconds_per_event = seconds_since_start / completed_events
    events_remaining = total_events - completed_events
    est_time_remaining = events_remaining * seconds_per_event

    hours = math.floor(est_time_remaining / 3600)
    minutes = math.floor(est_time_remaining / 60)
    seconds = math.floor(est_time_remaining % 60)

    time_str = ""
    if hours > 0:
        time_str += f"{hours}h "
    elif minutes > 0:
        time_str += f"{minutes}m "
    time_str += f"{seconds}s"
    print(f"estimated time until completion: {time_str}\n")

    event_data_list.extend(recursively_query_events(
        user_data_list,
        event_limit, 
        fail_delay, 
        original_list_limit, 
        event_update_increment, 
        delay_update_increment,
        user_join_floor,
        start_tick,
        total_events,
        completed_events,
        start_index
    ))

    return event_data_list



def get_tree_encoding() -> dict:
	encoding_file = open(TREE_ENCODING_PATH, "r")
	config = json.loads(encoding_file.read())
	return config

def download_all_event_data(
    user_join_floor: str , 
    join_window_in_days: int, 
    user_limit=1000000, 
    max_event_list_length=20000, 
    update_increment=2500
):
		user_join_floor_datetime = None
		if type(user_join_floor) == str:
			user_join_floor_datetime = get_datetime_from_playfab_str(user_join_floor)
		else:
			assert type(user_join_floor) == datetime
			user_join_floor_datetime = user_join_floor
		user_data_list = query_user_data_list(user_join_floor_datetime, join_window_in_days, user_limit)

		total_event_count = 0 ; print(user_data_list, " what?")
		for user_data in user_data_list:
			total_event_count += user_data["EventCount"]
		day_or_days = "days"
		if join_window_in_days == 1:
			day_or_days = "day"
		if len(user_data_list) < user_limit:
			print(f"{len(user_data_list)} users joined in the {join_window_in_days} {day_or_days} after {user_join_floor_datetime}\n")
		else:
			print(f"querying a randomized list of {len(user_data_list)} users who joined in the {join_window_in_days} {day_or_days} after {user_join_floor_datetime}\n")

		event_data_list = recursively_query_events(
			user_data_list=user_data_list, 
			event_limit=max_event_list_length, 
			fail_delay=5, 
			original_list_limit=max_event_list_length, 
			event_update_increment=update_increment, 
			delay_update_increment=5,
			user_join_floor=user_join_floor_datetime,
			total_events=total_event_count,
			start_tick= time.time()
		)

		print(f"\nreturning {len(event_data_list)} events from {len(user_data_list)} users")
		return event_data_list

def download(json_path: str, download_start_data: str, download_window: int, user_limit: int, is_raw: bool):
    abs_json_path = os.path.abspath(json_path)

    # midas_config = config.get_midas_config()

    auth_config = get_auth_config()
    pf_auth_config = auth_config["playfab"]
    aad_auth_config = auth_config["aad"]

    #pf_client = PlayFabClient(
   #     client_id = aad_auth_config["client_id"],
    #    client_secret = aad_auth_config["client_secret"],
    #    tenant_id = aad_auth_config["tenant_id"],
    #    title_id = pf_auth_config["title_id"]
   # )
    df = DataFrame(download_all_event_data(
        user_join_floor= get_datetime_from_playfab_str(download_start_data),
        join_window_in_days=download_window,
        user_limit= user_limit
    ))

    if not is_raw:
        print("decoding")
        decoded_df = decode_raw_df(df, get_tree_encoding())

        print("writing to json")
        decoded_df.to_json(abs_json_path, indent=4, orient="records")
        
        return decoded_df
    else:
        print("writing raw to json")
        df.to_json(abs_json_path, indent=4, orient="records")

        return df

download("Analytics/file.json", "2023-12-15 12:00:00.0000", 30, 1000000, True)