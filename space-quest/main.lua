local questgame = require('questgame')
local example_data = require('example')

local function create_syntax_test_quest()
	return {
		id = "syntax_test",
		start_node = "test",
		variables = { name = "Aria", gold = 42, credits = 5, status = "active" },
		nodes = {
			{
				id = "test",
				text = {
					"Plain text without formatting.\n",
					"==Text with highlight.==\n",
					"**Bold text** and *italic text*.\n",
					"~~Strikethrough~~ and `monospace`.\n",
					"Auto-highlight: <name>. ",
					"Bold + highlight: **<gold>**. \n",
					"Italic+monospace: *`code`*. \n",
					"Strike+var: ~~<credits>~~. \n",
					"Complex chain: **bold** *italic* ~~strike~~ `mono` **<status>**.\n"
				},
				choices = {}
			}
		}
	}
end

function love.load()
	math.randomseed(os.time())
	love.graphics.setBackgroundColor(0.05, 0.05, 0.08)
	questgame.init()
	questgame.load(example_data)
end

function love.draw()
	questgame.draw(20, 20, 480)

	-- help text (minimal)
	love.graphics.setColor(0.4, 0.4, 0.4, 1)
	love.graphics.setFont(love.graphics.newFont(12))
	love.graphics.print("[1-9] choose  [r] reset  [t] syntax test", 50, love.graphics.getHeight() - 20)
end

function love.keypressed(key)
	local idx = tonumber(key)
	if idx and idx >= 1 and idx <= 9 then
		if questgame.can_choose(idx) then
			questgame.choose(idx)
		end
	elseif key == "r" then
		questgame.reset(example_data)
	elseif key == "t" then
		questgame.load(create_syntax_test_quest())
	end
end