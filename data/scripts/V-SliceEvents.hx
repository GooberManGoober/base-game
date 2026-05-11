using StringTools;

var camTwn:Array<FlxTween> = [];

var positionData:FlxPoint = FlxPoint.get(0, 0);

function onEvent(eventName, value1, value2)
{
    switch (eventName)
    {
        case 'Focus Camera':	
            var triggerInfo:Array<String> = value2.split(',');

            var boolShit:Bool = false;

            if (triggerInfo[4].toLowerCase() == "true")
                boolShit = true;
            
            focusCamera(value1, Std.parseFloat(triggerInfo[0]), Std.parseFloat(triggerInfo[1]), Std.parseFloat(triggerInfo[2]), triggerInfo[3], boolShit);

        case 'Zoom Camera':	
            var triggerInfo:Array<String> = value2.split(',');

            tweenCameraZoom(Std.parseFloat(value1), Std.parseFloat(triggerInfo[0]), triggerInfo[1]);

        case 'Set Camera Bop':
            if(ClientPrefs.camZooms) {
                if(value1 == null) value1 = "4";
                if(value2 == null) value2 = "1";

                beatsPerZoom = Std.parseInt(value1);
                camZoomingMult = Std.parseFloat(value2);
            }
    }
}

function onBeatHit()
{
    if ((curBeat % beatsPerZoom == 0) && camZooming && ClientPrefs.camZooms) 
    {
        if (camTwn[0] == null) FlxG.camera.zoom += 0.015 * camZoomingMult;
        camHUD.zoom += 0.03 * camZoomingMult;
    }
}

function focusCamera(target:String = 'boyfriend', X:Float = 0, Y:Float = 0, Time:Float = 1, ease:String = 'linear', hasTween:Bool = false)
{
    positionData.put();
    
    switch(target.toLowerCase())
    {
        case 'bf', 'boyfriend', 'player':
            positionData = game.getCharacterCameraPos(boyfriend);
        case 'dad', 'opponent':
            positionData = game.getCharacterCameraPos(dad);
        case 'girlfriend', 'gf':
            positionData = getGFCameraPos();
        case 'position':
            positionData.x = X;
            positionData.y = Y;
        
    }

    if (hasTween)
    {
        if (camFollow != null)
        {
            if (camTwn[1] != null)
                camTwn[1].cancel();

            isCameraOnForcedPos = false;
            if(X != null || Y != null)
            {
                isCameraOnForcedPos = true;
                cameraSpeed = 3000 * 3000; // makes it so the camera is able to keep track with the position data and not fall behind.
                if(X == null) X = 0;
                if(Y == null) Y = 0;
                camTwn[1] = FlxTween.tween(camFollow, {
                    x: positionData.x, 
                    y: positionData.y
                }, Conductor.stepCrotchet * Time / 1000, {
                    ease: CoolUtil.getEaseFromString(ease), onComplete: function(twn:FlxTween)
                    {
                        camTwn[1] = null;
                        
                        if(stage.stageData.camera_speed != null)
                            cameraSpeed = stage.stageData.camera_speed;
                        else
                            cameraSpeed = 1;
                    }
                });
            }
        }
    }
    else
    {
        if(camFollow != null)
        {
            isCameraOnForcedPos = false;
            if(X != null || Y != null)
            {
                isCameraOnForcedPos = true;

                if(stage.stageData.camera_speed != null)
                    cameraSpeed = stage.stageData.camera_speed;
                else
                    cameraSpeed = 1; // Just in case
                if(X == null) X = 0;
                if(Y == null) Y = 0;
                camFollow.x = positionData.x;
                camFollow.y = positionData.y;
            }
        }
    }
}

public function tweenCameraZoom(?zoom:Float = 1, ?duration:Float = 1, ?ease:String = 'linear')
{
    if (camTwn[0] != null)
        camTwn[0].cancel();

    camTwn[0] = FlxTween.tween(FlxG.camera, {zoom: stage.stageData.defaultZoom * zoom}, Conductor.stepCrotchet * duration / 1000, {ease: CoolUtil.getEaseFromString(ease), 
        onComplete: function(twn:FlxTween)
        {
            defaultCamZoom = FlxG.camera.zoom;
            camTwn[0] = null;
        }
    });
}

function getGFCameraPos():FlxPoint
{
    if (gf == null) return FlxPoint.weak();
    
    final desiredPos = gf.getMidpoint();
    
    final offsets = girlfriendCameraOffset;
    
    desiredPos.y += -100 + gf.cameraPosition[1] + offsets[1];
    
    if (gf.isPlayer)
    {
        desiredPos.x -= 100 + gf.cameraPosition[0];
    }
    else
    {
        desiredPos.x += 100 + gf.cameraPosition[0];
    }
    
    desiredPos.x += offsets[0];
    
    return desiredPos;
}