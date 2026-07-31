import funkin.objects.Bopper;

final path = 'backgrounds/week1/erect';

var dadbattleBlack:BGSprite;
var dadbattleLight:BGSprite;
var dadbattleSmokes:FlxSpriteGroup;

function onLoad()
{
	dadbattleSmokes = new FlxSpriteGroup(); //troll'd
	
	var solid = new FlxSprite(-500, -1000).makeGraphic(2400, 2000, 0xFF222026);
	solid.scrollFactor.set();
	add(solid);
	
	brightLightSmall = new FlxSprite(967, -103).loadGraphic(Paths.image('$path/brightLightSmall'));
	brightLightSmall.scrollFactor.set(1.2, 1.2);
	brightLightSmall.zIndex = 10;
	add(brightLightSmall);
	
	crowd = new Bopper(682, 290).setFrames(Paths.getSparrowAtlas('$path/crowd'));
	crowd.addAnimByPrefix('idle', 'idle', 12, true);
	crowd.dance();
	crowd.scrollFactor.set(.8, .8);
	crowd.zIndex = 5;
	add(crowd);
	
	var bg = new FlxSprite(-765, -247).loadGraphic(Paths.image('$path/bg'));
	bg.zIndex = 20;
	add(bg);
	
	var server = new FlxSprite(-991, 205).loadGraphic(Paths.image('$path/server'));
	server.zIndex = 30;
	add(server);
	
	lights = new FlxSprite(-847, -245).loadGraphic(Paths.image('$path/lights'));
	lights.zIndex = 4000;
	lights.scrollFactor.set(1.2, 1.2);
	add(lights);
	
	orangeLight = new FlxSprite(189, -500).loadGraphic(Paths.image('$path/orangeLight'));
	orangeLight.setScale(1, 1700);
	orangeLight.zIndex = 80;
	add(orangeLight);
	
	lightgreen = new FlxSprite(-171, 242).loadGraphic(Paths.image('$path/lightgreen'));
	lightgreen.zIndex = 40;
	add(lightgreen);
	
	lightred = new FlxSprite(-101, 560).loadGraphic(Paths.image('$path/lightred'));
	lightred.zIndex = 40;
	add(lightred);
	
	lightAbove = new FlxSprite(804, -117).loadGraphic(Paths.image('$path/lightAbove'));
	lightAbove.zIndex = 4500;
	add(lightAbove);
	
	brightLightSmall.blend = orangeLight.blend = lightgreen.blend = lightred.blend = lightAbove.blend = 0;
}

function makeCharShader(_brightness, _hue, _contrast, _saturation)
{
	var shader = newShader('adjustColor');
	shader.setFloat('brightness', _brightness);
	shader.setFloat('hue', _hue);
	shader.setFloat('contrast', _contrast);
	shader.setFloat('saturation', _saturation);
	
	return shader;
}

function onCreatePost()
{
	boyfriend.shader = makeCharShader(-23, 12, 7, 0);
	gf.shader = makeCharShader(-30, -9, -4, 0);
	dad.shader = makeCharShader(-33, -32, -23, 0);
}

function onEventPush(event)
{
    if (event.event == 'Dadbattle Spotlight')
    {
        dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
        dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
        dadbattleBlack.alpha = 0.25;
        dadbattleBlack.visible = false;
        dadbattleBlack.zIndex = 101;
        add(dadbattleBlack);

        dadbattleLight = new BGSprite('spotlight', 400, -400);
        dadbattleLight.alpha = 0.375;
        dadbattleLight.blend = BlendMode.ADD;
        dadbattleLight.visible = false;
        dadbattleLight.zIndex = 301;
        add(dadbattleLight);
        
        dadbattleSmokes.alpha = 0.7;
        dadbattleSmokes.blend = BlendMode.ADD;
        dadbattleSmokes.visible = false;
        dadbattleSmokes.zIndex = 55;
        add(dadbattleSmokes);

        var offsetX = 200;
        var smokeLeft:BGSprite = new BGSprite('backgrounds/week1/smoke', -1050 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
        smokeLeft.setGraphicSize(Std.int(smokeLeft.width * FlxG.random.float(1.1, 1.22)));
        smokeLeft.updateHitbox();
        smokeLeft.velocity.x = FlxG.random.float(15, 22);
        smokeLeft.active = true;
        smokeLeft.zIndex = 55;
        dadbattleSmokes.add(smokeLeft);

        var smokeRight:BGSprite = new BGSprite('backgrounds/week1/smoke', 1050 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
        smokeRight.setGraphicSize(Std.int(smokeRight.width * FlxG.random.float(1.1, 1.22)));
        smokeRight.updateHitbox();
        smokeRight.velocity.x = FlxG.random.float(-15, -22);
        smokeRight.active = true;
        smokeRight.flipX = true;
        smokeRight.zIndex = 55;
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
