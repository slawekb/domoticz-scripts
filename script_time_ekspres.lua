-- This turns the coffee machine on based on time and day.
-- It is switched off by a simple switch timer in Domoticz interface
-- I didn't use simple timer as they cannot depend on another device
-- and obviously I want the machine to stay off if there is noone home (alarm is armed)

local socket = 'Gniazdo: Ekspres'
time = os.date("*t")
commandArray = {}

-- Only go further if the alarm system is not armed
if (otherdevices[socket] == 'Off' and uservariables['IntegraArmed'] == 0) then
	-- Switch on at 7am during the week
	if (time.wday >= 2 and time.wday <= 6 and time.hour == 7 and time.min == 0) then
		commandArray[socket] = 'On'
	end
	-- Switch on at 8am on the weekend
	if ((time.wday == 1 or time.wday == 7) and time.hour == 8 and time.min == 0) then
		commandArray[socket] = 'On'
	end
end
return commandArray
