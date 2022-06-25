//by Vixus Snowpaw 🦊 with help from Moy Loon 🐈
//No support will be given for this script by the author(s).

//go to https://steamcommunity.com/dev/apikey and generate a key
string apikey = "1234YOURKEYHERE1234"; //paste your steam API key between the quotes

//go to https://steamid.io and get your steamid64 from the 'lookup' page by looking your own account up
string steamid64 = "1234YOURSTEAMID64HERE"; //paste the steamid64 between the quotes


//Leave everything below this alone unless you actually know what you're doing.


//We need to declare a few things here.
key http_request_id;
key steamlogo = "7cb2c966-8db5-62f1-ff8b-e3df8872067a";
string playername;
string gameextrainfo;
string oldgame;
string newgame;
integer isingame;

//State for ingame status
ingame()
{
    if(gameextrainfo != oldgame) {
    oldgame = gameextrainfo;
    isingame = 0;
    llSetObjectName((llGetDisplayName(llGetOwner())));
    llSay(0, "/me is now playing " + gameextrainfo + ".");
    llSetObjectName("Steam Game Status Indicator");
    llParticleSystem( [PSYS_PART_FLAGS, PSYS_PART_FOLLOW_SRC_MASK | PSYS_PART_EMISSIVE_MASK, PSYS_SRC_TEXTURE, steamlogo, PSYS_PART_START_SCALE, <.1,.1,.1>, PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_DROP] );
}
    llSetText("" + playername + "\n In-Game: \n" + gameextrainfo, <0.56,0.74,0.33>, 1);
}

//Not in-game
idle()
{
    if((oldgame != gameextrainfo) && (isingame != 1)){
    gameextrainfo = oldgame;
    isingame = 1;
    llSetText("",<0,0,0>,1);
    llParticleSystem([]);
    llSetObjectName((llGetDisplayName(llGetOwner())));
    llSay(0,"/me stopped playing " + oldgame + ".");
    llSetObjectName("Steam Game Status Indicator");
    }
    else llSetText("",<0,0,0>,1);
}

//The works; we clear the particle and set a timer for 60 seconds.
default
{   
    state_entry()
    {
    isingame = 0;
    llParticleSystem([]);
    llSetTimerEvent(60);     
}

    timer()
    {
        //the timer fires, and we make the request
        http_request_id = llHTTPRequest("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key="+apikey+"&format=json&steamids="+steamid64, [], "");
    }
    
    //response + strip playername and game info from the json
    http_response(key request_id, integer status, list metadata, string body)
    {
        playername = llJsonGetValue(body, ["response","players",0,"personaname"]);
        gameextrainfo = llJsonGetValue(body, ["response","players",0,"gameextrainfo"]);
        if (request_id != http_request_id) return;
        if ((gameextrainfo != JSON_INVALID) && (gameextrainfo != JSON_NULL))
        {
            ingame();
        }
        //Error catching
        else if ((gameextrainfo == JSON_INVALID)) idle();
        else return;
    }
}
