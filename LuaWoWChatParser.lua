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

local htmlLineOpen = [[ <li> ]]
local htmlSpanClassOpen = [[ <span class="]]
local htmlSpanClassClose = [["> ]]
local htmlLineClose = [[ </span></li> ]]

function BuildColorsCSS()
	local colorsCSS = ""
	for colorName, colorValue in pairs(channelColors) do
		colorsCSS = colorsCSS.."."..colorName.." { color: "..colorValue.." }".."\n"
	end
	return colorsCSS
end
local htmlColors = BuildColorsCSS()

local months = {}
	months["1"] = "January"
	months["2"] = "February"
	months["3"] = "March"
	months["4"] = "April"
	months["5"] = "May"
	months["6"] = "June"
	months["7"] = "July"
	months["8"] = "August"
	months["9"] = "September"
	months["10"] = "October"
	months["11"] = "November"
	months["12"] = "December"


local channelPatterns = {}
	channelPatterns["%w+ says:"] = "say"
	channelPatterns["%w+ yells:"] = "yell"
	channelPatterns["%w+ rolls %d+"] = "roll"
	channelPatterns["%w+ whispers: .*"] = "playerwhisper_in"
	channelPatterns["^To %w+: .*"] = "playerwhisper_out"
	channelPatterns["^To |.*|.*|.*: .*"] = "playerwhisper_out"
	
	-- TODO: Fix these:
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
	local strlen = string.len
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
	
	--[[
	function round(num, idp)
		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
	end
	--]]--

	function DatetimeToUNIX(dateString)
		local pattern = "(%d+)%-(%d+)%-(%d+)%a(%d+)%:(%d+)%:([%d%.]+)([Z%p])(%d*)%:?(%d*)";
		local xyear, xmonth, xday, xhour, xminute, xseconds, xoffset, xoffsethour, xoffsetmin
		local monthLookup = {Jan = 1, Feb = 2, Mar = 3, Apr = 4, May = 5, Jun = 6, Jul = 7, Aug = 8, Sep = 9, Oct = 10, Nov = 11, Dec = 12}
		local convertedTimestamp
		local offset = 0
		if mode and mode == "ctime" then
			pattern = "%w+%s+(%w+)%s+(%d+)%s+(%d+)%:(%d+)%:(%d+)%s+(%w+)%s+(%d+)"
			local monthName, TZName
			monthName, xday, xhour, xminute, xseconds, TZName, xyear = string.match(dateString,pattern)
			xmonth = monthLookup[monthName]
			convertedTimestamp = os.time({year = xyear, month = xmonth,
			day = xday, hour = xhour, min = xminute, sec = xseconds})
		else
			xyear, xmonth, xday, xhour, xminute, xseconds, xoffset, xoffsethour, xoffsetmin = string.match(dateString,pattern)
			convertedTimestamp = os.time({year = xyear, month = xmonth,
			day = xday, hour = xhour, min = xminute, sec = xseconds})
			if xoffsetHour then
				offset = xoffsethour * 60 + xoffsetmin
				if xoffset == "-" then
					offset = offset * -1
				end
			end
		end
		return convertedTimestamp + offset
	end	
	
	function BuildUnixTimeStamp(year, month, day, hours, minutes, seconds)
		timestamp = (year or "2014").."-"..(month or "01").."-"..(day or "01").."T"..(hours or "00")..":"..(minutes or "00")..":"..(seconds or "00").."Z"
		return timestamp
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
	
	function addLeadingZero(str)
		if not str then return end
		if strlen(str) < 2 then str = "0"..str end
		return str
	end
	
	-- --------------------------------------------------------------------------------------------------------------------------------
	-- ParseText
	-- ----------------------------------------------------------------		
	function ParseLine(line, startTimestamp, endTimestamp)
		-- Separate out the datetimestamp
		-- TODO: Datetime range filtering
		local timeStampPattern = "%d+%/%d+ %d+:%d+:%d+%.%d+"
		local timeStamp = strmatch(line, timeStampPattern) or ""
		line = gsub(line, timeStamp, "")
		local timeStamp_date = strmatch(timeStamp, "%d+%/%d+") or "timestamp_date"
		local timeStamp_time = strmatch(timeStamp, "%d+:%d+:%d+") or "timestamp_time"
		
		local timeStamp_month, timeStamp_day = strmatch(timeStamp_date, "(%d+)%/(%d+)")
		local timeStamp_hours, timeStamp_minutes, timeStamp_seconds = strmatch(timeStamp_time, "(%d+):(%d+):(%d+)")
		
		timeStamp_month = addLeadingZero(timeStamp_month)
		timeStamp_day = addLeadingZero(timeStamp_day)
		timeStamp_hours = addLeadingZero(timeStamp_hours)
		timeStamp_minutes = addLeadingZero(timeStamp_minutes)
		timeStamp_seconds = addLeadingZero(timeStamp_seconds)
		
		-- WoW doesn't put year in its log.. Awkward around December/January..
		--"2014-"..timeStamp_month.."-"..timeStamp_day.."T"..timeStamp_hours..":"..timeStamp_minutes..":"..timeStamp_seconds.."Z"
		unix_timeStamp = BuildUnixTimeStamp(2014, timeStamp_month, timeStamp_day, timeStamp_hours, timeStamp_minutes, timeStamp_seconds)
		timeStamp_number = DatetimeToUNIX(unix_timeStamp)
		--print(unix_timeStamp)
		--print(timeStamp_number)
		

		
		--[[
		-- Month numbers to month words
		
		timeStamp_date = gsub(timeStamp_date, timeStamp_month, months[timeStamp_month])
		--]]--
		timeStamp_date = gsub(timeStamp_date, "%/", " %/ ")
		
		-- Trim whitespace
		line = strtrim(line)
		
		-- Filter out junk
		local junkLine = false
		for key, pattern in pairs(junkPatterns) do
			if strmatch(line, pattern) then
				junkLine = true
			end
		end
		
		if (startTimestamp and startTimestamp > timeStamp_number) or (endTimestamp and endTimestamp <= timeStamp_number) then
			junkLine = true
			--print("Filtering by time:", startTimestamp, endTimeStamp, timeStamp_number)
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
	function ParseText(inputFile, outputFile, totalLines, startDateTime, endDateTime)
		local start_timestamp_number, end_timestamp_number
		-- startDateTime
		if startDateTime then
			local start_timestamp, startTime_month, startTime_day, startTime_hours, startTime_minutes, startTime_seconds
			-- DateTime
			local startTime_month, startTime_day, startTime_hours, startTime_minutes, startTime_seconds = strmatch(startDateTime, "(%d+)%s*%/%s*(%d+)-(%d+):(%d+):(%d+)")
			-- Date Only
			if not startTime_month then
				startTime_month, startTime_day = strmatch(startDateTime, "(%d+)%s*%/%s*(%d+)")
			end
			-- Time Only
			if not startTime_month then
				startTime_hours, startTime_minutes, startTime_seconds = strmatch(startDateTime, "(%d+):(%d+):(%d+)")
			end
			startTime_month = addLeadingZero(startTime_month) or "01"
			startTime_day = addLeadingZero(startTime_day) or "01"
			startTime_hours = addLeadingZero(startTime_hours) or "00"
			startTime_minutes = addLeadingZero(startTime_minutes) or "00"
			startTime_seconds = addLeadingZero(startTime_seconds) or "00"
			start_timestamp = BuildUnixTimeStamp(2014, startTime_month, startTime_day, startTime_hours, startTime_minutes, startTime_seconds)
			start_timestamp_number = DatetimeToUNIX(start_timestamp)
		end
		
		-- endDateTime
		if endDateTime then
			local end_timestamp, endTime_month, endTime_day, endTime_hours, endTime_minutes, endTime_seconds
			-- DateTime
			local endTime_month, endTime_day, endTime_hours, endTime_minutes, endTime_seconds = strmatch(endDateTime, "(%d+)%s*%/%s*(%d+)-(%d+):(%d+):(%d+)")
			-- Date only
			if not endTime_month then
				endTime_month, endTime_day = strmatch(endDateTime, "(%d+)%s*%/%s*(%d+)")
			end
			-- Time only
			if not endTime_month then
				endTime_hours, endTime_minutes, endTime_seconds = strmatch(endDateTime, "(%d+):(%d+):(%d+)")
			end			
			endTime_month = addLeadingZero(endTime_month) or "12"
			endTime_day = addLeadingZero(endTime_day) or "31"
			endTime_hours = addLeadingZero(endTime_hours) or "23"
			endTime_minutes = addLeadingZero(endTime_minutes) or "59"
			endTime_seconds = addLeadingZero(endTime_seconds) or "59"
			end_timestamp = BuildUnixTimeStamp(2014, endTime_month, endTime_day, endTime_hours, endTime_minutes, endTime_seconds)
			end_timestamp_number = DatetimeToUNIX(end_timestamp)
		end
	
		-- Write HTML Header, CSS & Colors
		outputFile:write(htmlHeaderOpen..htmlColorsOpen..htmlColors..htmlColorsClose..htmlHeaderClose..htmlBodyOpen)
		
		local totalLines = totalLines or 0
		local numLines = 0
		local junkLines = 0
		local progressTick = totalLines / 100

		-- Read file by lines
		local line = inputFile:read("*line")
		while line do
			-- Activity/Progress Display
			if numLines >= progressTick then
				write(".")
				numLines = 0
			end		
			parsedLine = ParseLine(line, start_timestamp_number, end_timestamp_number)
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
	
	-- --------------------------------------------------------------------------------------------------------------------------------
	-- Info
	-- ----------------------------------------------------------------		
	function Info(usage)
		print("\n\n========================================")
		print("== World of Warcraft Chat Log Parser by Kvalyr")
		print("== Version: 0.01")
		print("== See accompanying README for Instructions and Licence")
		print("== Copyright (c) 2015 Robert Voigt")
		if not usage then 
			print("====================")
		else
			print("========================================")
			print("== Usage instructions:")
			print("====================")
			print("wowchatparser --input=INPUTFILE --output=OUTPUTFILE --start=STARTDATETIME --end=ENDDATETIME")
			print("Input is mandatory. All others are optional. Default output to 'output.htm'")
			print("")
			print("'wowchatparser input.txt output.htm'")
			print("        + Read log from input.txt and write formatted log to output.htm")
			print("")
			print("'wowchatparser input.txt output.htm --start=01/01-01:02:30 --end=09/27-04:03:00'")
			print("        + Read log from input.txt and write formatted log to output.htm")
			print("        + Discard entries before 01/01-01:02:30 (January 1st, 01:02:30")
			print("        + Discard entries after 09/27-04:03:00 (September 27th, 04:03:00")
			print("")
			print("'wowchatparser --output=output.txt'")
			print("        + Discard entries after 09/27-04:03:00 (September 27th, 04:03:00")		
			os.exit()
		end
	end
	
	-- --------------------------------------------------------------------------------------------------------------------------------
	-- Main
	-- ----------------------------------------------------------------		
	function Main(...)
		local argv = {...}
		local inputFileName, outputFileName, startDateTime, endDateTime
		inputFileName = argv[1]
		outputFileName = argv[2] or "output.htm"

		if strmatch(inputFileName or "", "--.*%=.*") then inputFileName = nil end
		if strmatch(outputFileName, "--.*%=.*") then outputFileName = nil end

		for key, val in pairs(argv) do
			inputFileName = strmatch(val, "--input=(.*)%s*") or inputFileName
			outputFileName = strmatch(val, "--output=(.*)%s*") or outputFileName
			startDateTime = strmatch(val, "--start=(.*)%s*") or startDateTime
			endDateTime = strmatch(val, "--end=(.*)%s*") or endDateTime
		end

		if not outputFileName then outputFileName = "output.htm" end
		Info(not inputFileName) -- Show usage if no inputFileName
		

		local inputFile, errMsg = io.open(inputFileName)
		if not inputFile then
			print("Error opening input file:", errMsg)
			return
		end
		local outputFile = io.open(outputFileName, "w")
		if not outputFile then
			print("Error opening output file:", errMsg)
			return
		end		

		-- Grab input text		
		local text = inputFile:read("*all")
		-- Convert input to lines and count
		local textLines, numLines = TextToLines(text)
		print("\nParsing input file: "..inputFileName.." with "..numLines.." lines.")
		inputFile:close()
		
		inputFile = io.open(inputFileName) -- Reopen to read by lines

		-- Parse and generate HTML
		local startTime = os.clock()
		local junkLines = ParseText(inputFile, outputFile, numLines, startDateTime, endDateTime)
		print("\nWrote "..(numLines-junkLines).." lines (after filtering) to file: '"..outputFileName.."' in "..string.format("%.2f seconds", os.clock() - startTime))
		if startDateTime then print("Entries before "..startDateTime.." were discarded.") end
		if endDateTime then print("Entries after "..endDateTime.." were discarded.") end

		outputFile:flush()
		outputFile:close()
		inputFile:close()
	end
	
Main(...)