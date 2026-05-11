var cantUppercut = false;
function goodNoteHit(note:Note)
{
    if (wasNoteHitPoorly(note.rating) && isPlayerLowHealth() && isDarnellPreppingUppercut())
    {
        playPunchHighAnim();
        return;
    }

    if (cantUppercut)
    {
        playBlockAnim();
        cantUppercut = false;
        return;
    }

    switch(note.noteType)
    {
        case "punchlow":
            playPunchLowAnim();
        case "punchlowblocked":
            playPunchLowAnim();
        case "punchlowdodged":
            playPunchLowAnim();
        case "punchlowspin":
            playPunchLowAnim();

        case "punchhigh":
            playPunchHighAnim();
        case "punchhighblocked":
            playPunchHighAnim();
        case "punchhighdodged":
            playPunchHighAnim();
        case "punchhighspin":
            playPunchHighAnim();

        case "blockhigh":
            playBlockAnim();
        case "blocklow":
            playBlockAnim();
        case "blockspin":
            playBlockAnim();

        case "dodgehigh":
            playDodgeAnim();
        case "dodgelow":
            playDodgeAnim();
        case "dodgespin":
            playDodgeAnim();

        // Pico ALWAYS gets punched.
        case "hithigh":
            playHitHighAnim();
        case "hitlow":
            playHitLowAnim();
        case "hitspin":
            playHitSpinAnim();

        case "picouppercutprep":
            playUppercutPrepAnim();
        case "picouppercut":
            playUppercutAnim(true);

        case "darnelluppercutprep":
            playIdleAnim();
        case "darnelluppercut":
            playUppercutHitAnim();

        case "idle":
            playIdleAnim();
        case "fakeout":
            playFakeoutAnim();
        case "taunt":
            playTauntConditionalAnim();
        case "tauntforce":
            playTauntAnim();
        case "reversefakeout":
            playIdleAnim(); // TODO: Which anim?
    }
}

public function missFunc(note:Note)
{
    //trace('missed note!');
    if (isDarnellInUppercut())
    {
        playUppercutHitAnim();
        return;
    }

    if (willMissBeLethal())
    {
        playHitLowAnim();
        return;
    }

    if (cantUppercut)
    {
        playHitHighAnim();
        return;
    }

    switch (note.noteType)
    {
        // Pico fails to punch, and instead gets hit!
        case "punchlow":
            playHitLowAnim();
        case "punchlowblocked":
            playHitLowAnim();
        case "punchlowdodged":
            playHitLowAnim();
        case "punchlowspin":
            playHitSpinAnim();

        // Pico fails to punch, and instead gets hit!
        case "punchhigh":
            playHitHighAnim();
        case "punchhighblocked":
            playHitHighAnim();
        case "punchhighdodged":
            playHitHighAnim();
        case "punchhighspin":
            playHitSpinAnim();

        // Pico fails to block, and instead gets hit!
        case "blockhigh":
            playHitHighAnim();
        case "blocklow":
            playHitLowAnim();
        case "blockspin":
            playHitSpinAnim();

        // Pico fails to dodge, and instead gets hit!
        case "dodgehigh":
            playHitHighAnim();
        case "dodgelow":
            playHitLowAnim();
        case "dodgespin":
            playHitSpinAnim();

        // Pico ALWAYS gets punched.
        case "hithigh":
            playHitHighAnim();
        case "hitlow":
            playHitLowAnim();
        case "hitspin":
            playHitSpinAnim();

        // Fail to dodge the uppercut.
        case "picouppercutprep":
            playPunchHighAnim();
            cantUppercut = true;
        case "picouppercut":
            playUppercutAnim(false);

        // Darnell's attempt to uppercut, Pico dodges or gets hit.
        case "darnelluppercutprep":
            playIdleAnim();
        case "darnelluppercut":
            playUppercutHitAnim();

        case "idle":
            playIdleAnim();
        case "fakeout":
            playHitHighAnim();
        case "taunt":
            playTauntConditionalAnim();
        case "tauntforce":
            playTauntAnim();
        case "reversefakeout":
            playIdleAnim();
    }
}

public function noteMissPress(direction:Int)
{
    if (willMissBeLethal())
        playHitLowAnim(); // Darnell throws a punch so that Pico dies.
    else 
        playPunchHighAnim(); // Pico wildly throws punches but Darnell dodges.
}

function movePicoToBack()
{
    boyfriendGroup.zIndex = 2000;
	dadGroup.zIndex = 3000;
    refreshZ();
}

function movePicoToFront()
{
    boyfriendGroup.zIndex = 3000;
	dadGroup.zIndex = 2000;
    refreshZ();
}

var alternate:Bool = false;
function doAlternate():String
{
    alternate = !alternate;
    return alternate ? '1' : '2';
}

function playBlockAnim()
{
    boyfriend.playAnim('block', true);
    FlxG.camera.shake(0.002, 0.1);
    moveToBack();
}

function playCringeAnim()
{
    boyfriend.playAnim('cringe', true);
    moveToBack();
}

function playDodgeAnim()
{
    boyfriend.playAnim('dodge', true);
    moveToBack();
}

function playIdleAnim()
{
    boyfriend.playAnim('idle', false);
    moveToBack();
}

function playFakeoutAnim()
{
    boyfriend.playAnim('fakeout', true);
    moveToBack();
}

function playUppercutPrepAnim()
{
    boyfriend.playAnim('uppercutPrep', true);
    moveToFront();
}

function playUppercutAnim(hit:Bool)
{
    boyfriend.playAnim('uppercut', true);
    if (hit) FlxG.camera.shake(0.005, 0.25);
    moveToFront();
}

function playUppercutHitAnim()
{
    boyfriend.playAnim('uppercutHit', true);
    FlxG.camera.shake(0.005, 0.25);
    moveToBack();
}

function playHitHighAnim()
{
    boyfriend.playAnim('hitHigh', true);
    FlxG.camera.shake(0.0025, 0.15);
    moveToBack();
}

function playHitLowAnim()
{
    boyfriend.playAnim('hitLow', true);
    FlxG.camera.shake(0.0025, 0.15);
    moveToBack();
}

function playHitSpinAnim()
{
    boyfriend.playAnim('hitSpin', true);
    FlxG.camera.shake(0.0025, 0.15);
    moveToBack();
}

function playPunchHighAnim()
{
    boyfriend.playAnim('punchHigh' + doAlternate(), true);
    moveToFront();
}

function playPunchLowAnim()
{
    boyfriend.playAnim('punchLow' + doAlternate(), true);
    moveToFront();
}

function playTauntConditionalAnim()
{
    if (boyfriend.getAnimName() == "fakeout")
        playTauntAnim();
    else
        playIdleAnim();
}

function playTauntAnim()
{
    boyfriend.playAnim('taunt', true);
    moveToBack();
}

function willMissBeLethal()
{
    return PlayState.instance.health <= 0.0 && !PlayState.instance.practiceMode;
}

function isDarnellPreppingUppercut()
{
    return dad.getAnimName() == 'uppercutPrep';
}

function isDarnellInUppercut()
{
    return dad.getAnimName() == 'uppercut' || dad.getAnimName() == 'uppercut-hold';
}

function wasNoteHitPoorly(rating:String)
{
    return (rating == "bad" || rating == "shit");
}

function isPlayerLowHealth()
{
    return PlayState.instance.health <= 0.3 * 2;
}

function moveToBack()
{
    var bfPos:Int = FlxG.state.members.indexOf(boyfriendGroup);
    var dadPos:Int = FlxG.state.members.indexOf(dadGroup);
    if(bfPos < dadPos) return;

    FlxG.state.members[dadPos] = boyfriendGroup;
    FlxG.state.members[bfPos] = dadGroup;
}

function moveToFront()
{
    var bfPos:Int = FlxG.state.members.indexOf(boyfriendGroup);
    var dadPos:Int = FlxG.state.members.indexOf(dadGroup);
    if(bfPos > dadPos) return;

    FlxG.state.members[dadPos] = boyfriendGroup;
    FlxG.state.members[bfPos] = dadGroup;
}

function opponentNoteHit(note:Note)
{
    missFunc(note);
}

function noteMiss(note:Note)
{
    missFunc(note);
}