-- This script executes several actions based
-- on events from the alarm system

-- Some switches that correspond to signals from the alarm system
local alarm = 'Arm 1 partition'       -- Partition arm status indicator
local entry = 'Output:CzasNaWejscie'  -- Time for entry indicator
local breakin = 'Output:Alarm'        -- Actual alarm  signal (break in attempt)

-- Log messages to Domoticz log if "Debug" user variable is set in Domoticz
function debuglog (s)
   if uservariables["Debug"] == 1 then print("INTEGRA: " .. s) end
   return true
end

-- Get current time
time = os.date("*t")

commandArray = {}

-- Alarm signals time for entry (time to enter disarm code after opening the door)
if (devicechanged[entry]) then
	if (otherdevices_svalues[entry] == 'On') then
		-- Turn on some lights
		commandArray['Integra: Oswietlenie'] = 'On'
		commandArray['Światło: Akwarium'] = 'On'
		commandArray['Światło: Przedpokój'] = 'On AFTER 1'
		debuglog ('Integra: Czas na wejscie')
	end
end

-- Alarm system is armed and was previously disarmed
if (devicechanged[alarm] == 'On' and uservariables['IntegraArmed'] == 0) then
	debuglog('Integra armed')
	-- Send notification to my phone and update status variable
	commandArray['SendNotification'] = 'Integra#Czuwanie załączone#0'
	commandArray['Variable:IntegraArmed'] = '1'
	-- Turn off lights using a scene 
	commandArray['Scene:Ciemność'] = 'On'
	-- Turn off coffee maker and set heating to night mode
	commandArray['Gniazdo: Ekspres'] = 'Off AFTER 300'
	commandArray['Ogrzewanie: Dzień/Noc'] = 'Off'
	commandArray['Integra: Oswietlenie'] = 'Off AFTER 120'
	-- Set presence indicator to off
	commandArray['Ogólne: Obecność'] = 'Off AFTER 30'
end

-- Alarm system is disarmed and was armed previously
if (devicechanged[alarm] == 'Off' and uservariables['IntegraArmed'] == 1) then
	debuglog('Integra disarmed')
	-- Turn on hall lights, send notification, update status variable
	commandArray['Integra: Oswietlenie'] = 'On'
	commandArray['Światło: Przedpokój'] = 'On'
	commandArray['SendNotification'] = 'Integra#Czuwanie wyłączone#0'
	commandArray['Variable:IntegraArmed'] = '0'
	-- If it's night, turn on a light
	if timeofday['Nighttime'] then
		commandArray['Światło: Duża lampka'] = 'On'
	end
	-- If it's not too late yet, turn on the coffe maker and fishtank light
	if (time.hour >= 7 and time.hour < 21) then
		commandArray['Gniazdo: Ekspres'] = 'On AFTER 15'
		commandArray['Światło: Akwarium'] = 'On'
	end
	-- Set heating mode to day, holidays to off and presence to on
	commandArray['Ogólne: Wakacje'] = 'Off'
	commandArray['Ogólne: Obecność'] = 'On'
	commandArray['Ogrzewanie: Dzień/Noc'] = 'On'
end

-- Send notification if there was a break in
if (devicechanged[breakin] == 'On') then
		commandArray['SendNotification'] = 'Integra#ALARM!!!#2'
end


if (devicechanged['Output:Awaria']) then
	-- Send notification if alarm system reports any failure
	if (otherdevices_svalues['Output:Awaria'] == 'On') then
		commandArray['SendNotification'] = 'Integra#Awaria#0'
		debuglog ('Integra: Awaria')
	end
	-- Send notification if the fault has cleared
	if (otherdevices_svalues['Output:Awaria'] == 'Off') then
		commandArray['SendNotification'] = 'Integra#OK#0'
		debuglog('Integra: OK')
	end
end

return commandArray
