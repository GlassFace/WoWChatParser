
-- --------------------------------------------------------------------------------------------------------------------------------
-- Config Stuff
-- ----------------------------------------------------------------		
--TODO: Move this to Config, or duplicate it there and leave this table here as a source for defaults
local channels = {}
	channels["date"] = "#808080"
	channels["time"] = "#606060"
	channels["guild"] = "#40FF40"
	channels["instance"] = "#AEABFC"
	channels["instanceleader"] = "#AEABFC"
	channels["party"] = "#AEABFC"
	channels["partyleader"] = "#7AC5FC"
	channels["raid"] = "#970000"
	channels["raidleader"] = "#FF4D0B"
	channels["raidwarning"] = "#FFDDB4"
	channels["officer"] = "#40BC40"
	channels["battleground"] = "#FF7D01"
	channels["battlegroundleader"] = "#F8D2AE"
	channels["playerwhisper_in"] = "#FF80FF"
	channels["playerwhisper_out"] = "#FFD0FF"
	channels["yell"] = "#FF4040"
	channels["say"] = "#FFFFFF"
	channels["playersay"] = "#FFFFFF"
	channels["npcwhisper"] = "#FCB5EF"
	channels["npcyell"] = "#FF4040"
	channels["npcsay"] = "#FEFA9F"
	channels["general"] = "#FFFF33"
	channels["trade"] = "#DDDD00"
	channels["localdefense"] = "#BBBB22"
	channels["channel1"] = "#FFC0C0"
	channels["channel2"] = "#FFC0C0"
	channels["channel3"] = "#FFC0C0"
	channels["channel4"] = "#FFC0C0"
	channels["channel5"] = "#FFC0C0"
	channels["channel6"] = "#FFC0C0"
	channels["channel7"] = "#FFC0C0"
	channels["channel8"] = "#FFC0C0"
	channels["channel9"] = "#FFC0C0"
	channels["channel10"] = "#FFC0C0"
	channels["whitespam"] = "#FFFFFF"
	channels["system"] = "#FFFF0B"
	channels["ignoringyou"] = "#FF0700"
	channels["loot"] = "#019700"
	channels["roll"] = "#019700"
	channels["experience"] = "#786DF7"
	channels["reputation"] = "#7C78E7"
	channels["skills"] = "#5F58FF"
	channels["itemcreation"] = "#019700"
	channels["honor"] = "#D8B825"
	channels["battlegroundwarning"] = "#E8CAB0"
	channels["bgalliance"] = "#00A2E1"
	channels["bghorde"] = "#F70000"
	channels["bgmisc"] = "#FF7D01"
	channels["emote"] = "#FF7C41"
	channels["unrecognized"] = "#FF7C41"
	channels["item"] = "#FFFFFF"
 
-- TODO: Move to config
-- TODO: Move some of these to channelPatterns
local junkPatterns = {
	-- System
	"FRIEND_ONLINE",
	"FRIEND_OFFLINE",
	-- Friends/Guild
	"^.* has gone offline.$",
	"^.* has come online.$",
	-- Channels
	"^Changed Channel: .*",
	"^Joined Channel: .*", 
	"^Left Channel: .*", 
	-- Loot, Crafting
	"^You receive item: .-%.$",
	"^You create: .-%.$",
	"^.- receives loot: .*%.$",
	"^.- creates:? [%w%s%'$-]-%.$",
	"^You receive currency: .-%.$",
	"^You loot 21 Gold, 27 Silver, 90 Copper",
	"^Loot: .-",
	"^Your share of the loot is 8 Silver, 9 Copper.",
	"^Loot: You have selected Disenchant for: .-$",
	"^Your skill in .- has increased to %d+%.", -- Crafting skillups
	-- Misc
	"^You have a firm grip - now JUMP.*",
	"^Auction created.",
	"^Bid accepted.",
	"^You won an auction for .-$",
	"^You are now Away: .-$",
	"^You are no longer Away.$",
	-- Groups, Instances, Queues
	"^You leave the group.",
	"^.- has joined the instance group.",
	"^.- has left the instance group.",
	"^You are now queued in the Raid Finder.",
	"^You are now queued in the Dungeon Finder.",
	"^Dungeon Difficulty set to .-%.",
	"^Raid Difficulty set to .-%.",
	"^Looting changed to .-%.",
	"^Looting set to .-%.",
	"^Loot threshold set to .-%.",
	"^You have been removed from the group.",
	"^Your group has been disbanded.",
	"^You are in both a party and an instance group. You may communicate with your party with \"/p\" and with your instance group with \"/i\".",
	"^You are not in a raid group",
	-- Combat
	"^.- has died%.",
	"^You are no longer rested%.",
	-- PvP
	"^Your group has joined the queue for All Arenas",
	"^.- has joined the battle",
	"^%w- seconds until the Arena battle begins!",
	"^The Arena battle has begun!",
}

local channelGroups = {}
	channelGroups["RP"] = {"say", "emote", "yell"}
	channelGroups["RPEvent"] = {"say", "emote", "yell", "party", "partyleader", "raid", "raidleader", "raidwarning", "roll", "officer"}
	channelGroups["group"] = {"party", "partyleader", "raid", "raidleader", "raidwarning", "instance", "instanceleader"}
	channelGroups["raid"] = {"raid", "raidleader", "raidwarning"}
	channelGroups["party"] = {"party", "partyleader"}
	channelGroups["instance"] = {"instance", "instanceleader"}
	channelGroups["pvp"] = {"battlegroundwarning", "bgalliance", "bghorde", "bgmisc", "honor"}
 
-- --------------------------------------------------------------------------------------------------------------------------------
-- HTML Constants
-- ----------------------------------------------------------------

 local htmlHeaderOpen = [[
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>World of Warcraft Chatlog</title>
]]

local htmlColorsOpen = [[<style type="text/css">
<!--
  body { background-color: #000000; font-family: Arial; font-size: 14.25px }
  ul,li { color: #808080; list-style: none; margin: 0; padding: 0 }
]]

local htmlColorsClose = [[--></style>]]
local htmlHeaderClose = [[</head>
]]
local htmlBodyOpen = [[<body><ul>
]]
local htmlBodyClose = [[</ul></body>
</html>]]

local htmlLineOpen = [[ <li> ]]
local htmlSpanClassOpen = [[ <span class="]]
local htmlSpanClassClose = [["> ]]
local htmlLineClose = [[ </span></li> ]]

function BuildColorsCSS()
	local colorsCSS = ""
	for colorName, colorValue in pairs(channels) do
		colorsCSS = colorsCSS.."."..colorName.." { color: "..colorValue.." }".."\n"
	end
	return colorsCSS
end
local htmlColors = BuildColorsCSS()

-- --------------------------------------------------------------------------------------------------------------------------------
-- Miscellaneous & Helper Functions
-- ----------------------------------------------------------------

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
	channelPatterns["^[%w%-]+ says:"] = "say"
	channelPatterns["^[%w%-]+ yells:"] = "yell"
	channelPatterns["^[%w%-]+ rolls %d+"] = "roll"
	channelPatterns["^[%w%-]+ whispers: .*"] = "playerwhisper_in"
	channelPatterns["^To [%w%-]+: .*"] = "playerwhisper_out"
	channelPatterns["^To |.*|.*|.*: .*"] = "playerwhisper_out"
	channelPatterns["^%[Raid%s+Warning%]%s+"] = "raidwarning"
	
	channelPatterns["%w+ .*"] = "emote" -- Gonna catch a lot of false positives here	
	
local strmatch = string.match
local strfind = string.find
local strsub = string.sub
local gsub = string.gsub
local tinsert = table.insert
local tconcat = table.concat
local tconcatkeys = function(t, sep) local str = ""; for key in pairs(t) do str = str..key..(sep or "") end; return str end
local strlower = string.lower
local strupper = string.upper
local strlen = string.len
local write = io.write	
local strtrim = function(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end

local function strsplit(delimiter, text)
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

-- --------------------------------------------------------------------------------------------------------------------------------
-- UNIXTimeToOS
-- Parses a dateString (in UNIX timestamp format) into a time in os.time() format
-- ----------------------------------------------------------------	
function UNIXTimeToOS(dateString)
	local pattern = "(%d+)%-(%d+)%-(%d+)%a(%d+)%:(%d+)%:([%d%.]+)([Z%p])(%d*)%:?(%d*)";
	local monthLookup = {Jan = 1, Feb = 2, Mar = 3, Apr = 4, May = 5, Jun = 6, Jul = 7, Aug = 8, Sep = 9, Oct = 10, Nov = 11, Dec = 12}
	local offset = 0
	local xyear, xmonth, xday, xhour, xminute, xseconds, xoffset, xoffsethour, xoffsetmin = string.match(dateString,pattern)
	local convertedTimestamp = os.time({year = xyear, month = xmonth, day = xday, hour = xhour, min = xminute, sec = xseconds}) or 0
	if xoffsetHour then
		offset = xoffsethour * 60 + xoffsetmin
		if xoffset == "-" then
			offset = offset * -1
		end
	end
	return convertedTimestamp + offset
end	

-- --------------------------------------------------------------------------------------------------------------------------------
-- BuildUnixTimeStamp
-- Constructs a UNIX dateString from constituent parts
-- ----------------------------------------------------------------		
function BuildUnixTimeStamp(year, month, day, hours, minutes, seconds)
	timestamp = (year or "2014").."-"..(month or "01").."-"..(day or "01").."T"..(hours or "00")..":"..(minutes or "00")..":"..(seconds or "00").."Z"
	return timestamp
end

-- --------------------------------------------------------------------------------------------------------------------------------
-- TextToLines
-- ----------------------------------------------------------------		
function TextToLines(inputText)
	local textLines = strsplit("\n", inputText)
	local totalLines = #textLines
	return textLines, totalLines
end

-- --------------------------------------------------------------------------------------------------------------------------------
-- addLeadingZero
-- ----------------------------------------------------------------			
function addLeadingZero(str)
	if not str then return end
	if strlen(str) < 2 then str = "0"..str end
	return str
end


-- --------------------------------------------------------------------------------------------------------------------------------
-- Parser class
-- --------------------------------------------------------------------------------------------------------------------------------
local Parser = {}
Parser.version = { major = 0.2, minor = 1, }
Parser.versionString = Parser.version.major..Parser.version.minor

	-- --------------------------------------------------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------------------------------
	-- Main
	-- ----------------------------------------------------------------		
	function Parser:Main(...)
		local argv = {...}
		local inputFileName, outputFileName, startDateTime, endDateTime, filters, noHtml, keyword, avatar, openFileAfter
		inputFileName = argv[1]
		outputFileName = argv[2] or "output.htm"

		print(inputFileName)
		
		if inputFileName then if strmatch(inputFileName, "^%-%-.*") then inputFileName = nil end end
		if strmatch(outputFileName, "^%-%-.*") then outputFileName = nil end

		for key, val in pairs(argv) do
			inputFileName = strmatch(val, "--input=(.*)%s*") or inputFileName
			outputFileName = strmatch(val, "--output=(.*)%s*") or outputFileName
			startDateTime = strmatch(val, "--start=(.*)%s*") or startDateTime
			endDateTime = strmatch(val, "--end=(.*)%s*") or endDateTime
			filters = strmatch(val, "--filter=(.*)%s*") or filters
			keyword = strmatch(val, [[--keyword='(.-)']]) or keyword
			avatar = strmatch(val, "--avatar=(.*)%s*") or avatar
			
			noHtml = strmatch(val, "--raw") or noHtml
			openFileAfter = strmatch(val, "--open") or openFileAfter
		end
		
		self:Info(not inputFileName) -- Show usage and quit if no inputFileName		
		
		-- Escape datetimes
		if startDateTime then startDateTime = gsub(startDateTime, "%/", "_") end
		if endDateTime then endDateTime = gsub(endDateTime, "%/", "_") end

		-- Output File Name
		if not outputFileName then 
			outputFileName = "output" 
			if startDateTime then
				outputFileName = outputFileName.."-"..startDateTime
			end
			if endDateTime then
				outputFileName = outputFileName.."_to_"..endDateTime
			end
			if noHtml then
				outputFileName = outputFileName..".txt"
			else
				outputFileName = outputFileName..".htm"
			end
		end

		-- Filters
		local included_channels, excluded_channels
		if filters then
			filters = gsub(filters, "%s", "")
			local filters_table = strsplit(",", filters)
			
			for key, channelOrGroup in pairs(filters_table) do
				local negatedChannel = strmatch(channelOrGroup, "%-([%w_]*)")
				
				if (negatedChannel and channels[negatedChannel]) then
					if not excluded_channels then excluded_channels = {} end
					excluded_channels[negatedChannel] = true
				elseif channels[channelOrGroup] then
					if not included_channels then included_channels = {} end
					included_channels[channelOrGroup] = true
				end
				
				if (negatedChannel and channelGroups[negatedChannel]) then
					if not excluded_channels then excluded_channels = {} end
					for k, chan in pairs(channelGroups[negatedChannel]) do
						excluded_channels[chan] = true
					end
				elseif channelGroups[channelOrGroup] then
					if not included_channels then included_channels = {} end
					for k, chan in pairs(channelGroups[channelOrGroup]) do
						included_channels[chan] = true
					end
				end
			end
		end

		-- Open Files
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
		local junkLines = self:ParseText(inputFile, outputFile, numLines, startDateTime, endDateTime, included_channels, excluded_channels, keyword, avatar, noHtml)
		print("\nProcessed and filtered "..(numLines-junkLines).." lines in "..string.format("%.2f seconds", os.clock() - startTime))
		if startDateTime then print("Entries before "..startDateTime.." were discarded.") end
		if endDateTime then print("Entries after "..endDateTime.." were discarded.") end
		if included_channels then print("Only entries from the following channels were processed: "..tconcatkeys(included_channels, ", ")) end
		if excluded_channels then print("Entries from the following channels were not processed: "..tconcatkeys(excluded_channels, ", ")) end
		
		print("Writing output to file. Please wait...")
		--outputFile:flush()
		outputFile:close()
		print("Wrote output to file: '"..outputFileName.."'")
		inputFile:close()
		
		if openFileAfter then os.execute("start "..outputFileName) end
		
		return 0
	end	
	
	-- --------------------------------------------------------------------------------------------------------------------------------
	-- ParseText
	-- ----------------------------------------------------------------		
	function Parser:ParseLine(line, startTimestamp, endTimestamp, included_channels, excluded_channels, keyword, avatar, noHtml)
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
		timeStamp_number = UNIXTimeToOS(unix_timeStamp)
		
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
		if line == "" or strlen(line) < 1 then junkLine = true end
		
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
			
			-- HChannel
			-- |Hchannel:GUILD|h[Guild]|h, etc.
			-- |Hchannel:INSTANCE_CHAT|h[Instance]|h
			local hChannel = strmatch(line, "|Hchannel:.*|h%[(.*)%]|h%s") 
			if hChannel then 
				channel = hChannel
				line = gsub(line, "|Hchannel:.*|h%[.*%]|h%s", "")
			end
			
			-- Tagged channel
			-- [2. Trade] Bravesteel: x 
			local taggedChannel = strmatch(line, "%[%d+%.%s(.-)%] .-:.-") 
			if taggedChannel then 
				channel = taggedChannel
				line = gsub(line, "%[%d+%.%s.-%] .-: .-", "")
			end
			
			channel = strlower(channel)
			channel = gsub(channel, " ", "")
			if not channels[channel] then 
				channel = "unknown".."("..channel.."?)"
			end
			
			-- Only let entries past if they are in valid channels
			if included_channels then
				if not included_channels[channel] then return nil end -- Blocked by virtue of not being a filter channel
			end
			if excluded_channels then
				if excluded_channels[channel] then return nil end
			end

			-- Keyword filter
			if keyword and not strmatch(line, keyword) then return nil end			
			
			-- Channel tag
			local channelTag = "["..strupper(channel).."]: "
			line = channelTag..line
			
			-- Avatar filter
			if avatar then
				local avatarPattern = "%["..strupper(channel).."%]:%s"..avatar
				if not strmatch(line, avatarPattern) then 
					return nil 
				end
			end

			local lineTable = {}
			-- Line Open
			--parsedText = parsedText..htmlLineOpen
			if noHtml then
				-- Date
				tinsert(lineTable, timeStamp_date)
				tinsert(lineTable, " ")
				tinsert(lineTable, timeStamp_time)
				tinsert(lineTable, line)
				tinsert(lineTable, "\n")
			else
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
			end
			
			return tconcat(lineTable)
		end -- Junkline
	end
	
	-- --------------------------------------------------------------------------------------------------------------------------------
	-- ParseText
	-- ----------------------------------------------------------------		
	function Parser:ParseText(inputFile, outputFile, totalLines, startDateTime, endDateTime, included_channels, excluded_channels, keyword, avatar, noHtml)
		local start_timestamp_number, end_timestamp_number
		-- startDateTime
		if startDateTime then
			local start_timestamp, startTime_month, startTime_day, startTime_hours, startTime_minutes, startTime_seconds
			-- DateTime
			local startTime_month, startTime_day, startTime_hours, startTime_minutes, startTime_seconds = strmatch(startDateTime, "(%d+)%s*%_%s*(%d+)-(%d+):(%d+):(%d+)")
			-- Date Only
			if not startTime_month then
				startTime_month, startTime_day = strmatch(startDateTime, "(%d+)%s*%_%s*(%d+)")
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
			start_timestamp_number = UNIXTimeToOS(start_timestamp)
		end
		
		-- endDateTime
		if endDateTime then
			local end_timestamp, endTime_month, endTime_day, endTime_hours, endTime_minutes, endTime_seconds
			-- DateTime
			local endTime_month, endTime_day, endTime_hours, endTime_minutes, endTime_seconds = strmatch(endDateTime, "(%d+)%s*%_%s*(%d+)-(%d+):(%d+):(%d+)")
			-- Date only
			if not endTime_month then
				endTime_month, endTime_day = strmatch(endDateTime, "(%d+)%s*%_%s*(%d+)")
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
			end_timestamp_number = UNIXTimeToOS(end_timestamp)
		end
	
		-- Write HTML Header, CSS & Colors
		if not noHtml then outputFile:write(htmlHeaderOpen..htmlColorsOpen..htmlColors..htmlColorsClose..htmlHeaderClose..htmlBodyOpen) end
		
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

			-- Only let entries past if they are in valid channels
			parsedLine = self:ParseLine(line, start_timestamp_number, end_timestamp_number, included_channels, excluded_channels, keyword, avatar, noHtml)
			if parsedLine then
				outputFile:write(parsedLine)
			else
				junkLines = junkLines + 1
			end
			numLines = numLines + 1
			line = inputFile:read()
		end
		if not noHtml then outputFile:write(htmlBodyClose) end
		
		return junkLines
	end	
	
	-- --------------------------------------------------------------------------------------------------------------------------------
	-- Info
	-- ----------------------------------------------------------------		
	function Parser:Info(usage)
		print("\n\n========================================")
		print("== World of Warcraft Chat Log Parser by Kvalyr")
		print("== Version: "..Parser.versionString)
		print("== See accompanying README for Instructions and Licence")
		print("== Copyright (c) 2015 Robert Voigt")
		if not usage then 
			print("====================")
		else
			print("========================================")
			print("== Usage instructions:")
			print("====================")
			print("wowchatparser --input=INPUTFILE --output=OUTPUTFILE --start=STARTDATETIME --end=ENDDATETIME --filter=battleground, RP, raid")
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
	
return Parser:Main(...)