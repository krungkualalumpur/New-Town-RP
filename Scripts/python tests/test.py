import requests
import json
import time
from CategoryIds import SubcategoryList, CategoryList

#Constants
MAX_PAGE_COUNT = 8

FACES_URL = "https://catalog.roblox.com/v1/search/items/details?Category=" + str(CategoryList.BodyParts) + "&Subcategory=" + str(SubcategoryList.Faces) + "&Limit=30"
SHIRTS_URL = "https://catalog.roblox.com/v1/search/items/details?Category=" + str(CategoryList.Clothing) + "&Subcategory=" + str(SubcategoryList.Shirts) + "&Limit=30"
PANTS_URL = "https://catalog.roblox.com/v1/search/items/details?Category=" + str(CategoryList.Clothing) + "&Subcategory=" + str(SubcategoryList.Pants) + "&Limit=30"
ACCESSORIES_URL = "https://catalog.roblox.com/v1/search/items/details?Category=" + str(CategoryList.Accessories) + "&Subcategory=" + str(SubcategoryList.Accessories) + "&Limit=30"

#functions
def getRawContent(url : str, cursor : str = None):
    newUrl = url + (("&Cursor=" + cursor) if cursor else "")

    response = requests.get(newUrl, headers = {
        "X-DataSource-Auth": "true"
    })

    print(response.status_code, newUrl, ": Response status")
    if response.status_code == 200 :
        return response.text
    elif response.status_code == 429 :
        retry_after = int(response.headers.get('Retry-After', 5))
        print(f"Rate limited! Retrying in {retry_after} seconds!")
        time.sleep(retry_after)
        return getRawContent(url, cursor)

def getContent(url, cursor : str = None):
    rawContent = getRawContent(url, cursor)
    print(url, rawContent)
    if rawContent == None: 
        return None
    accsInfoDict = json.loads(rawContent)
    return accsInfoDict

def write(className : str, luaFile, cursor : str = None, count : int = None):
    url = ACCESSORIES_URL if className == "Accessory" else FACES_URL if className == "Face" else SHIRTS_URL if className == "Shirt" else PANTS_URL if className == "Pants" else None
    
    if url == None:
        return None
    
    content = getContent(url, cursor)
    if content != None: 
        contentList = content['data']

        # print(contentList.get('nextPageCursor'))
        for v in contentList:
            luaFile.write('\n\t{')
            luaFile.write('\n\t\tClass = ' + '"' + className + '",')
            luaFile.write('\n\t\tName = "' + (str(v['name']).replace('"', '')) + '",')
            luaFile.write('\n\t\tTemplateId = ' + str(v.get('id')) + ',')
            luaFile.write('\n\t},')

    cursor =  content['nextPageCursor'] if content != None else None
    #recursive loop until reached max page count
    global MAX_PAGE_COUNT
    count = count or 1
    if (count < MAX_PAGE_COUNT) and (cursor != "None"):
        time.sleep(0.2)
        count += 1
        print(count)
        write(className, luaFile, cursor, count)
    print(count, " : count")
    # print(v['name'], v.get('assetType', "no asset type"))
    time.sleep(0.2)

with open("Scripts/GeneratedFilesTest/luaTest.lua", "w", encoding='utf-8') as scriptTest:
    scriptTest.write('--!strict \n')
    scriptTest.write('--services \n')
    scriptTest.write('--packages \n')
    scriptTest.write('--modules \n')
    scriptTest.write('--types \nexport type CustomizationClass = "Accessory" | "Face" | "Shirt" | "Pants"\n')
    scriptTest.write('\nexport type Customization = { \n\tClass : CustomizationClass,\n\tName : string,\n\tTemplateId : number\n}\n')  
    scriptTest.write('--constants \n')
    scriptTest.write('--variables \n')

    scriptTest.write('local CustomizationList : {[number] : Customization} = {')

    write("Accessory", scriptTest)
    write("Face", scriptTest)
    write("Shirt", scriptTest)
    write("Pants", scriptTest)

    scriptTest.write('\n}')

    scriptTest.write('\n\nreturn CustomizationList')

