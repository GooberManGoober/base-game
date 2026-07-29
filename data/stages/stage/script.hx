var dadbattleBlack:BGSprite;
var dadbattleLight:BGSprite;
var dadbattleSmokes:FlxSpriteGroup;

function onLoad()
{
    dadbattleSmokes = new FlxSpriteGroup(); //troll'd
}

function onEventPush(event)
{
    if (event.event == 'Dadbattle Spotlight')
    {
        dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
        dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
        dadbattleBlack.alpha = 0.25;
        dadbattleBlack.visible = false;
        dadbattleBlack.zIndex = 2;
        add(dadbattleBlack);

        dadbattleLight = new BGSprite('spotlight', 400, -400);
        dadbattleLight.alpha = 0.375;
        dadbattleLight.blend = BlendMode.ADD;
        dadbattleLight.visible = false;
        dadbattleLight.zIndex = 5;
        add(dadbattleLight);
        
        dadbattleSmokes.alpha = 0.7;
        dadbattleSmokes.blend = BlendMode.ADD;
        dadbattleSmokes.visible = false;
        dadbattleSmokes.zIndex = 4;
        add(dadbattleSmokes);

        var offsetX = 200;
        var smokeLeft:BGSprite = new BGSprite('smoke', -1050 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
        smokeLeft.setGraphicSize(Std.int(smokeLeft.width * FlxG.random.float(1.1, 1.22)));
        smokeLeft.updateHitbox();
        smokeLeft.velocity.x = FlxG.random.float(15, 22);
        smokeLeft.active = true;
        smokeLeft.zIndex = 3;
        dadbattleSmokes.add(smokeLeft);

        var smokeRight:BGSprite = new BGSprite('backgrounds/week1/smoke', 1050 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
        smokeRight.setGraphicSize(Std.int(smokeRight.width * FlxG.random.float(1.1, 1.22)));
        smokeRight.updateHitbox();
        smokeRight.velocity.x = FlxG.random.float(-15, -22);
        smokeRight.active = true;
        smokeRight.flipX = true;
        smokeRight.zIndex = 4;
        dadbattleSmokes.add(smokeRight);
    }
}

function onEvent(name, value1, value2)
{
    if (name == "Dadbattle Spotlight")
    {
        var val:Null<Int> = Std.parseInt(value1);
        if(val == null) val = 0;

        switch(Std.parseInt(value1))
        {
            case 1, 2, 3: //enable and target dad
                if(val == 1) //enable
                {
                    dadbattleBlack.visible = true;
                    dadbattleLight.visible = true;
                    dadbattleSmokes.visible = true;
                    camChangeZoom(defaultCamZoom + 0.12, 1.9, FlxEase.expoOut);
                }

                var who:Character = dad;
                if(val > 2) who = boyfriend;
                //2 only targets dad
                dadbattleLight.alpha = 0;
                new FlxTimer().start(0.12, function(tmr:FlxTimer) {
                    dadbattleLight.alpha = 0.375;
                });
                dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);

            default:
                dadbattleBlack.visible = false;
                dadbattleLight.visible = false;
                camChangeZoom(defaultCamZoom - 0.12, 1.9, FlxEase.expoOut);
                FlxTween.tween(dadbattleSmokes, {alpha: 0}, 1, {onComplete: function(twn:FlxTween)
                {
                    dadbattleSmokes.visible = false;
                }});
				}
    }
}