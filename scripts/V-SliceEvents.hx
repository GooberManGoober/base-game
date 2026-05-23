using StringTools;

var camTwn:Array<FlxTween> = [];

var positionData:FlxPoint = FlxPoint.get(0, 0);

function onEvent(eventName, value1, value2)
{
    switch (eventName)
    {
        case 'Focus Camera':	
            var triggerInfo:Array<String> = value2.split(',');

            focusCamera(value1, Std.parseFloat(triggerInfo[0]), Std.parseFloat(triggerInfo[1]), Std.parseFloat(triggerInfo[2]), triggerInfo[3]);

        case 'Zoom Camera':	
            var triggerInfo:Array<String> = value2.split(',');

            tweenCameraZoom(value1, Std.parseFloat(triggerInfo[0]), Std.parseFloat(triggerInfo[1]), triggerInfo[2]);

        case 'Set Camera Bop':
            if(ClientPrefs.camZooms) {
                if(value1 == null) value1 = "4";
                if(value2 == null) value2 = "1";

                beatsPerZoom = Std.parseInt(value1);
                camZoomingMult = Std.parseFloat(value2);
            }
    }
}

function focusCamera(target:String = 'boyfriend', X:Float = 0, Y:Float = 0, Time:Float = 1, ease:String = 'linear')
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

    if (ease.toLowerCase() != 'classic' && ease.toLowerCase() != 'instant')
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
    else if (ease.toLowerCase() == 'classic')
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
    else if (ease.toLowerCase() == 'instant')
    {  
        if(camFollow != null)
        {
            isCameraOnForcedPos = false;
            if(X != null || Y != null)
            {
                snapCamToPos(positionData.x, positionData.y, true);
            }
        }
    }
}

public function tweenCameraZoom(?zoomType:String = 'Stage', ?zoom:Float = 1, ?duration:Float = 1, ?ease:String = 'linear')
{
    if (camTwn[0] != null)
        camTwn[0].cancel();

    var targetZoom = zoom * (zoomType.toLowerCase() == "absolute" ? FlxCamera.defaultZoom : stage.stageData.defaultZoom);

    if (ease.toLowerCase() != 'instant')
    {
        camTwn[0] = FlxTween.tween(FlxG.camera, {zoom: targetZoom}, Conductor.stepCrotchet * duration / 1000, {ease: CoolUtil.getEaseFromString(ease), 
            onComplete: function(twn:FlxTween)
            {
                defaultCamZoom = FlxG.camera.zoom;
                camTwn[0] = null;
            }
        });
    }
    else if (ease.toLowerCase() == 'instant')
    {
        defaultCamZoom = FlxG.camera.zoom = targetZoom;
    }
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