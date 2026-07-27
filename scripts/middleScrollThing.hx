function onCreatePost()
{
    if (ClientPrefs.middleScroll)
    {
        modManager.setValue("opponentSwap", 0.5, 0);
        modManager.setValue("transform0X", -75, 0);
        modManager.setValue("transform1X", -25, 0);
        modManager.setValue("transform2X", 25, 0);
        modManager.setValue("transform3X", 75, 0);

        modManager.setValue("transformX", -600, 1);
        modManager.setValue("transformY", -300, 1);
        modManager.setValue("transformZ", -1, 1);
        modManager.setValue("noteAlpha", 1, 1);

        opponentStrums.underlayAlphaMult = 0;
    }
}