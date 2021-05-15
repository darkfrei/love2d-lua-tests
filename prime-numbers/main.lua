function prime(n)
	for i = 2, math.floor(n^(1/2)) do
		if (n % i) == 0 then
			return false
		end
	end
	return true
 end

function love.load()
--	Now = os.date('*t')
--	print(Now.hour .. ' ' .. Now.min .. ' ' .. Now.sec)
	
--	local ns = 1*10^3 -- 0.81 s
--	local ns = 1*10^4 -- 0.64 s
--	local ns = 1*10^5 -- 0.71 s
--	local ns = 1*10^6 -- 0.91 s
	local ns = 1*10^7 -- 7.05 s
--	local ns = 1*10^8 -- 171.79 s
	
--	local ns = 37*10^7

	primes = 1 -- 2 is here already
	not_primes = 0
	local prime_last = 0
	for n = 3, (ns), 2 do
		if prime(n) then
			primes = primes + 1
			prime_last = n
		else
			not_primes = not_primes + 1
		end
	end
	print ('primes: '..primes .. ' not_primes: '..not_primes .. ' prime_last: ' .. prime_last)
--	Now = os.date('*t')
	print(Now.hour .. ' ' .. Now.min .. ' ' .. Now.sec)
	
end
 
 
function love.update(dt)
	
end
 
 
function love.draw()
	love.event.quit() 
	love.graphics.print(primes, 10, 10)
end
