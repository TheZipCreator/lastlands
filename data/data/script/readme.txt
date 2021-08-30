All external scripts are written with Lastlands Event Language (LEL)

The ending character of a line is the newline character (like in Python). The commands of LEL are the following:

# [Anything] - Comment (there must be a space after the hashtag)
change_state [new state] - Changes the state to [new state]
reset_windows - Removes all windows off the screen
play [index of chiefdom] - Changes currently playing chiefdom to that index
open_window [path to window] [metadata for window] - Opens a window given the metadata (metadata can be left empty)
restart - Restarts the game
diplomacy [DiplomaticRelation] [chiefdom A] [chiefdom B] - Adds a diplomatic relation of type [DiplomaticRelation] between [chiefdom a] and [chiefdom b].
print [text] - prints the text into the console, for debug purposes
exterminate [chiefdom] - Removes [chiefdom] from the game
make_tributary [chiefdomA] [chiefdomB] - [chiefdomB] becomes a tributary of [chiefdomA]
integrate [chiefdomA] [chiefdomB] - [chiefdomB] becomes integrated into [chiefdomA]