# WoWChatParser
Best used with srLua (https://github.com/LuaDist/srlua) to create an executable for dragging WoWChatLog.txt files onto directly.

## Windows:

Run Build_srLua.bat to create the WoWChatParser executable. Drag and drop WoW Chat log text files onto that exe.

## Linux & OSX:

* Download/install srLua.
* "glue srlua WoWChatParser.lua WoWChatParser"
* "chmod +x WoWChatParser"

## Else from command line with Lua installed (and in your PATH):

lua WoWChatParser.lua --input=INPUTFILE.txt [--output=OUTPUTFILE.txt --start=01/01-00:00:00] --end=12/25-23:59:59]