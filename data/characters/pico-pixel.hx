import funkin.states.substates.GameOverSubstate;
import funkin.objects.Bopper;

import flixel.util.FlxDestroyUtil;

var dead;

function onCreatePost()
{
	// preloading death assets so game no lag....
	Paths.getSparrowAtlas("characters/nenePixel/nenePixelKnifeToss");
}

function onGameOverPost()
{
	dead = (GameOverSubstate.instance);
	dead.camFollow.setPosition(getCharacterCameraPos(dead.boyfriend).x, getCharacterCameraPos(dead.boyfriend).y);
	FlxG.camera.snapToTarget();

	dead.boyfriend.shader = null;
	
	neneSpr = new Bopper(gf.x + 150, gf.y).setFrames(Paths.getSparrowAtlas("characters/nenePixel/nenePixelKnifeToss"));
	neneSpr.setScale(6, 6, true);
	neneSpr.addAnimByPrefix('die', 'knifetosscolor', 24, false);
	neneSpr.playAnim('die', true);
	neneSpr.antialiasing = false;
	dead.add(neneSpr);
	
	FlxTween.tween(neneSpr, {alpha: 0}, 0.2, {startDelay: 0.5});
	
	dead.boyfriend.onAnimationFrameChange.add((anim, frame) -> {
		if (anim == 'firstDeath')
		{
			switch (frame)
			{
				case 15:
					FlxTween.tween(dead.camFollow, {x: dead.boyfriend.getGraphicMidpoint().x - 200}, 0.5, {ease: FlxEase.backInOut});
			}
		}
	});
	
	FlxG.camera.follow(dead.camFollow, FlxCameraFollowStyle.LOCKON, 0);
}
