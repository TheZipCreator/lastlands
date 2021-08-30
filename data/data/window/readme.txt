All windows are written in Lastlands GUI Language (LGL).

The ending character of a line is the newline character (like in Python). The commands of LGL are the following:

*optional
# [Anything] - Comment (there must be a space after the hashtag)
size [x] [y] - Changes the size of the window.
element [x] [y] - Creates a generic element at position (x,y). It will appear as "Invalid Element" in game.
position [x] [y] - Sets the position of the window to (x,y). You can also put "position center" to center the window
title [title] - Sets the title to [title]. Remember to put [title] in quotes if it's more than one word
text [text] [x] [y] [textSize] [red] [green] [blue] - Creates a text element. Remember to put [text] in quotes if it's more than one word
image [path to image] [x] [y] [text*] - Creates an image at the specified position. With [text] as the text that displays if you hover over it
button [x] [y] [size x] [size y] [text] [Path to LEL script] [args for LEL script] - Creates a button element
disable_x - Removes the "X" from the window
line [x1] [y1] [x2] [y2] [red] [green] [blue] - Draws a line from (x1,y1) to (x2,y2) with the color specified
diplomaticbox [x] [y] [type] [tag] [oneWay] - Creates a box showing all of [tag]'s diplomacy of type [type]. If [OneWay] is set to 0, it shows relations if [tag] is chiefdomA or chiefdomB, if [oneWay] is set to 1, it shows relations only if [tag] is chiefdomA, if [oneWay] is set to 2, it shows relations only if [tag] is chiefdomB.
print [text] - prints the text into the console, for debug purposes
force_pause - Forces the game to pause. It can only be unpaused when the window no longer exists