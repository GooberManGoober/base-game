import funkin.game.shaders.OverlayShader;

import funkin.objects.stageobjects.BackgroundDancer;
import funkin.objects.BGSprite;

var grpLimoDancers:Array<BackgroundDancer> = [];
var grpLimoParticles:Array<BGSprite> = [];
var limo:BGSprite;
var shootingStar:BGSprite;
var limoMetalPole:BGSprite;
var limoLight:BGSprite;
var limoCorpse:BGSprite;
var limoCorpseTwo:BGSprite;
var bgLimo:BGSprite;
var fastCar:BGSprite;
var limoSpeed:Float = 0;
var limoKillingState:Int = 0;

var colorShader:AdjustColorShader;
var mist1:FlxBackdrop;
var mist2:FlxBackdrop;
var mist3:FlxBackdrop;
var mist4:FlxBackdrop;
var mist5:FlxBackdrop;

var shootingStarBeat:Int = 0;
var shootingStarOffset:Int = 2;

function onLoad()
{
        // Apply sky shader.
    var skyOverlay:OverlayShader = new OverlayShader();
    var sunOverlay:FlxSprite = new FlxSprite().loadGraphic(Paths.image('backgrounds/limo/limoOverlay'));
    sunOverlay.setGraphicSize(Std.int(sunOverlay.width * 2));
    sunOverlay.updateHitbox();
    skyOverlay.setBitmapOverlay(sunOverlay.pixels);
    
    colorShader = newShader('adjustColor');
    colorShader.setFloat('hue', -30);
    colorShader.setFloat('saturation', -20);
    colorShader.setFloat('contrast', 0);
    colorShader.setFloat('brightness', -30);

    addMist();

	var skyBG:BGSprite = new BGSprite('backgrounds/limo/erect/limoSunset', -120, -50, 0.1, 0.1);
	add(skyBG);

	skyBG.zIndex = 10;

    shootingStar = new BGSprite('backgrounds/limo/erect/shooting star', 200, 0, 0.12, 0.12, ['shooting star'], false);
    shootingStar.blend = 0;
    shootingStar.zIndex = 20;
    add(shootingStar);

    if (!ClientPrefs.lowQuality) {
		limoMetalPole = new BGSprite('backgrounds/limo/gore/metalPole', -500, 220, 0.4, 0.4);
        limoMetalPole.shader = colorShader;
		add(limoMetalPole);
		limoMetalPole.zIndex = 20;

		bgLimo = new BGSprite('backgrounds/limo/erect/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
		add(bgLimo);
		bgLimo.zIndex = 25;

		for (i in 0...5) {
			var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 170, bgLimo.y - 400);
			dancer.scrollFactor.set(0.4, 0.4);
			add(dancer);
			dancer.zIndex = 30;
			grpLimoDancers.push(dancer);

            dancer.shader = colorShader;
		}

		limoLight = new BGSprite('backgrounds/limo/gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
        limoLight.shader = colorShader;
		add(limoLight);
		limoLight.zIndex = 40;

		// PRECACHE BLOOD
		var particle:BGSprite = new BGSprite('backgrounds/limo/gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
		particle.alpha = 0.01;
		add(particle);
		particle.zIndex = 50;
		grpLimoParticles.push(particle);
	}

	limo = new BGSprite('backgrounds/limo/erect/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);
	limo.zIndex = 150;

	fastCar = new BGSprite('backgrounds/limo/fastCarLol', -300, 160);
	fastCar.active = true;
	fastCar.zIndex = 500;
    fastCar.shader = colorShader;

	add(limo);
	add(fastCar);

	limoKillingState = 0;
}

function onCreatePost()
{
	dadGroup.zIndex = 200;
	boyfriendGroup.zIndex = 300;
	gfGroup.zIndex = 100;

    dad.shader = colorShader;
    gf.shader = colorShader;
    boyfriend.shader = colorShader;

	resetFastCar();
}

function addMist()
{
    mist1 = new FlxBackdrop(Paths.image('backgrounds/limo/erect/mistMid'), 0x01);
    mist1.setPosition(-650, -100);
    mist1.scrollFactor.set(1.1, 1.1);
    mist1.zIndex = 400;
    mist1.blend = 0;
    mist1.color = 0xFFc6bfde;
    mist1.alpha = 0.4;
    mist1.velocity.x = 1700;

    add(mist1);

    mist2 = new FlxBackdrop(Paths.image('backgrounds/limo/erect/mistBack'), 0x01);
    mist2.setPosition(-650, -100);
    mist2.scrollFactor.set(1.2, 1.2);
    mist2.zIndex = 401;
    mist2.blend = 0;
    mist2.color = 0xFF6a4da1;
    mist2.alpha = 1;
    mist2.velocity.x = 2100;
    mist1.scale.set(1.3, 1.3);

    add(mist2);

    mist3 = new FlxBackdrop(Paths.image('backgrounds/limo/erect/mistMid'), 0x01);
    mist3.setPosition(-650, -100);
    mist3.scrollFactor.set(0.8, 0.8);
    mist3.zIndex = 99;
    mist3.blend = 0;
    mist3.color = 0xFFa7d9be;
    mist3.alpha = 0.5;
    mist3.velocity.x = 900;
    mist3.scale.set(1.5, 1.5);

    add(mist3);

    mist4 = new FlxBackdrop(Paths.image('backgrounds/limo/erect/mistBack'), 0x01);
    mist4.setPosition(-650, -380);
    mist4.scrollFactor.set(0.6, 0.6);
    mist4.zIndex = 98;
    mist4.blend = 0;
    mist4.color = 0xFF9c77c7;
    mist4.alpha = 1;
    mist4.velocity.x = 700;
    mist4.scale.set(1.5, 1.5);

    add(mist4);

    mist5 = new FlxBackdrop(Paths.image('backgrounds/limo/erect/mistMid'), 0x01);
    mist5.setPosition(-650, -400);
    mist5.scrollFactor.set(0.2, 0.2);
    mist5.zIndex = 15;
    mist5.blend = 0;
    mist5.color = 0xFFE7A480;
    mist5.alpha = 1;
    mist5.velocity.x = 100;
    mist5.scale.set(1.5, 1.5);

    add(mist5);
}

function resetLimoKill():Void {
	limoMetalPole.x = -500;
	limoMetalPole.visible = false;
	limoLight.x = -500;
	limoLight.visible = false;
	limoCorpse.x = -500;
	limoCorpse.visible = false;
	limoCorpseTwo.x = -500;
	limoCorpseTwo.visible = false;
}

function killHenchmen():Void {
	if (!ClientPrefs.lowQuality) {
		if (limoKillingState < 1) {
			limoMetalPole.x = -400;
			limoMetalPole.visible = true;
			limoLight.visible = true;
			limoCorpse.visible = false;
			limoCorpseTwo.visible = false;
			limoKillingState = 1;
		}
	}
}

function resetFastCar():Void {
	fastCar.x = -12600;
	fastCar.y = FlxG.random.int(140, 250);
	fastCar.velocity.x = 0;
	fastCarCanDrive = true;
}

var carTimer:FlxTimer;

function fastCarDrive() {
	FlxG.sound.play(Paths.soundRandom('week4/carPass', 0, 1), 0.7);

	fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
	fastCarCanDrive = false;
	carTimer = new FlxTimer().start(2, function(tmr:FlxTimer) {
		resetFastCar();
		carTimer = null;
	});
}

var _timer:Float = 0;

function onUpdate(elapsed)
{
	_timer += elapsed;
    mist1.y = 100 + (Math.sin(_timer) * 200);
    mist2.y = 0 + (Math.sin(_timer * 0.8) * 100);
    mist3.y = -20 + (Math.sin(_timer * 0.5) * 200);
    mist4.y = -180 + (Math.sin(_timer * 0.4) * 300);
    mist5.y = -450 + (Math.sin(_timer * 0.2) * 150);
    
    if (!ClientPrefs.lowQuality)
    {
		for (spr in grpLimoParticles)
        {
			if (spr.animation.curAnim.finished)
            {
				spr.kill();
				grpLimoParticles.remove(spr);
				spr.destroy();
			}
		}

		switch (limoKillingState)
        {
			case 1:
				limoMetalPole.x += 5000 * elapsed;
				limoLight.x = limoMetalPole.x - 180;
				limoCorpse.x = limoLight.x - 50;
				limoCorpseTwo.x = limoLight.x + 35;

				var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
				for (i in 0...dancers.length)
                {
					if (dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 170)
                    {
						switch (i)
                        {
							case 0 | 3:
								if (i == 0) FlxG.sound.play(Paths.sound('week4/dancerdeath'), 0.5);

								var diffStr:String = i == 3 ? ' 2 ' : ' ';
								var particle:BGSprite = new BGSprite('backgrounds/limo/gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4,
									['hench leg spin' + diffStr + 'PINK'], false);
								add(particle);
								grpLimoParticles.push(particle);
								var particle:BGSprite = new BGSprite('backgrounds/limo/gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4,
									['hench arm spin' + diffStr + 'PINK'], false);
								add(particle);
								grpLimoParticles.push(particle);
								var particle:BGSprite = new BGSprite('backgrounds/limo/gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4,
									['hench head spin' + diffStr + 'PINK'], false);
								add(particle);
								grpLimoParticles.push(particle);

								var particle:BGSprite = new BGSprite('backgrounds/limo/gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4,
									['blood'], false);
								particle.flipX = true;
								particle.angle = -57.5;
								add(particle);
								grpLimoParticles.push(particle);
							case 1:
								limoCorpse.visible = true;
							case 2:
								limoCorpseTwo.visible = true;
						} // Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
						dancers[i].x += FlxG.width * 2;
					}
				}

				if (limoMetalPole.x > FlxG.width * 2)
                {
					resetLimoKill();
					limoSpeed = 800;
					limoKillingState = 2;
				}

			case 2:
				limoSpeed -= 4000 * elapsed;
				bgLimo.x -= limoSpeed * elapsed;
				if (bgLimo.x > FlxG.width * 1.5)
                {
					limoSpeed = 3000;
					limoKillingState = 3;
				}

			case 3:
				limoSpeed -= 2000 * elapsed;
				if (limoSpeed < 1000)
					limoSpeed = 1000;

				bgLimo.x -= limoSpeed * elapsed;
				if (bgLimo.x < -275)
                {
					limoKillingState = 4;
					limoSpeed = 800;
				}

			case 4:
				bgLimo.x = FlxMath.lerp(bgLimo.x, -150, FlxMath.bound(elapsed * 9, 0, 1));
				if (Math.round(bgLimo.x) == -150)
                {
					bgLimo.x = -150;
					limoKillingState = 0;
				}
		}

		if (limoKillingState > 2)
        {
			for (i in 0...grpLimoDancers.length)
            {
				grpLimoDancers[i].x = (370 * i) + bgLimo.x + 280;
			}
		}
	}
}

function onCountdownTick() {
	if (!ClientPrefs.lowQuality) {
		for (dancer in grpLimoDancers) {
			dancer.dance();
		}
	}
}

function doShootingStar(beat:Int):Void
{
    shootingStar.x = FlxG.random.int(50, 900);
    shootingStar.y = FlxG.random.int(-10, 20);
    shootingStar.flipX = FlxG.random.bool(50);
    shootingStar.animation.play('shooting star');

    shootingStarBeat = beat;
    shootingStarOffset = FlxG.random.int(4, 8);
}

function onBeatHit() {
	if (!ClientPrefs.lowQuality) {
		for (dancer in grpLimoDancers) {
			dancer.dance();
		}
	}
	if (FlxG.random.bool(10) && fastCarCanDrive)
		fastCarDrive();

    if (FlxG.random.bool(10) && curBeat > (shootingStarBeat + shootingStarOffset)) doShootingStar(curBeat);
}

function onEvent(event, value1, value2) {
	if (value1 == 'Kill Henchmen')
		killHenchmen();
}