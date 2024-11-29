-- Luau
--!strict
local oct2bin = {
	['0'] = '000',
	['1'] = '001',
	['2'] = '010',
	['3'] = '011',
	['4'] = '100',
	['5'] = '101',
	['6'] = '110',
	['7'] = '111'
}


local function getOct2bin(a) return oct2bin[a] end
function decimalToBinary(d: number)
	local s = string.format('%o', d)
	s = s:gsub('.', getOct2bin)
	return s
end

function binaryToDecimal(b: string)
	return tostring(tonumber(b, 2))
end

export type SnowflakeOptions = {
	-- Internal worker ID, in decimal.
	-- 5 bits, max = 31.
	worker: number?,
	-- Internal process ID, in decimal.
	-- 5 bits, max = 31.
	pid: number?,
	-- Incremented for every generated ID on that process, in decimal.
	-- 12 bits, max = 4095.
	increment: number?,
	-- The timestamp after the Unix epoch that should be the basis for all dates.
	-- 42 bits.
	epoch: number?
}

export type AbsoluteSnowflakeOptions = {
	-- Internal worker ID, in decimal.
	-- 5 bits, max = 31.
	worker: number,
	-- Internal process ID, in decimal.
	-- 5 bits, max = 31.
	pid: number,
	-- Incremented for every generated ID on that process, in decimal.
	-- 12 bits, max = 4095.
	increment: number,
	-- The timestamp after the Unix epoch that should be the basis for all dates.
	-- 42 bits.
	epoch: number
}

type SnowflakeObject = {
	defaultConfig: UtilTypes.SnowflakeOptions,
	generate: (options: UtilTypes.SnowflakeOptions?, time: number?) -> UtilTypes.Snowflake
}

local defaultConfig: AbsoluteSnowflakeOptions = {
	epoch = 0,
	worker = 1,
	pid = 1,
	increment = 1
}

function appendTo(s: string, c: string, target: number)
	while target > string.len(s)  do
		s = c .. s
	end

	return s
end

function generateSnowflake(config: UtilTypes.SnowflakeOptions?, date: number?)
	if (config) then
		if not config.increment then config.increment = defaultConfig.increment end
		if not config.worker then config.worker = defaultConfig.worker end
		if not config.pid then config.pid = defaultConfig.pid end
		config.epoch = defaultConfig.epoch
	end

	if (config == nil) then
		config = defaultConfig
	end

	local configNonNil = config :: UtilTypes.SnowflakeOptions

	if (typeof(date) ~= "number") then
		date = DateTime.now().UnixTimestampMillis
	end

	local timestamp = date :: number - defaultConfig.epoch
	local workerId = configNonNil.worker :: number
	local processId = configNonNil.pid :: number
	local increment = configNonNil.increment  :: number

	local binaryIncrement = appendTo(decimalToBinary(increment), "0", 12)
	local binaryTime = appendTo(decimalToBinary(timestamp), "0", 42)
	local binaryPid = appendTo(decimalToBinary(processId), "0", 5)
	local binaryWorker = appendTo(decimalToBinary(workerId), "0", 5)

	return tostring(binaryToDecimal(binaryTime..binaryWorker..binaryPid..binaryIncrement))
end

local Snowflake: SnowflakeObject = {
	defaultConfig = defaultConfig,
	generate = generateSnowflake
}

return Snowflake
