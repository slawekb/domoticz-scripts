-- Turns on the bathroom extrator fan if the humidity rises above set level
-- It takes into account outside temperature and humidity to prevent pointlessly
-- spinning the fan if air outside is too wet to make a difference

-- Devices used
local fan = 'Gniazdo: Wentylator'             -- Fan switch
local sensor = 'Temp: Łazienka'               -- Bathroom temp/humidity sensor
local sensoroutside = 'Temp: Zewnątrz'        -- Outside temp/humidity sensor
local target = uservariables['TargetHumidity'] -- Target humidity (user variable in Domoticz)
local failtime = 1200                         -- Sensor fail timeout (if sensor wasn't updated this long, assume it's faulty)
local offset = uservariables['OffsetHumidity'] -- Humidity offset (user var) 

function timedifference (s)
	year = string.sub(s, 1, 4)
	month = string.sub(s, 6, 7)
	day = string.sub(s, 9, 10)
	hour = string.sub(s, 12, 13)
	minutes = string.sub(s, 15, 16)
	seconds = string.sub(s, 18, 19)
	t1 = os.time()
	t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
	difference = os.difftime (t1, t2)
	return difference
end

-- Debug logging function
function debuglog (s)
	if uservariables["Debug"] == 1 then print("HUMIDITY: " .. s) end
	return true
end

-- Relative humidity will change once the outside air is sucked in and heated, so
-- calculate humidity that is possible to achieve inside based on temp/humidity of outside air
-- t1 - outside temp, t2 - inside temp, rh1 - outside humidity, rh2 - resulting humidity of air when heated
function humidity (t1, t2, rh1)
	rh2 = rh1 * math.exp(t1*0.06235398) / math.exp(t2*0.06235398)
	return math.ceil(rh2)
end

local updated = timedifference(otherdevices_lastupdate[sensor]) -- sensor last updated
local humidityoutside = otherdevices_humidity[sensoroutside] -- outside humidity
local tempoutside = tonumber(string.gmatch(otherdevices_svalues[sensoroutside], '([^;]+)')(1)) -- outside temp
local tempinside = tonumber(string.gmatch(otherdevices_svalues[sensor], '([^;]+)')(1)) -- inside temp
local possibletarget = humidity(tempoutside, tempinside, humidityoutside) -- humidity of outside air when heated to inside temp

debuglog("Tout: " .. otherdevices_svalues[sensoroutside] .. " Tin: " .. otherdevices_svalues[sensor])

commandArray = {}

humidity = otherdevices_humidity[sensor]
debuglog('Current: ' .. tostring(humidity) .. ' Target: ' .. tostring(target) .. ' Possible target: ' .. tostring(possibletarget))
debuglog('Last sensor update: ' .. tostring(updated) .. ' seconds ago')

-- If humidity is too high and outside air is dry enough, turn on the extractor fan
-- Fan will be turned off by a timer in Domoticz
if (humidity > target and updated < failtime and possibletarget <= (humidity - offset)) then
	debuglog('Fan on')
	commandArray[fan] = 'On'
end	

return commandArray
