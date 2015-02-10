local channelColors = {}
channelColors["date"] = "#808080"
channelColors["time"] = "#606060"
channelColors["guild"] = "#40FF40"
channelColors["party"] = "#AEABFC"
channelColors["partyleader"] = "#7AC5FC"
channelColors["raid"] = "#970000"
channelColors["raidLeader"] = "#FF4D0B"
channelColors["raidwarning"] = "#FFDDB4"
channelColors["officer"] = "#40BC40"
channelColors["battleground"] = "#FF7D01"
channelColors["battlegroundleader"] = "#F8D2AE"
channelColors["playerwhisper_in"] = "#FF80FF"
channelColors["playerwhisper_out"] = "#FFD0FF"
channelColors["yell"] = "#FF4040"
channelColors["say"] = "#FFFFFF"
channelColors["playersay"] = "#FFFFFF"
channelColors["npcwhisper"] = "#FCB5EF"
channelColors["npcyell"] = "#FF4040"
channelColors["npcsay"] = "#FEFA9F"
channelColors["general"] = "#FFFF33"
channelColors["trade"] = "#FFFF00"
channelColors["localdefense"] = "#FFFF00"
channelColors["channel1"] = "#FFC0C0"
channelColors["channel2"] = "#FFC0C0"
channelColors["channel3"] = "#FFC0C0"
channelColors["channel4"] = "#FFC0C0"
channelColors["channel5"] = "#FFC0C0"
channelColors["channel6"] = "#FFC0C0"
channelColors["channel7"] = "#FFC0C0"
channelColors["channel8"] = "#FFC0C0"
channelColors["channel9"] = "#FFC0C0"
channelColors["channel10"] = "#FFC0C0"
channelColors["whitespam"] = "#FFFFFF"
channelColors["system"] = "#FFFF0B"
channelColors["ignoringyou"] = "#FF0700"
channelColors["loot"] = "#019700"
channelColors["roll"] = "#019700"
channelColors["experience"] = "#786DF7"
channelColors["reputation"] = "#7C78E7"
channelColors["skills"] = "#5F58FF"
channelColors["itemcreation"] = "#019700"
channelColors["honour"] = "#D8B825"
channelColors["battlegroundwarning"] = "#E8CAB0"
channelColors["bgalliance"] = "#00A2E1"
channelColors["bghorde"] = "#F70000"
channelColors["bgmisc"] = "#FF7D01"
channelColors["emote"] = "#FF7C41"
channelColors["unrecognized"] = "#FF7C41"
channelColors["item"] = "#FFFFFF"
  
local htmlHeaderOpen = [[
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>World of Warcraft Chatlog</title>
]]

local htmlColorsOpen = [[
<style type="text/css">
<!--
  body { background-color: #000000; font-family: Arial; font-size: 14.25px }
  ul,li { color: #808080; list-style: none; margin: 0; padding: 0 }
]]

local htmlColorsClose = [[
-->
</style>
]]

local htmlHeaderClose = [[
</head>
]]

local htmlBodyOpen = [[	
<body>
<ul>
]]

local htmlBodyClose = [[	
</ul>
</body>
</html>
]]

	function BuildColorsCSS()
		local colorsCSS = ""
		for colorName, colorValue in pairs(channelColors) do
			colorsCSS = colorsCSS.."."..colorName.." { color: "..colorValue.." }".."\n"
		end
		return colorsCSS
	end

local htmlColors = BuildColorsCSS()

local htmlLineOpen = [[ <li> ]]
local htmlSpanClassOpen = [[ <span class="]]
local htmlSpanClassClose = [["> ]]
local htmlLineClose = [[ </span></li> ]]

	local junkPatterns = {
	"FRIEND_ONLINE",
	"FRIEND_OFFLINE",
	"^.* has gone offline.$",
	"^.* has come online.$",
	"^Changed Channel: .*",
	"^Joined Channel: .*", 
	"^Left Channel: .*", 
	"^You receive item: .*",
	"^You create: .*",
	"^You have a firm grip - now JUMP.*",
	}

	local channelPatterns = {}
	channelPatterns["%w+ says:"] = "say"
	channelPatterns["%w+ yells:"] = "yell"
	channelPatterns["%w+ rolls %d+"] = "roll"
	channelPatterns["%w+ whispers: .*"] = "playerwhisper_in"
	channelPatterns["^To %w+: .*"] = "playerwhisper_out"
	channelPatterns["^To |.*|.*|.*: .*"] = "playerwhisper_out"
	
	--channelPatterns["^%[1%. General%] %w+: "] = "general"
	channelPatterns["^%[2%. Trade%] %w+: "] = "trade"
	--channelPatterns["^%[3%. LocalDefense%] %w+: "] = "localdefense"
	
	
	channelPatterns["%w+ .*"] = "emote" -- Gonna catch a lot of false positives here	
	
	
	local strmatch = string.match
	local strfind = string.find
	local strsub = string.sub
	local gsub = string.gsub
	local tinsert = table.insert	
	local strlower = string.lower
	local strupper = string.upper
	local strtrim = function(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end

	function strsplit(delimiter, text)
		local list = {}
		local pos = 1
		if strfind("", delimiter, 1) then -- this would result in endless loops
			error("delimiter matches empty string!")
		end
		while 1 do
			local first, last = strfind(text, delimiter, pos)
			if first then -- found?
				tinsert(list, strsub(text, pos, first-1))
				pos = last+1
			else
				tinsert(list, strsub(text, pos))
				break
			end
		end
		return list
	end
	
	function round(num, idp)
		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
	end

	local write = io.write
	
	-- --------------------------------------------------------------------------------------------------------------------------------
	-- TextToLines
	-- ----------------------------------------------------------------		
	function TextToLines(inputText)
		local textLines = strsplit("\n", inputText)
		local totalLines = #textLines
		return textLines, totalLines
	end
	
	-- --------------------------------------------------------------------------------------------------------------------------------
	-- ParseText
	-- ----------------------------------------------------------------		
	function ParseLine(line)
		-- Separate out the datetimestamp
		-- TODO: Datetime range filtering
		local timeStampPattern = "%d+%/%d+ %d+:%d+:%d+%.%d+"
		local timeStamp = strmatch(line, timeStampPattern) or ""
		line = gsub(line, timeStamp, "")
		local timeStamp_date = strmatch(timeStamp, "%d+%/%d+") or "timestamp_date"
		local timeStamp_time = strmatch(timeStamp, "%d+:%d+:%d+") or "timestamp_time"
		
		-- Trim whitespace
		line = strtrim(line)
		
		-- Filter out junk
		local junkLine = false
		for key, pattern in pairs(junkPatterns) do
			if strmatch(line, pattern) then
				--print("Junkline:", pattern, "--", "'"..line.."'")
				junkLine = true
			end
		end
		
		if junkLine then
			return nil
		else
			-- Try to determine the channel
			local channel = ""
			for pattern, channelByPattern in pairs(channelPatterns) do
				if strmatch(line, pattern) then
					channel = channelByPattern
					break
				end
			end
			
			-- Specified Channel
			-- |Hchannel:GUILD|h[Guild]|h, etc.
			local specifiedChannel = strmatch(line, "|Hchannel:(.*)|h%[.*%]|h")
			if specifiedChannel then 
				channel = specifiedChannel
				line = gsub(line, "|Hchannel:(.*)|h%[.*%]|h", "")
			end
			
			channel = strlower(channel)
			channel = gsub(channel, " ", "")
			if not channelColors[channel] then channel = "unknown" end
			
			-- Channel tag
			-- TODO: Make optional
			line = "["..strupper(channel).."]: "..line

			local lineTable = {}
			-- Line Open
			--parsedText = parsedText..htmlLineOpen
			tinsert(lineTable, htmlLineOpen)
			-- Date
			--parsedText = parsedText..htmlSpanClassOpen.."date"..htmlSpanClassClose..timeStamp_date.."</span> - "
			tinsert(lineTable, htmlSpanClassOpen)
			tinsert(lineTable, "date")
			tinsert(lineTable, htmlSpanClassClose)
			tinsert(lineTable, timeStamp_date)
			tinsert(lineTable, "</span> - ")
			-- Time
			--parsedText = parsedText..htmlSpanClassOpen.."time"..htmlSpanClassClose..timeStamp_time.."</span> "
			tinsert(lineTable, htmlSpanClassOpen)
			tinsert(lineTable, "time")
			tinsert(lineTable, htmlSpanClassClose)
			tinsert(lineTable, timeStamp_time)
			tinsert(lineTable, "</span> ")
			-- Channel CSS Class and line text
			--parsedText = parsedText..htmlSpanClassOpen..channel..htmlSpanClassClose..line
			tinsert(lineTable, htmlSpanClassOpen)
			tinsert(lineTable, channel)
			tinsert(lineTable, htmlSpanClassClose)
			tinsert(lineTable, line)
			-- Line Close
			--parsedText = parsedText..htmlLineClose.."\n"
			tinsert(lineTable, htmlLineClose)
			tinsert(lineTable, "\n")
			
			return table.concat(lineTable)
		end -- Junkline
	end
	
	-- --------------------------------------------------------------------------------------------------------------------------------
	-- ParseText
	-- ----------------------------------------------------------------		
	function ParseText(inputFile, outputFile, totalLines)

		outputFile:write(htmlHeaderOpen..htmlColorsOpen..htmlColors..htmlColorsClose..htmlHeaderClose..htmlBodyOpen)
		
		local totalLines = totalLines or 0
		local numLines = 0
		local junkLines = 0
		local progressTick = totalLines / 100
		
		local line = inputFile:read("*line")
		while line do
			-- Activity/Progress Display
			if numLines >= progressTick then
				write(".")
				numLines = 0
			end		
			parsedLine = ParseLine(line)
			if parsedLine then
				outputFile:write(parsedLine)
			else
				junkLines = junkLines + 1
			end
			numLines = numLines + 1
			line = inputFile:read()
		end
		outputFile:write(htmlBodyClose)
		
		return junkLines
	end	
	
	local argv = {...}
	
	-- Grab input text
	local inputFileName = argv[1] or "input.txt"
	local inputFile = io.open(inputFileName)
	local text = inputFile:read("*all")
	inputFile:close()
	inputFile = io.open(inputFileName)
	
	-- Convert input to lines and count
	local textLines, numLines = TextToLines(text)
	print("\nParsing input file: "..inputFileName.." with "..numLines.." lines.")
	local outputFileName = argv[2] or "output.htm"
	local outputFile = io.open(outputFileName, "w")	
	
	local startTime = os.clock()
    local s = 0
    print()	
	
	-- Parse and generate HTML
	local junkLines = ParseText(inputFile, outputFile, numLines)
	print("\nWrote "..(numLines-junkLines).." lines (after filtering) to file: '"..outputFileName.."' in "..string.format("%.2f seconds", os.clock() - startTime))
	
	outputFile:flush()
	outputFile:close()
	inputFile:close()