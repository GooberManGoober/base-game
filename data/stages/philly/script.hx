import funkin.objects.BGSprite;

import funkin.objects.stageobjects.PhillyGlow.PhillyGlowGradient;
import funkin.objects.stageobjects.PhillyGlow.PhillyGlowParticle;

var phillyLightsColors:Array<FlxColor>;
var phillyWindow:BGSprite;
var phillyStreet:BGSprite;
var phillyTrain:BGSprite;
var blammedLightsBlack:FlxSprite;
var phillyWindowEvent:BGSprite;
var trainSound:FlxSound;

var phillyGlowGradient:PhillyGlowGradient;
var phillyGlowParticles:FlxTypedGroup<PhillyGlowParticle>;

var curLight:Int = -1;
var curLightEvent:Int = -1;

function onLoad() {
	if (!ClientPrefs.lowQuality)
	{
		var bg:BGSprite = new BGSprite('backgrounds/philly/sky', -100, 0, 0.1, 0.1);
		bg.zIndex = 0;
		add(bg);
	}

	var city:BGSprite = new BGSprite('backgrounds/philly/city', -10, 0, 0.3, 0.3);
	city.setGraphicSize(Std.int(city.width * 0.85));
	city.updateHitbox();
	city.zIndex = 5;
	add(city);

	phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
	phillyWindow = new BGSprite('backgrounds/philly/window', city.x, city.y, 0.3, 0.3);
	phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
	phillyWindow.updateHitbox();
	phillyWindow.zIndex = 10;
	add(phillyWindow);
	phillyWindow.alpha = 0;

	if (!ClientPrefs.lowQuality)
	{
		var streetBehind:BGSprite = new BGSprite('backgrounds/philly/behindTrain', -40, 50);
		streetBehind.zIndex = 15;
		add(streetBehind);
	}

	phillyTrain = new BGSprite('backgrounds/philly/train', 2000, 360);
	phillyTrain.zIndex = 20;
	add(phillyTrain);

	trainSound = new FlxSound().loadEmbedded(Paths.sound('week3/train_passes'));
	FlxG.sound.list.add(trainSound);

	phillyStreet = new BGSprite('backgrounds/philly/street', -40, 50);
	phillyStreet.zIndex = 25;
	add(phillyStreet);
}

function onEventPush(event)
{
	if (event.event == "Philly Glow")
	{
		blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		blammedLightsBlack.visible = false;
		blammedLightsBlack.zIndex = 21;
		add(blammedLightsBlack);

		phillyWindowEvent = new BGSprite('backgrounds/philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
		phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
		phillyWindowEvent.updateHitbox();
		phillyWindowEvent.visible = false;
		phillyWindowEvent.zIndex = 22;
		add(phillyWindowEvent);

		phillyGlowGradient = new PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
		phillyGlowGradient.visible = false;
		phillyGlowGradient.zIndex = 23;
		add(phillyGlowGradient);
		if(!ClientPrefs.flashing) phillyGlowGradient.intendedAlpha = 0.7;

		phillyGlowParticles = new FlxTypedGroup();
		phillyGlowParticles.visible = false;
		phillyGlowParticles.zIndex = 24;
		add(phillyGlowParticles);
	}
}

var trainMoving:Bool = false;
var trainFrameTiming:Float = 0;
var trainCars:Int = 8;
var trainFinishing:Bool = false;
var trainCooldown:Int = 0;

function trainStart():Void
{
	trainMoving = true;
	if (!trainSound.playing)
		trainSound.play(true);
}

var startedMoving:Bool = false;

function updateTrainPos():Void
{
	if (trainSound.time >= 4700)
	{
		startedMoving = true;
		if (gf != null)
		{
			gf.playAnim('hairBlow');
			gf.specialAnim = true;
		}
	}

	if (startedMoving)
	{
		phillyTrain.x -= 400;

		if (phillyTrain.x < -2000 && !trainFinishing)
		{
			phillyTrain.x = -1150;
			trainCars -= 1;

			if (trainCars <= 0)
				trainFinishing = true;
		}

		if (phillyTrain.x < -4000 && trainFinishing)
			trainReset();
	}
}

function trainReset():Void
{
	if (gf != null)
	{
		gf.danced = false; // Sets head to the correct position once the animation ends
		gf.playAnim('hairFall');
		gf.specialAnim = true;
	}
	phillyTrain.x = FlxG.width + 200;
	trainMoving = false;
	trainCars = 8;
	trainFinishing = false;
	startedMoving = false;
}

var time:Float = 0;

function onUpdate(elapsed)
{
	if (trainMoving)
	{
		trainFrameTiming += elapsed;

		if (trainFrameTiming >= 1 / 24)
		{
			updateTrainPos();
			trainFrameTiming = 0;
		}
	}

	phillyWindow.alpha = FlxMath.lerp(phillyWindow.alpha, 0, FlxMath.bound(elapsed * 3.2, 0, 1));
	// boyfriend.angle += 5;

	if(phillyGlowParticles != null)
	{
		var i:Int = phillyGlowParticles.members.length-1;
		while (i > 0)
		{
			var particle = phillyGlowParticles.members[i];
			if(particle.alpha < 0)
			{
				particle.kill();
				phillyGlowParticles.remove(particle, true);
				particle.destroy();
			}
			--i;
		}
	}
}

function onEvent(eventName, value1, value2)
{
	if (eventName == "Philly Glow")
	{
		var lightId:Int = Std.parseInt(value1);
		if(Math.isNaN(lightId)) lightId = 0;

		var doFlash:Void->Void = function()
		{
			var color:FlxColor = FlxColor.WHITE;

			FlxG.camera.flash(color, 0.15, null, true);
		};

		var chars:Array<Character> = [boyfriend, gf, dad];
		switch(lightId)
		{
			case 0:
				if(phillyGlowGradient.visible)
				{
					doFlash();
					if(ClientPrefs.camZooms) uiBop(0.5, 0.1);

					blammedLightsBlack.visible = false;
					phillyWindowEvent.visible = false;
					phillyGlowGradient.visible = false;
					phillyGlowParticles.visible = false;
					curLightEvent = -1;

					for (who in chars)
					{
						who.color = FlxColor.WHITE;
					}
					phillyStreet.color = FlxColor.WHITE;
				}

			case 1: //turn on
				curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);
				var color:FlxColor = phillyLightsColors[curLightEvent];

				if(!phillyGlowGradient.visible)
				{
					doFlash();
					if(ClientPrefs.camZooms)
					{
						FlxG.camera.zoom += 0.5;
						camHUD.zoom += 0.1;
					}

					blammedLightsBlack.visible = true;
					blammedLightsBlack.alpha = 1;
					phillyWindowEvent.visible = true;
					phillyGlowGradient.visible = true;
					phillyGlowParticles.visible = true;
				}

				var charColor:FlxColor = color;

				for (who in chars)
				{
					who.color = charColor;
				}
				phillyGlowParticles.forEachAlive(function(particle:PhillyGlowParticle)
				{
					particle.color = color;
				});
				phillyGlowGradient.color = color;
				phillyWindowEvent.color = color;

				phillyStreet.color = color;

			case 2: // spawn particles
				if(!ClientPrefs.lowQuality)
				{
					var particlesNum:Int = FlxG.random.int(8, 12);
					var width:Float = (2000 / particlesNum);
					var color:FlxColor = phillyLightsColors[curLightEvent];
					for (j in 0...3)
					{
						for (i in 0...particlesNum)
						{
							var particle:PhillyGlowParticle = new PhillyGlowParticle(-400 + width * i + FlxG.random.float(-width / 5, width / 5), phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40), color);
							phillyGlowParticles.add(particle);
						}
					}
				}
				phillyGlowGradient.bop();
		}
	}
}

function randomizeLights()
{
	curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
	phillyWindow.color = phillyLightsColors[curLight];
	phillyWindow.alpha = 1;
}

function onBeatHit()
{
	if (!trainMoving)
		trainCooldown += 1;

	if (curBeat % 4 == 0)
		randomizeLights();

	if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8) {
		trainCooldown = FlxG.random.int(-4, 0);
		trainStart();
	}
}
