-- main.lua - Минимальный QM плеер для Love2D
-- Требует файл quests/data.lua с данными квеста


--тесты
require("test_formula")

-- ============================================================================
-- ЗАГРУЗКА ДАННЫХ
-- ============================================================================
--local quest = require("quests.data")
local quest = require("quests.gobsaur")

local font = love.graphics.newFont("fonts/NotoSans-Regular.ttf", 18) 
love.graphics.setFont (font)

-- ============================================================================
-- СОСТОЯНИЕ ИГРЫ
-- ============================================================================
local gameState = {
	params = {},           -- Текущие значения параметров [p1], [p2], etc
	currentLocation = nil, -- Текущая локация
	selectedJump = 1,      -- Выбранный переход
	gameOver = false,
	isWin = false,
--	history = {},           -- История переходов

	availableJumps = {},

	jumpUses = {},

	cachedLocationText = nil,
	cachedLocationId = nil,

}

-- ============================================================================
-- ПОДКЛЮЧЕНИЕ МОДУЛЕЙ
-- ============================================================================

-- Если вы вынесли Formula в отдельный модуль lib/formula.lua:
-- local Formula = require("lib.formula")

-- Временная встроенная версия Formula (пока не создали lib/formula.lua)
local Formula = {}

function Formula.replaceParams(str, params)
	if not str then return "0" end
	return string.gsub(str, "%[p(%d+)%]", function(n)
			return tostring(params[tonumber(n)] or 0)
		end)
end

function Formula.processRandom(str)
	return string.gsub(str, "%[(-?%d+)%.%.(-?%d+)%]", function(min, max)
			return tostring(math.random(tonumber(min), tonumber(max)))
		end)
end

function Formula.convertOperators(str)
	str = string.gsub(str, "<>", "~=")
	str = string.gsub(str, "([^<>~=])=([^=])", "%1==%2")
	str = string.gsub(str, " div ", " // ")
	str = string.gsub(str, " mod ", " %% ")
	return str
end

function Formula.eval(formula, params)
	if not formula or formula == "" then return 0 end

	local expr = Formula.replaceParams(formula, params)
	expr = Formula.processRandom(expr)
	expr = Formula.convertOperators(expr)

	local func, err = load("return " .. expr)
	if not func then
		print("Error parsing formula: " .. formula)
		return 0
	end

	local success, result = pcall(func)
	if not success then
		print("Error evaluating: " .. formula)
		return 0
	end

	return math.floor(tonumber(result) or 0)
end

function Formula.checkCondition(formula, params)
	if not formula or formula == "" then return true end
	return Formula.eval(formula, params) ~= 0
end

function Formula.evaluateTextFormulas(text, params)
	if not text then return "" end
	return string.gsub(text, "{([^}]+)}", function(f)
			return tostring(Formula.eval(f, params))
		end)
end

-- ============================================================================
-- РАБОТА С ЛОКАЦИЯМИ И ПЕРЕХОДАМИ
-- ============================================================================

-- Найти локацию по ID
local function findLocation(locationId)
	for _, loc in ipairs(quest.locations) do
		if loc.id == locationId then
			return loc
		end
	end
	return nil
end

-- Убрать теги форматирования из текста
local function stripTags(text)
	-- Убираем <clr>, <clrEnd>, <fix> и другие теги
	text = string.gsub(text, "<[^>]+>", "")
	-- Формулы уже вычислены через Formula.evaluateTextFormulas
	return text
end

-- Получить текст локации (с кэшированием)
local function getLocationText(location)
	if not location or not location.texts then
		return "Нет текста"
	end

	-- Проверяем кэш
	if gameState.cachedLocationId == location.id and gameState.cachedLocationText then
		return gameState.cachedLocationText
	end

	local textIndex = 1

	-- Если текст выбирается по формуле
	if location.isTextByFormula and location.textSelectFormula then
		textIndex = Formula.eval(location.textSelectFormula, gameState.params)
		textIndex = math.max(1, math.min(textIndex, #location.texts))
	end

	local text = location.texts[textIndex] or location.texts[1] or "Нет текста"

	-- Вычисляем формулы в фигурных скобках
	text = Formula.evaluateTextFormulas(text, gameState.params)
	
	-- Убираем теги сразу
	text = stripTags(text)

	-- Сохраняем в кэш
	gameState.cachedLocationText = text
	gameState.cachedLocationId = location.id

	return text
end

local function checkJumpWithLog(jump)
	local params = gameState.params
	local label = string.format("%d", jump._debugIndex or 0)
	local idpart = jump.id and ("(id="..tostring(jump.id)..")") or ""

	-- проверка лимита использований
	local limit = jump.jumpingCountLimit
	local uses = 0
	if jump.id then uses = gameState.jumpUses[jump.id] or 0
	else uses = gameState.jumpUses[jump._debugIndex] or 0 end

	if limit and limit > 0 and uses >= limit then
		print(string.format("[Jump J%s] %s from L%d -> L%d | blocked: limit %d reached (uses=%d)",
				label, idpart, jump.fromLocationId, jump.toLocationId, limit, uses))
		return false
	end

	-- формула перехода
	local formula = jump.formulaToPass
	if not formula or formula == "" then
		print(string.format("[Jump %s] %s from L%d -> L%d | no formula -> ALLOWED",
				label, idpart, jump.fromLocationId, jump.toLocationId))
		return true
	end

	local replaced = Formula.replaceParams(formula, params)
	local processed = Formula.processRandom(replaced)
	local converted = Formula.convertOperators(processed)
	local ok = Formula.eval(formula, params) ~= 0

	print(string.format("[JUMP CHECK] %s %s from L%d -> L%d | %s -> %s",
			label, idpart, jump.fromLocationId, jump.toLocationId, converted, ok and "ALLOWED" or "BLOCKED"))

	return ok
end



-- Получить доступные переходы из текущей локации
local function updateAvailableJumps()
	gameState.availableJumps = {}

	if not gameState.currentLocation then return end

	for _, jump in ipairs(quest.jumps) do
		if jump.fromLocationId == gameState.currentLocation.id then
			if checkJumpWithLog(jump) then
				table.insert(gameState.availableJumps, jump)
			end
		end
	end
end




-- Применить изменения параметров
local function applyParamChanges(changes, context)
	if not changes or #changes == 0 then return nil end

	local entry = {
		type = "params",
		source = context or {},
		changes = {}
	}

	for _, change in ipairs(changes) do
		local paramIndex = tonumber(string.match(change.index or "", "%[p(%d+)%]"))
		if paramIndex then
			local oldValue = tonumber(gameState.params[paramIndex]) or 0
			local newValue = oldValue

			if change.isChangeFormula then
				newValue = Formula.eval(change.changingFormula, gameState.params)
			elseif change.isChangePercentage then
				newValue = oldValue + math.floor(oldValue * (tonumber(change.change) or 0) / 100)
			elseif change.isChangeValue or change.change ~= nil then
				newValue = oldValue + (tonumber(change.change) or 0)
			end

			local paramMeta = quest.params[paramIndex]
			if paramMeta then
				newValue = math.max(paramMeta.min or newValue, math.min(paramMeta.max or newValue, newValue))
			end

			gameState.params[paramIndex] = newValue

			table.insert(entry.changes, {
					param = paramIndex,
					old = oldValue,
					new = newValue,
					showingType = change.showingType
				})

			print(string.format(
					"[PARAM] p%d: %d -> %d",
					paramIndex,
					oldValue,
					newValue
				))
		end
	end

	return entry
end




-- Перейти в локацию
local function goToLocation(locationId)
	local location = findLocation(locationId)
	if not location then
		print("Location not found: " .. locationId)
		return
	end

	-- Применяем изменения параметров локации
	applyParamChanges(location.paramsChanges)

	gameState.currentLocation = location
	gameState.selectedJump = 1

	-- Проверка на конечную локацию
	if location.type == 3 then -- isSuccess
		gameState.gameOver = true
		gameState.isWin = true
	elseif location.type == 4 then -- isFaily
		gameState.gameOver = true
		gameState.isWin = false
	end

--	-- Сохраняем в историю
--	table.insert(gameState.history, {
--			locationId = locationId,
--			params = {}
--		})

	updateAvailableJumps()

end

local function incrementJumpUse(jump)
	if jump.id then
		gameState.jumpUses[jump.id] = (gameState.jumpUses[jump.id] or 0) + 1
	else
		gameState.jumpUses[jump._debugIndex] = (gameState.jumpUses[jump._debugIndex] or 0) + 1
	end
end

-- Выполнить переход
local function makeJump(jump)
	print(string.format("makeJump [Jump %d] (jump.id=%s) L%d -> L%d",
			jump._debugIndex or 0,
			jump.id,
			jump.fromLocationId,
			jump.toLocationId
		))

	-- применяем изменения параметров перехода
	applyParamChanges(jump.paramsChanges)

	-- увеличиваем счётчик использования
	incrementJumpUse(jump)

	-- затем переход
	goToLocation(jump.toLocationId)

	-- обновляем кэш доступных переходов для новой локации
--	updateAvailableJumps()
	-- ❌ УДАЛЕНО - updateAvailableJumps() уже вызывается внутри goToLocation()

end


-- ============================================================================
-- ИНИЦИАЛИЗАЦИЯ
-- ============================================================================

function love.load()
	love.window.setTitle("QM Player - " .. (quest.taskText or "Quest"))
	love.window.setMode(1280, 800)

	-- Инициализация параметров
	for i, param in ipairs(quest.params) do
		gameState.params[i] = param.starting or 0
	end

	-- debug index and uses
	gameState.jumpUses = {} -- counts uses by jump.id or by debugIndex

	for i, jump in ipairs(quest.jumps) do
		jump._debugIndex = i
		-- ensure jump.id exists (optional) — не переписываем если есть
		-- jump.id = jump.id or (i + 1) -- (не обязательно)
	end

	-- Найти стартовую локацию
	local startLocation = nil
	for _, loc in ipairs(quest.locations) do
		if loc.type == 1 then -- isStarting
			startLocation = loc
			break
		end
	end

	if startLocation then
		goToLocation(startLocation.id)
	else
		print("No starting location found!")
	end

--	updateAvailableJumps()

end

-- ============================================================================
-- ОТРИСОВКА
-- ============================================================================

-- Простая функция для переноса текста
local function wrapText(text, maxWidth)
	local font = love.graphics.getFont()
	local _, wrappedText = font:getWrap(text, maxWidth)
	return wrappedText
end



function love.draw()
	love.graphics.clear(0.1, 0.1, 0.15)

	if not gameState.currentLocation then
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("Загрузка...", 50, 50)
		return
	end

	local y = 20

	-- Заголовок локации
	love.graphics.setColor(1, 1, 0.5)
	love.graphics.print("Локация L" .. gameState.currentLocation.id, 20, y)
	y = y + 30

	-- Параметры игрока (показываем только важные)
	love.graphics.setColor(0.8, 0.8, 0.8)
	local paramText = ""
	for i = 1, math.min(10, #quest.params) do
		local param = quest.params[i]
		if param then
			paramText = paramText .. param.name .. ": " .. gameState.params[i] .. "  "
		end
	end
	love.graphics.print(paramText, 20, y)
	y = y + 25

	-- Разделитель
	love.graphics.setColor(0.5, 0.5, 0.5)
	love.graphics.line(20, y, 780, y)
	y = y + 10

	-- Текст локации
	love.graphics.setColor(1, 1, 1)
	local text = getLocationText(gameState.currentLocation)
	-- stripTags уже вызван внутри getLocationText

	local wrappedText = wrapText(text, 760)
	for _, line in ipairs(wrappedText) do
		love.graphics.print(line, 20, y)
		y = y + 20
		if y > 350 then break end -- Ограничиваем высоту текста
	end

	y = math.max(y, 380)

	-- Разделитель
	love.graphics.setColor(0.5, 0.5, 0.5)
	love.graphics.line(20, y, 780, y)
	y = y + 10

	-- Переходы
	if gameState.gameOver then
		love.graphics.setColor(1, 1, 1)
		if gameState.isWin then
			love.graphics.print("ПОБЕДА! Нажмите ESC для выхода", 20, y)
		else
			love.graphics.print("ПОРАЖЕНИЕ! Нажмите ESC для выхода", 20, y)
		end
	else
--		local jumps = updateAvailableJumps()
		local jumps = gameState.availableJumps

		if #jumps == 0 then
			love.graphics.setColor(1, 0.5, 0.5)
			love.graphics.print("Нет доступных переходов!", 20, y)
		else
			love.graphics.setColor(0.9, 0.9, 1)
			love.graphics.print("Выберите действие (↑↓ Enter):", 20, y)
			y = y + 25

			for i, jump in ipairs(jumps) do
				local color = (i == gameState.selectedJump) 
				and {1, 1, 0} or {0.7, 0.7, 0.7}

				love.graphics.setColor(color)
--				local jumpText = string.format("%d. %s", i, jump.text or "Переход")
				local jumpText = string.format(
					"%d. [J%d->L%d] %s",
					i,
					jump.id or i,
					jump.toLocationId,
					jump.text or "Переход"
				)

				love.graphics.print(jumpText, 40, y)
				y = y + 20
			end
		end
	end
end

-- ============================================================================
-- ОБРАБОТКА ВВОДА
-- ============================================================================

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
		return
	end

	if gameState.gameOver then
		return
	end

--	local jumps = updateAvailableJumps()
	local jumps = gameState.availableJumps


	if key == "up" then
		gameState.selectedJump = math.max(1, gameState.selectedJump - 1)
	elseif key == "down" then
		gameState.selectedJump = math.min(#jumps, gameState.selectedJump + 1)
	elseif key == "return" or key == "space" then
		local selectedJump = jumps[gameState.selectedJump]
		if selectedJump then
			makeJump(selectedJump)
		end
	end
end