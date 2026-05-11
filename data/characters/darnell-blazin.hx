var cantUppercut:Bool = false;
function goodNoteHit(note:Note)
{
    // SPECIAL CASE: If Pico hits a poor note at low health (at 30% chance),
    // Darnell may duck below Pico's punch to attempt an uppercut.
    // TODO: Maybe add a cooldown to this?
    if (wasNoteHitPoorly(note.rating) && isPlayerLowHealth() && FlxG.random.bool(30))
    {
        playUppercutPrepAnim();
        return;
    }

    if (cantUppercut)
    {
        playPunchHighAnim();
        return;
    }

    // Override the hit note animation.
    switch (note.noteType)
    {
        case "punchlow":
            playHitLowAnim();
        case "punchlowblocked":
            playBlockAnim();
        case "punchlowdodged":
            playDodgeAnim();
        case "punchlowspin":
            playSpinAnim();

        case "punchhigh":
            playHitHighAnim();
        case "punchhighblocked":
            playBlockAnim();
        case "punchhighdodged":
            playDodgeAnim();
        case "punchhighspin":
            playSpinAnim();

        // Attempt to punch, Pico dodges or gets hit.
        case "blockhigh":
            playPunchHighAnim();
        case "blocklow":
            playPunchLowAnim();
        case "blockspin":
            playPunchHighAnim();

        // Attempt to punch, Pico dodges or gets hit.
        case "dodgehigh":
            playPunchHighAnim();
        case "dodgelow":
            playPunchLowAnim();
        case "dodgespin":
            playPunchHighAnim();

        // Attempt to punch, Pico ALWAYS gets hit.
        case "hithigh":
            playPunchHighAnim();
        case "hitlow":
            playPunchLowAnim();
        case "hitspin":
            playPunchHighAnim();

        // Fail to dodge the uppercut.
        case "picouppercutprep":
            // Continue whatever animation was playing before
            // playIdleAnim();
        case "picouppercut":
            playUppercutHitAnim();

        // Attempt to punch, Pico dodges or gets hit.
        case "darnelluppercutprep":
            playUppercutPrepAnim();
        case "darnelluppercut":
            playUppercutAnim();

        case "idle":
            playIdleAnim();
        case "fakeout":
            playCringeAnim();
        case "taunt":
            playPissedConditionalAnim();
        case "tauntforce":
            playPissedAnim();
        case "reversefakeout":
            playFakeoutAnim();
    }

    cantUppercut = false;
}

function missFunc(note:Note)
{
    // SPECIAL CASE: Darnell prepared to uppercut last time and Pico missed! FINISH HIM!
    if (dad.getAnimName() == 'uppercutPrep')
    {
        playUppercutAnim();
        return;
    }

    if (willMissBeLethal())
    {
        playPunchLowAnim();
        return;
    }

    if (cantUppercut)
    {
        playPunchHighAnim();
        return;
    }

    // Override the hit note animation.
    switch (note.noteType)
    {
        // Pico tried and failed to punch, punch back!
        case "punchlow":
            playPunchLowAnim();
        case "punchlowblocked":
            playPunchLowAnim();
        case "punchlowdodged":
            playPunchLowAnim();
        case "punchlowspin":
            playPunchLowAnim();

        // Pico tried and failed to punch, punch back!
        case "punchhigh":
            playPunchHighAnim();
        case "punchhighblocked":
            playPunchHighAnim();
        case "punchhighdodged":
            playPunchHighAnim();
        case "punchhighspin":
            playPunchHighAnim();

        // Attempt to punch, Pico dodges or gets hit.
        case "blockhigh":
            playPunchHighAnim();
        case "blocklow":
            playPunchLowAnim();
        case "blockspin":
            playPunchHighAnim();

        // Attempt to punch, Pico dodges or gets hit.
        case "dodgehigh":
            playPunchHighAnim();
        case "dodgelow":
            playPunchLowAnim();
        case "dodgespin":
            playPunchHighAnim();

        // Attempt to punch, Pico ALWAYS gets hit.
        case "hithigh":
            playPunchHighAnim();
        case "hitlow":
            playPunchLowAnim();
        case "hitspin":
            playPunchHighAnim();

        // Successfully dodge the uppercut.
        case "picouppercutprep":
            playHitHighAnim();
            cantUppercut = true;
        case "picouppercut":
            playDodgeAnim();

        // Attempt to punch, Pico dodges or gets hit.
        case "darnelluppercutprep":
            playUppercutPrepAnim();
        case "darnelluppercut":
            playUppercutAnim();

        case "idle":
            playIdleAnim();
        case "fakeout":
            playCringeAnim(); // TODO: Which anim?
        case "taunt":
            playPissedConditionalAnim();
        case "tauntforce":
            playPissedAnim();
        case "reversefakeout":
            playFakeoutAnim(); // TODO: Which anim?
    }
    cantUppercut = false;
}

function noteMissPress(direction:Int)
{
    if (willMissBeLethal())
        playPunchLowAnim(); // Darnell alternates a punch so that Pico dies.
    else
    {
        // Pico wildly throws punches but Darnell alternates between dodges and blocks.
        var shouldDodge = FlxG.random.bool(50); // 50/50.
        if (shouldDodge)
            playDodgeAnim();
        else
            playBlockAnim();
    }
}

var alternate:Bool = false;
function doAlternate():String
{
    alternate = !alternate;
    return alternate ? '1' : '2';
}

function playBlockAnim()
{
    dad.playAnim('block', true);
    PlayState.instance.camGame.shake(0.002, 0.1);
    moveToBack();
}

function playCringeAnim()
{
    dad.playAnim('cringe', true);
    moveToBack();
}

function playDodgeAnim()
{
    dad.playAnim('dodge', true, false);
    moveToBack();
}

function playIdleAnim()
{
    dad.playAnim('idle', false);
    moveToBack();
}

function playFakeoutAnim()
{
    dad.playAnim('fakeout', true);
    moveToBack();
}

function playPissedConditionalAnim()
{
    if (dad.getAnimName() == "cringe")
        playPissedAnim();
    else
        playIdleAnim();
}

function playPissedAnim()
{
    dad.playAnim('pissed', true);
    moveToBack();
}

function playUppercutPrepAnim()
{
    dad.playAnim('uppercutPrep', true);
    moveToFront();
}

function playUppercutAnim()
{
    dad.playAnim('uppercut', true);
    moveToFront();
}

function playUppercutHitAnim()
{
    dad.playAnim('uppercutHit', true);
    moveToBack();
}

function playHitHighAnim()
{
    dad.playAnim('hitHigh', true);
    camGame.shake(0.0025, 0.15);
    moveToBack();
}

function playHitLowAnim()
{
    dad.playAnim('hitLow', true);
    camGame.shake(0.0025, 0.15);
    moveToBack();
}

function playPunchHighAnim()
{
    dad.playAnim('punchHigh' + doAlternate(), true);
    moveToFront();
}

function playPunchLowAnim()
{
    dad.playAnim('punchLow' + doAlternate(), true);
    moveToFront();
}

function playSpinAnim()
{
    dad.playAnim('hitSpin', true);
    camGame.shake(0.0025, 0.15);
    moveToBack();
}

function willMissBeLethal()
{
    return health <= 0.0 && !practiceMode;
}

function wasNoteHitPoorly(rating:String)
{
    return (rating == "bad" || rating == "shit");
}

function isPlayerLowHealth()
{
    return health <= 0.3 * 2;
}

function moveToBack()
{
    boyfriendGroup.zIndex = 3000;
	dadGroup.zIndex = 2000;
    refreshZ();
}

function moveToFront()
{
    boyfriendGroup.zIndex = 2000;
	dadGroup.zIndex = 3000;
    refreshZ();
}

function opponentNoteHit(note:Note)
{
    missFunc(note);
}

function noteMiss(note:Note)
{
    missFunc(note);
}