// JSON
// LSL Json utilities and patterns
// Timberwoof Lupindo

// JSON is a useful way to send key-value pairs between scripts in an object. 
// It's better to use keys than numbers because you don't have to remember what each number means
// and you can change a key without having to change the id number everywhere. 

integer OPTION_DEBUG = 1;
sayDebug(string message)
{
    if (OPTION_DEBUG)
    {
        llOwnerSay("MenuMain: "+message);
    }
}

sendJSONstring(string jsonKey, string value, key avatarKey) {
    // Send a string packaged up in a JSON object. 
    llMessageLinked(LINK_THIS, 0, llList2Json(JSON_OBJECT, [jsonKey, value]), avatarKey);
}

string getJSONstring(string jsonValue, string jsonKey, string valueNow) {
    // Extract a specific string from a JSON string. 
    // jsonValue is the JSON-encoded string. 
    // jsonKey is the identifier you want to find.
    // valueNow is the current value of your string.
    // If the JSON message contains the key, then this returns the value. 
    // If it does not contain the key, then this returns the original value. 
    string result = valueNow;
    string value = llJsonGetValue(jsonValue, [jsonKey]);
    if (value != JSON_INVALID) {
        result = value;
    }
    return result;
}

sendJSONinteger(string jsonKey, integer value, key avatarKey) {
    // Send an integer packaged up in a JSON object. 
    llMessageLinked(LINK_THIS, 0, llList2Json(JSON_OBJECT, [jsonKey, (string)value]), avatarKey);
}

integer getJSONinteger(string jsonValue, string jsonKey, integer valueNow){
    // Extract a specific integer from a JSON string. 
    // jsonValue is the JSON-encoded integer. 
    // jsonKey is the identifier you want to find.
    // valueNow is the current value of your string.
    // If the JSON message contains the key, then this returns the value. 
    // If it does not contain the key, then this returns the original value. 
    integer result = valueNow;
    string value = llJsonGetValue(jsonValue, [jsonKey]);
    if (value != JSON_INVALID) {
        result = (integer)value;
    }
    return result;
}

default
{
    state_entry()
    {
        llSay(0, "Hello, Avatar!");
    }
    
    // An object cannot send a message to itself.
    // Thus the sendJSON calls and the getJSON calls would be in different scripts. 
    // This serves to illustrate how you would send values from one script
    // and receive them in another script. 

    touch_start(integer total_number)
    {
        // This sends a string and an integer to all the other scripts in this object. 
        sendJSONstring("stringKey","value",llDetectedKey(0));
        sendJSONinteger("integerKey",456,llDetectedKey(0));
    }

    link_message( integer sender_num, integer num, string json, key id ){
        sayDebug("link_message "+json);
        // This receives a string and an integer from whoever might send one 
        string receivedString = getJSONstring(json, "stringKey", "default");
        integer receivedInteger = getJSONinteger(json, "integerKey", 0);
    }

}
