-- game-config.lua

local GameConfig = {
	tileSize = 40,
	tileCountW = 32,
	tileCountH = 18
}

print('game-config.lua:')
print('Tile size:', GameConfig.tileSize)
print('Tiles W x H:', GameConfig.tileCountW..' x '..GameConfig.tileCountH)
print('')

return GameConfig