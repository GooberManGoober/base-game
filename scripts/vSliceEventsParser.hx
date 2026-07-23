import funkin.FunkinAssets;
import funkin.data.Chart;

using StringTools;

var eventsArray = [];

var canUseEvents:Bool = true;

function triggerVSliceEvent(name, values, strumTime):Void
{
    switch(name)
    {
        case "FocusCamera":
            updateCamOffsets = false;

            var focusChar:String = "Player";

            switch (values.char)
            {
                case 0:
                    focusChar = "player";
                case 1:
                    focusChar = "opponent";
                case 2:
                    focusChar = "girlfriend";
                default:
                    focusChar = "position";
            }

            var easeType:String = "CLASSIC";
            if (values.ease != null) easeType = values.ease;
            if (values.easeDir != null) easeType += values.easeDir;

            focusCamera(focusChar, values.x ?? 0, values.y ?? 0, values.duration ?? 4, easeType);
        case "ZoomCamera":
            var easeType:String = "CLASSIC";
            if (values.ease != null) easeType = values.ease;
            if (values.easeDir != null) easeType += values.easeDir;
            tweenCameraZoom(values.mode ?? "stage", values.zoom ?? 1, values.duration ?? 4, easeType);
         case "SetCameraBop":
            triggerEventNote("Set Camera Bop", '${values.rate}', '${values.intensity}');
    }
}
function onCreatePost()
{
    var jsonToUse = Paths.json(PlayState.SONG.song.replace(' ', '-') + '/v-sliceEvents', null, true);
    
    if (FunkinAssets.exists(jsonToUse))
    {
        var parsedJson = FunkinAssets.parseJson(FunkinAssets.getContent(jsonToUse));
        eventsArray = parsedJson.events;
        if (eventsArray == null) {
            canUseEvents = false;
        }
    }
}

function onUpdatePost(elapsed)
{
    if (canUseEvents)
    {
        if (endingSong)
            return;

        if (eventsArray[0] != null)
        {
            if (Conductor.songPosition >= eventsArray[0].t)
            {
                triggerVSliceEvent(eventsArray[0].e, eventsArray[0].v, eventsArray[0].t);
                eventsArray.remove(eventsArray[0]);
            }
        }
    }
}
function onGameOver()
{
    eventsArray = [];
}

function onEndSong()
{
    eventsArray = [];
}