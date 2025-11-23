-- https://github.com/roginvs/space-rangers-quest/blob/master/src/lib/qmreader.ts

return { -- quest.qmm
	header = 1111111127,
	givingRace = 31,
	whenDone = 1,
	planetRace = 64,
	playerCareer = 7,
	playerRace = 31,
	reputationChange = 1,
	screenSizeX = 1920,
	screenSizeY = 1009,
	widthSize = 30,
	heightSize = 24,
	defaultJumpCountLimit = 0,
	hardness = 50,
	majorVersion = 1,
	minorVersion = 0,
	changeLogString = "",
	 
	defaultParam = {
		type = 0,
		showWhenZero = true,
		critType = 0,
		active = true,
		isMoney = false,
		critValueString = "",
	},
	defaultParamChange = {
		change = 0,
		showingType = 0, -- don't change
		isChangePercentage = false,
		isChangeValue = false,
		isChangeFormula = true,
	},
	defaultLocation = {
		type = 2,
		maxVisits = 0,
		dayPassed = false,
		isTextByFormula = false,
		textSelectFormula = "",
	},
	defaultJump = {
		priority = 1.0,
		dayPassed = false,
		alwaysShow = false,
		jumpingCountLimit = 0,
		showingOrder = 5,
		text = "",
		description = "",
		formulaToPass = "",
	},
	 
	strings = {
		ToStar = "<ToStar>",
		ToPlanet = "<ToPlanet>",
		Date = "<Date>",
		Money = "<Money>",
		FromPlanet = "<FromPlanet>",
		FromStar = "<FromStar>",
		Ranger = "<Ranger>",
	},
	taskText = "Знаменитый рейс Кон-Тики! Триумфальное возвращение Михаила Коршунова с Луны на Землю! \nНа ржавом корыте!\n\nОчень хочется видеть это в форме квеста, но для этого в квестовый движок придётся засунуть <clr>Б3-34<clrEnd>. \nЧто из всего этого получится, пока не ясно...\n\nНо вы можете опробовать альфа-версию... На свой страх и риск...\n",
	successText = "Вам правда это удалось? От всей души поздравляю!\n\nА также выражаю крайнюю признательность Михаилу Пухову, Евгению Катышеву, да и всему коллективу редакции \"Техники Молодёжи\" в целом.\n\nНе будь этого журнала и не будь рубрики КЭИ в нём, моя жизнь, вероятно, сложилась бы совсем по-другому.\n\n",
	-- amount params: 56
	params = {
		{
			index = "[p1]",
			name = "RRR",
			min = 0,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p2]",
			name = "cred",
			min = 0,
			max = 10000,
			starting = 1000,
		},
		{
			index = "[p3]",
			name = "bet",
			min = 0,
			max = 1000,
			starting = 500,
		},
		{
			index = "[p4]",
			name = "rRR",
			min = 0,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p5]",
			name = "rXn",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p6]",
			name = "rXd",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p7]",
			name = "rYn",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p8]",
			name = "rYd",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p9]",
			name = "rZn",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p10]",
			name = "rZd",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p11]",
			name = "rTn",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p12]",
			name = "rTd",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p13]",
			name = "rRn",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p14]",
			name = "rRd",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p15]",
			name = "r0n",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p16]",
			name = "r0d",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p17]",
			name = "r1n",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p18]",
			name = "r1d",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p19]",
			name = "r2n",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p20]",
			name = "r2d",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p21]",
			name = "r3n",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p22]",
			name = "r3d",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p23]",
			name = "r4n",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p24]",
			name = "r4d",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p25]",
			name = "r5n",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p26]",
			name = "r5d",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p27]",
			name = "r6n",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p28]",
			name = "r6d",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p29]",
			name = "r7n",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p30]",
			name = "r7d",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p31]",
			name = "r8n",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p32]",
			name = "r8d",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p33]",
			name = "r9n",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p34]",
			name = "r9d",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p35]",
			name = "rAn",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p36]",
			name = "rAd",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p37]",
			name = "rBn",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p38]",
			name = "rBd",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p39]",
			name = "rCn",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p40]",
			name = "rCd",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p41]",
			name = "rDn",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p42]",
			name = "rDd",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p43]",
			name = "rEn",
			min = -100000000,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p44]",
			name = "rEd",
			min = 1,
			max = 100000000,
			starting = 1,
		},
		{
			index = "[p45]",
			name = "rA",
			min = 0,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p46]",
			name = "rB",
			min = 0,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p47]",
			name = "rC",
			min = 0,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p48]",
			name = "rD",
			min = 0,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p49]",
			name = "rE",
			min = 0,
			max = 100000000,
			starting = 0,
		},
		{
			index = "[p50]",
			name = "eMD",
			min = 0,
			max = 2,
			starting = 0,
		},
		{
			index = "[p51]",
			name = "coffe",
			min = 0,
			max = 10,
			starting = 0,
		},
		{
			index = "[p52]",
			name = "variant",
			min = 1,
			max = 10,
			starting = 1,
		},
		{
			index = "[p53]",
			name = "fuel",
			min = 0,
			max = 100,
			starting = 0,
		},
		{
			index = "[p54]",
			name = "time",
			min = 1,
			max = 100,
			starting = 10,
		},
		{
			index = "[p55]",
			name = "angl",
			min = -180,
			max = 180,
			starting = 0,
			showingInfo = {
				{from=-180, to=179, str=""},
				{from=180, to=180, str="Реверс тяги!"},
			},
		},
		{
			index = "[p56]",
			name = "stage",
			min = 0,
			max = 2,
			starting = 0,
		},
	},
	locations = {
		{
			index = 1, -- number
			id = 236, -- location [L236]
			type = 1, -- isStarting
			locX = 288,
			locY = 231,
			texts = {
				"Самое увлекательное приключение XXI века началось с чашки кофе. Мы с Эдиком Рыжковским завтракали в буфете астровокзала на девятом этаже. Лучший лунный кофе делали здесь, но получить его было непросто. \n\nСовсем недавно на раздачу установили игровой автомат и с этих пор, для получения чашки вожделенного напитка, приходилось решать астронавигационные задачи. Кофе помогал в их решении, но именно его то и не было.\n\n- Спорим на [p3] кредов, что железка опять тебя прокатит? - сказал Эдик\n\nНедавно он совершил почти невозможное: выиграл целых две кружки подряд, но похоже, что полоса его везения на этом закончилась.\n",
			},
			media = {
				{
					img = "lunolet_6.jpg",
				},
			},
		},
		{
			index = 2, -- number
			id = 239, -- location [L239]
			type = 0, -- undefined
			locX = 352,
			locY = 231,
			isTextByFormula = true,
			textSelectFormula = "([p51]>0)+1",
			texts = {
				"Мы с Эдиком продолжали сидеть за столиком. Кофе хотелось мучительно. В этом состоянии мы и пребывали, когда в помещение вошёл незнакомый нам человек. Он вошёл уверенной лунной походкой, какая замечается лишь у коренных \"селенитов\". На Луне все ходят замедленно, но у тех кто недавно прилетел с Земли или Марса, это выглядит неуклюже.\n\nНаш незнакомец шагал настоящей лунной походкой и это было странно - мы хорошо знаем всех местных жителей, не так уж нас и много. Внешность у него была запоминающаяся - подтянутый, среднего роста, глаза голубые, на голове короткий ёжик совершенно седых волос.\n\nОн направился прямо к стойке, взял несколько бутербродов, стакан оранджа, окинул взглядом зал, подошёл к нашему столику и попросил разрешения сесть.\n",
				"Мы с Эдиком смаковали честно заработанный кофе, когда в помещение вошёл незнакомый нам человек. Он вошёл уверенной лунной походкой, какая замечается лишь у коренных \"селенитов\". На Луне все ходят замедленно, но у тех кто недавно прилетел с Земли или Марса, это выглядит неуклюже.\n\nНаш незнакомец шагал настоящей лунной походкой и это было странно - мы хорошо знаем всех местных жителей, не так уж нас и много. Внешность у него была запоминающаяся - подтянутый, среднего роста, глаза голубые, на голове короткий ёжик совершенно седых волос.\n\nОн направился прямо к стойке, взял несколько бутербродов, стакан оранджа, окинул взглядом зал, подошёл к нашему столику и попросил разрешения сесть.\n",
			},
			media = {
				{
					img = "lunolet_1.jpg",
				},
				{
					img = "lunolet_1.jpg",
				},
			},
			paramsChanges = { -- amount: 56
				{
					index = "[p56]",
					changingFormula = "1",
				},
			},
		},
		{
			index = 3, -- number
			id = 237, -- location [L237]
			type = 0, -- undefined
			locX = 288,
			locY = 189,
			texts = {
				"Я поднялся на ноги, потянулся и не спеша побрёл к игровому автомату. В последнюю неделю, он мучал нас всех посадкой на безатмосферное тело.\n\nАппарат с химическим реактивным двигателем начинал своё движение к Луне на произвольно заданной высоте, от соискателя же требовалось подавать команды двигателю таким образом, чтобы завершить движение у самой поверхности со скоростью не более <clr>5<clrEnd> метров в секунду.\n\nПревышать ускорение свыше <clr>3g<clrEnd> также не рекомендовалась. Аппарат имитировал потерю пилотом сознания, а за то время что он \"приходил в себя\" можно было и в Луну врезаться...\n",
			},
			media = {
				{
					img = "lunolet_10.jpg",
				},
			},
		},
		{
			index = 4, -- number
			id = 240, -- location [L240]
			type = 0, -- undefined
			locX = 352,
			locY = 189,
			isTextByFormula = true,
			textSelectFormula = "[p52]",
			texts = {
				"Отхлебнув оранджа, незнакомец повёл носом. В воздухе плавал кофейный аромат.\n\n- Вы с какой-нибудь дальней базы? - спросил Эдик.\n- С дальней? - незнакомец прищурился. - Можно и так сказать. А почему вы так решили?\n- Селенита видно по походке, - объяснил Эдик. В Центре мы вас раньше не встречали, да и во всех ближних точках я тоже бывал.\n- Понял вашу логику, - кивнул незнакомец, но скажите, где взять кофе? В баре я видел только это, - он поднял свой стакан, - и минеральную воду.\n- Кофе в автомате. - Эдик махнул рукой. - Только не выиграешь. Раздобыть сразу две чашки выпадает раз в жизни.\n- А что за игра? Шахматы? Или какой-нибудь \"Стартрек\"?\n- Нет, здесь игра для профессионалов, чтобы кофе шёл основному лётному составу, а не всяким там...\n\nНезнакомец посмотрел на Эдика с недоумением.\n\n- Надо попробовать. - Он встал со своего места. - Вам принести?\n- Я, право, не знаю... - заколебался я.\n- Несите, - сказал Элик. В голосе его звучало злорадство. - Две..., нет, лучше три чашки...\n",
				"- А где взять кофе? В баре я видел только это, - он поднял свой стакан, - и минеральную воду.\n- Кофе в автомате. - Эдик махнул рукой. - Только не выиграешь. Раздобыть две чашки выпадает раз в жизни.\n- А что за игра? Шахматы? Или какой-нибудь \"Стартрек\"?\n- Нет, здесь игра для профессионалов, чтобы кофе шёл основному лётному составу, а не всяким там...\n\nНезнакомец посмотрел на Эдика с недоумением.\n\n- Надо попробовать. - Он встал со своего места. - Вам принести?\n- Я, право, не знаю... - заколебался я.\n- Несите, - сказал Элик. В голосе его звучало злорадство. - Две..., нет, лучше три чашки...\n",
			},
		},
		{
			index = 5, -- number
			id = 238, -- location [L238]
			type = 0, -- undefined
			locX = 416,
			locY = 231,
			texts = {
				"<fix> Высота: {[p35] div [p36]}<clr>.<clrEnd>{((([p35]*100) div [p36]) mod 100)*(1-2*([p35]<0))} м</fix>\n<fix> Запас топлива: {[p41] div [p42]}<clr>.<clrEnd>{((([p41]*100) div [p42]) mod 100)*(1-2*([p41]<0))} кг</fix>\n",
			},
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "0",
				},
				{
					index = "[p5]",
					changingFormula = "0",
				},
				{
					index = "[p6]",
					changingFormula = "1",
				},
				{
					index = "[p7]",
					changingFormula = "0",
				},
				{
					index = "[p8]",
					changingFormula = "1",
				},
				{
					index = "[p9]",
					changingFormula = "0",
				},
				{
					index = "[p10]",
					changingFormula = "1",
				},
				{
					index = "[p11]",
					changingFormula = "0",
				},
				{
					index = "[p12]",
					changingFormula = "1",
				},
				{
					index = "[p13]",
					changingFormula = "0",
				},
				{
					index = "[p14]",
					changingFormula = "1",
				},
				{
					index = "[p15]",
					changingFormula = "0",
				},
				{
					index = "[p16]",
					changingFormula = "1",
				},
				{
					index = "[p17]",
					changingFormula = "0",
				},
				{
					index = "[p18]",
					changingFormula = "1",
				},
				{
					index = "[p19]",
					changingFormula = "0",
				},
				{
					index = "[p20]",
					changingFormula = "1",
				},
				{
					index = "[p21]",
					changingFormula = "0",
				},
				{
					index = "[p22]",
					changingFormula = "1",
				},
				{
					index = "[p23]",
					changingFormula = "162",
				},
				{
					index = "[p24]",
					changingFormula = "100",
				},
				{
					index = "[p25]",
					changingFormula = "2250",
				},
				{
					index = "[p26]",
					changingFormula = "1",
				},
				{
					index = "[p27]",
					changingFormula = "3660",
				},
				{
					index = "[p28]",
					changingFormula = "1",
				},
				{
					index = "[p29]",
					changingFormula = "2943",
				},
				{
					index = "[p30]",
					changingFormula = "100",
				},
				{
					index = "[p31]",
					changingFormula = "0",
				},
				{
					index = "[p32]",
					changingFormula = "1",
				},
				{
					index = "[p33]",
					changingFormula = "505",
				},
				{
					index = "[p34]",
					changingFormula = "1",
				},
				{
					index = "[p35]",
					changingFormula = "[300..800]",
				},
				{
					index = "[p36]",
					changingFormula = "1",
				},
				{
					index = "[p37]",
					changingFormula = "0",
				},
				{
					index = "[p38]",
					changingFormula = "1",
				},
				{
					index = "[p39]",
					changingFormula = "0",
				},
				{
					index = "[p40]",
					changingFormula = "1",
				},
				{
					index = "[p41]",
					changingFormula = "[200..500]",
				},
				{
					index = "[p42]",
					changingFormula = "1",
				},
				{
					index = "[p43]",
					changingFormula = "0",
				},
				{
					index = "[p44]",
					changingFormula = "1",
				},
			},
		},
		{
			index = 6, -- number
			id = 241, -- location [L241]
			type = 0, -- undefined
			locX = 416,
			locY = 189,
			texts = {
				"- Я его прищемил, - сказал Эдик. - Думает, раз он профессионал, всё получится. Как бы не так!\n- Зачем ты так? Ты же его не знаешь.\n- Человека видно по походке, - произнёс Эдик. - Обыкновенный пижон...\n\nОн замолчал, потому что по залу пронёсся восхищённый ропот. Наш новый знакомый возвращался, балансируя подносом, уставленным чашками кофе.\n\n- Себе я взял две, если не возражаете, - сказал он, опускаясь в кресло. - А вам по три, как и просили...\n",
			},
			media = {
				{
					img = "lunolet_5.jpg",
				},
			},
		},
		{
			index = 7, -- number
			id = 28, -- location [L28]
			type = 2, -- isEmpty
			locX = 288,
			locY = 315,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p35]",
				},
				{
					index = "[p6]",
					changingFormula = "[p36]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 8, -- number
			id = 242, -- location [L242]
			type = 0, -- undefined
			locX = 480,
			locY = 189,
			texts = {
				"Эдик сидел, опустив глаза. Лицо у него полыхало. Он, обжигаясь, пил кофе большими глотками.\n\n- А где вы раньше летали? - спросил я чуть погодя.\n- Юпитер, - сказал он. - Ио, Европа, Каллисто... А сейчас в отставке... По возрасту.\n- И что теперь?\n- Теперь на Землю, - сказал он.\n",
			},
			media = {
				{
					img = "lunolet_1.jpg",
				},
			},
		},
		{
			index = 9, -- number
			id = 29, -- location [L29]
			type = 2, -- isEmpty
			locX = 352,
			locY = 315,
		},
		{
			index = 10, -- number
			id = 243, -- location [L243]
			type = 0, -- undefined
			locX = 480,
			locY = 231,
			texts = {
				"Я тоже туда собираюсь. В отпуск.\n\n- По рукам. Вы мне нравитесь. Пойдёте со мной штурманом? Меня зовут Михаил Коршунов. Профессиональная кличка Лунный Коршун. Так договорились - летим вместе?\n- Договорились, - сказал я. Меня зовут <Ranger>. Только лайнер ушёл вчера. Теперь две недели ждать...\n\nМихаил поморщился. Лайнер. Скукотища... Стюардесса разносит конфеты и воду. Заставляют сидеть в кресле...\n\n- А как же иначе? Космический лифт пока не построили.\n- Вот и я думаю, - сказал Михаил Коршунов. - Простите, Эдуард, если не ошибаюсь? Вы говорили что много летаете? Не знаете, где можно раздобыть корабль? Хотя бы плохонький?\n",
			},
		},
		{
			index = 11, -- number
			id = 31, -- location [L31]
			type = 2, -- isEmpty
			locX = 480,
			locY = 315,
		},
		{
			index = 12, -- number
			id = 30, -- location [L30]
			type = 2, -- isEmpty
			locX = 416,
			locY = 315,
		},
		{
			index = 13, -- number
			id = 244, -- location [L244]
			type = 0, -- undefined
			locX = 544,
			locY = 189,
			texts = {
				"Краска с него уже схлынула, а в глазах появилось выражение, которое мне очень не понравилось. Что-то нехорошое, мстительное.\n\n- Плохонький? - повторил он.\n- Меня устроит любой, лишь бы двигатель был цел.\n- Тогда я вам помогу. У меня есть именно то что вам нужно.\n",
			},
		},
		{
			index = 14, -- number
			id = 32, -- location [L32]
			type = 2, -- isEmpty
			locX = 480,
			locY = 357,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "0",
				},
				{
					index = "[p6]",
					changingFormula = "1",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
			},
		},
		{
			index = 15, -- number
			id = 33, -- location [L33]
			type = 2, -- isEmpty
			locX = 480,
			locY = 399,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]+2",
				},
				{
					index = "[p50]",
					changingFormula = "1",
				},
			},
		},
		{
			index = 16, -- number
			id = 61, -- location [L61]
			type = 2, -- isEmpty
			locX = 1184,
			locY = 315,
		},
		{
			index = 17, -- number
			id = 245, -- location [L245]
			type = 4, -- isFaily
			locX = 544,
			locY = 231,
			texts = {
				"Я решительно встал из-за стола. Лунный Коршун смотрел на меня с недоумением и... какой-то жалостью?\nРазвернувшись, я зашагал к выходу. Я дождался своего лайнера, там были стюардесса, вода и конфеты...\nА про завершение этой истории я узнал из газет. \n\nЗнаменитый рейс Кон-Тики! Лунный Коршун в одиночку осуществляет перелёт с Луны на Землю!\nТриумфальный рейс на ржавом корыте, завершившийся где-то в Атлантике. Там Михаил вызвал спасателей.\nЛунный Коршун не умел плавать...\n\nИменно из газет я узнал о самом интересном приключении XXI-го века, в котором так и не принял участие.\n",
			},
			media = {
				{
					img = "lunolet_8.jpg",
				},
			},
		},
		{
			index = 18, -- number
			id = 246, -- location [L246]
			type = 0, -- undefined
			locX = 608,
			locY = 189,
			texts = {
				"Я знал что было у Эдика. Ведь именно на этом корыте я чуть не разбился пару недель назад!\n\n- На этом нельзя летать! Даже на орбиту нельзя выйти!\n- Давайте, посмотрим описание? - сказал Лунный Коршун.\n\nЭдик выложил на стол паспорт - да-да, того самого лунолёта!\n\nКоршунов погрузился в чтение. Он шевелил губами, иногда повторяя вслух: сухая масса - две тонны. Топливо - керосин и кислород. Предназначен для перелётов вдоль поверхности Луны на расстояния не свыше 1000 километров...\n",
			},
		},
		{
			index = 19, -- number
			id = 34, -- location [L34]
			type = 2, -- isEmpty
			locX = 544,
			locY = 315,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p7]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 20, -- number
			id = 62, -- location [L62]
			type = 2, -- isEmpty
			locX = 1248,
			locY = 315,
		},
		{
			index = 21, -- number
			id = 63, -- location [L63]
			type = 2, -- isEmpty
			locX = 1312,
			locY = 315,
		},
		{
			index = 22, -- number
			id = 247, -- location [L247]
			type = 0, -- undefined
			locX = 608,
			locY = 231,
			texts = {
				"Он смеялся долго и искренне. Эдик тоже засмеялся - сначала робко, потом всё уверенней. На них оглядывались. Я молча ждал, пытаясь сообразить, во что может вылиться эта ситуация.\n\n- Ну и колымага!- отсмеявшись сказал Коршунов. - Но зачем все эти дурацкие ограничители? На ускорение, на расход, на время манёвра? Учтите - я всё это выброшу.\n\nЛицо у Эдика Рыжковского стало растерянным.\n\n- Да вы что... берёте?\n- Конечно. Мы же с вами договорились. Разве не так?\n- Но я же просто пошутил! - воскликнул Эдик. - Прошу вас меня извинить...\n- Извинения не принимаются, - холодно заявил Дунный Коршун. Я беру ваше судно.\n- Но это безумие! - рассвирипел Эдик. Эта машина никогда не поднималась на орбиту, идти на ней в космос - это всё равно что переплывать океан на плоту!\n- Но ведь переплывали же, - спокойно возразил Коршунов. С вашего разрешения, нарекаю это судно \"Кон-Тики\".\n\nТак началась эта удивительная история. Мы выбросили с Кон-Тики всё лишнее, установили на него дополнительные баки...\n",
			},
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "0",
				},
				{
					index = "[p5]",
					changingFormula = "0",
				},
				{
					index = "[p6]",
					changingFormula = "1",
				},
				{
					index = "[p7]",
					changingFormula = "0",
				},
				{
					index = "[p8]",
					changingFormula = "1",
				},
				{
					index = "[p9]",
					changingFormula = "0",
				},
				{
					index = "[p10]",
					changingFormula = "1",
				},
				{
					index = "[p11]",
					changingFormula = "0",
				},
				{
					index = "[p12]",
					changingFormula = "1",
				},
				{
					index = "[p13]",
					changingFormula = "0",
				},
				{
					index = "[p14]",
					changingFormula = "1",
				},
				{
					index = "[p15]",
					changingFormula = "0",
				},
				{
					index = "[p16]",
					changingFormula = "1",
				},
				{
					index = "[p17]",
					changingFormula = "0",
				},
				{
					index = "[p18]",
					changingFormula = "1",
				},
				{
					index = "[p19]",
					changingFormula = "0",
				},
				{
					index = "[p20]",
					changingFormula = "1",
				},
				{
					index = "[p21]",
					changingFormula = "0",
				},
				{
					index = "[p22]",
					changingFormula = "1",
				},
				{
					index = "[p23]",
					changingFormula = "162",
				},
				{
					index = "[p24]",
					changingFormula = "100",
				},
				{
					index = "[p25]",
					changingFormula = "2250",
				},
				{
					index = "[p26]",
					changingFormula = "1",
				},
				{
					index = "[p27]",
					changingFormula = "3660",
				},
				{
					index = "[p28]",
					changingFormula = "1",
				},
				{
					index = "[p29]",
					changingFormula = "2943",
				},
				{
					index = "[p30]",
					changingFormula = "100",
				},
				{
					index = "[p31]",
					changingFormula = "0",
				},
				{
					index = "[p32]",
					changingFormula = "1",
				},
				{
					index = "[p33]",
					changingFormula = "505",
				},
				{
					index = "[p34]",
					changingFormula = "1",
				},
				{
					index = "[p35]",
					changingFormula = "0",
				},
				{
					index = "[p36]",
					changingFormula = "1",
				},
				{
					index = "[p37]",
					changingFormula = "0",
				},
				{
					index = "[p38]",
					changingFormula = "1",
				},
				{
					index = "[p39]",
					changingFormula = "250000",
				},
				{
					index = "[p40]",
					changingFormula = "1",
				},
				{
					index = "[p41]",
					changingFormula = "1000",
				},
				{
					index = "[p42]",
					changingFormula = "1",
				},
				{
					index = "[p43]",
					changingFormula = "0",
				},
				{
					index = "[p44]",
					changingFormula = "1",
				},
			},
		},
		{
			index = 23, -- number
			id = 1, -- location [L1]
			type = 2, -- isEmpty
			locX = 1952,
			locY = 609,
		},
		{
			index = 24, -- number
			id = 85, -- location [L85]
			type = 2, -- isEmpty
			locX = 992,
			locY = 567,
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "[p4]*100+32",
				},
			},
		},
		{
			index = 25, -- number
			id = 64, -- location [L64]
			type = 2, -- isEmpty
			locX = 1312,
			locY = 357,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "0",
				},
				{
					index = "[p6]",
					changingFormula = "1",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
			},
		},
		{
			index = 26, -- number
			id = 65, -- location [L65]
			type = 2, -- isEmpty
			locX = 1312,
			locY = 399,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]+0",
				},
				{
					index = "[p50]",
					changingFormula = "1",
				},
			},
		},
		{
			index = 27, -- number
			id = 2, -- location [L2]
			type = 2, -- isEmpty
			locX = 2016,
			locY = 609,
		},
		{
			index = 28, -- number
			id = 4, -- location [L4]
			type = 2, -- isEmpty
			locX = 1952,
			locY = 651,
		},
		{
			index = 29, -- number
			id = 248, -- location [L248]
			type = 2, -- isEmpty
			locX = 1440,
			locY = 231,
		},
		{
			index = 30, -- number
			id = 66, -- location [L66]
			type = 2, -- isEmpty
			locX = 1376,
			locY = 315,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p21]",
				},
				{
					index = "[p6]",
					changingFormula = "[p22]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 31, -- number
			id = 3, -- location [L3]
			type = 2, -- isEmpty
			locX = 2016,
			locY = 651,
		},
		{
			index = 32, -- number
			id = 9, -- location [L9]
			type = 2, -- isEmpty
			locX = 2016,
			locY = 399,
		},
		{
			index = 33, -- number
			id = 14, -- location [L14]
			type = 2, -- isEmpty
			locX = 1120,
			locY = 189,
		},
		{
			index = 34, -- number
			id = 24, -- location [L24]
			type = 2, -- isEmpty
			locX = 2016,
			locY = 735,
		},
		{
			index = 35, -- number
			id = 35, -- location [L35]
			type = 2, -- isEmpty
			locX = 544,
			locY = 357,
		},
		{
			index = 36, -- number
			id = 41, -- location [L41]
			type = 2, -- isEmpty
			locX = 736,
			locY = 357,
		},
		{
			index = 37, -- number
			id = 47, -- location [L47]
			type = 2, -- isEmpty
			locX = 800,
			locY = 441,
		},
		{
			index = 38, -- number
			id = 51, -- location [L51]
			type = 2, -- isEmpty
			locX = 864,
			locY = 357,
		},
		{
			index = 39, -- number
			id = 56, -- location [L56]
			type = 2, -- isEmpty
			locX = 992,
			locY = 441,
		},
		{
			index = 40, -- number
			id = 71, -- location [L71]
			type = 2, -- isEmpty
			locX = 1504,
			locY = 441,
		},
		{
			index = 41, -- number
			id = 91, -- location [L91]
			type = 2, -- isEmpty
			locX = 1248,
			locY = 651,
		},
		{
			index = 42, -- number
			id = 100, -- location [L100]
			type = 2, -- isEmpty
			locX = 1504,
			locY = 693,
		},
		{
			index = 43, -- number
			id = 105, -- location [L105]
			type = 2, -- isEmpty
			locX = 288,
			locY = 903,
		},
		{
			index = 44, -- number
			id = 110, -- location [L110]
			type = 2, -- isEmpty
			locX = 416,
			locY = 861,
		},
		{
			index = 45, -- number
			id = 118, -- location [L118]
			type = 2, -- isEmpty
			locX = 736,
			locY = 861,
		},
		{
			index = 46, -- number
			id = 119, -- location [L119]
			type = 2, -- isEmpty
			locX = 736,
			locY = 903,
		},
		{
			index = 47, -- number
			id = 121, -- location [L121]
			type = 2, -- isEmpty
			locX = 800,
			locY = 861,
		},
		{
			index = 48, -- number
			id = 126, -- location [L126]
			type = 2, -- isEmpty
			locX = 928,
			locY = 861,
		},
		{
			index = 49, -- number
			id = 133, -- location [L133]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 945,
		},
		{
			index = 50, -- number
			id = 142, -- location [L142]
			type = 2, -- isEmpty
			locX = 1312,
			locY = 945,
		},
		{
			index = 51, -- number
			id = 153, -- location [L153]
			type = 2, -- isEmpty
			locX = 416,
			locY = 1197,
		},
		{
			index = 52, -- number
			id = 163, -- location [L163]
			type = 2, -- isEmpty
			locX = 736,
			locY = 1197,
		},
		{
			index = 53, -- number
			id = 171, -- location [L171]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 1113,
		},
		{
			index = 54, -- number
			id = 177, -- location [L177]
			type = 2, -- isEmpty
			locX = 1120,
			locY = 1197,
		},
		{
			index = 55, -- number
			id = 186, -- location [L186]
			type = 2, -- isEmpty
			locX = 1440,
			locY = 1155,
		},
		{
			index = 56, -- number
			id = 196, -- location [L196]
			type = 2, -- isEmpty
			locX = 608,
			locY = 1365,
		},
		{
			index = 57, -- number
			id = 197, -- location [L197]
			type = 2, -- isEmpty
			locX = 608,
			locY = 1407,
		},
		{
			index = 58, -- number
			id = 199, -- location [L199]
			type = 2, -- isEmpty
			locX = 672,
			locY = 1365,
		},
		{
			index = 59, -- number
			id = 205, -- location [L205]
			type = 2, -- isEmpty
			locX = 736,
			locY = 1449,
		},
		{
			index = 60, -- number
			id = 209, -- location [L209]
			type = 2, -- isEmpty
			locX = 800,
			locY = 1365,
		},
		{
			index = 61, -- number
			id = 218, -- location [L218]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 1449,
		},
		{
			index = 62, -- number
			id = 226, -- location [L226]
			type = 2, -- isEmpty
			locX = 1184,
			locY = 1407,
		},
		{
			index = 63, -- number
			id = 231, -- location [L231]
			type = 2, -- isEmpty
			locX = 1312,
			locY = 1365,
		},
		{
			index = 64, -- number
			id = 250, -- location [L250]
			type = 2, -- isEmpty
			locX = 1376,
			locY = 231,
		},
		{
			index = 65, -- number
			id = 259, -- location [L259]
			type = 2, -- isEmpty
			locX = 1504,
			locY = 231,
		},
		{
			index = 66, -- number
			id = 249, -- location [L249]
			type = 0, -- undefined
			locX = 1440,
			locY = 189,
			texts = {
				"<clr>!!! ПЕРЕГРУЗКА !!!<clrEnd>\n",
			},
		},
		{
			index = 67, -- number
			id = 67, -- location [L67]
			type = 2, -- isEmpty
			locX = 1440,
			locY = 315,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p29]",
				},
				{
					index = "[p6]",
					changingFormula = "[p30]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 68, -- number
			id = 10, -- location [L10]
			type = 2, -- isEmpty
			locX = 2016,
			locY = 357,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 69, -- number
			id = 11, -- location [L11]
			type = 2, -- isEmpty
			locX = 1952,
			locY = 399,
		},
		{
			index = 70, -- number
			id = 15, -- location [L15]
			type = 2, -- isEmpty
			locX = 1120,
			locY = 231,
		},
		{
			index = 71, -- number
			id = 25, -- location [L25]
			type = 2, -- isEmpty
			locX = 1952,
			locY = 735,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 72, -- number
			id = 26, -- location [L26]
			type = 2, -- isEmpty
			locX = 1952,
			locY = 693,
		},
		{
			index = 73, -- number
			id = 37, -- location [L37]
			type = 2, -- isEmpty
			locX = 544,
			locY = 441,
		},
		{
			index = 74, -- number
			id = 36, -- location [L36]
			type = 2, -- isEmpty
			locX = 544,
			locY = 399,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 75, -- number
			id = 43, -- location [L43]
			type = 2, -- isEmpty
			locX = 736,
			locY = 441,
		},
		{
			index = 76, -- number
			id = 42, -- location [L42]
			type = 2, -- isEmpty
			locX = 736,
			locY = 399,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 77, -- number
			id = 49, -- location [L49]
			type = 2, -- isEmpty
			locX = 800,
			locY = 525,
		},
		{
			index = 78, -- number
			id = 48, -- location [L48]
			type = 2, -- isEmpty
			locX = 800,
			locY = 483,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 79, -- number
			id = 52, -- location [L52]
			type = 2, -- isEmpty
			locX = 928,
			locY = 315,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p37]",
				},
				{
					index = "[p6]",
					changingFormula = "[p38]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 80, -- number
			id = 58, -- location [L58]
			type = 2, -- isEmpty
			locX = 992,
			locY = 525,
		},
		{
			index = 81, -- number
			id = 57, -- location [L57]
			type = 2, -- isEmpty
			locX = 992,
			locY = 483,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 82, -- number
			id = 73, -- location [L73]
			type = 2, -- isEmpty
			locX = 1504,
			locY = 525,
		},
		{
			index = 83, -- number
			id = 72, -- location [L72]
			type = 2, -- isEmpty
			locX = 1504,
			locY = 483,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 84, -- number
			id = 93, -- location [L93]
			type = 2, -- isEmpty
			locX = 1248,
			locY = 735,
		},
		{
			index = 85, -- number
			id = 92, -- location [L92]
			type = 2, -- isEmpty
			locX = 1248,
			locY = 693,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 86, -- number
			id = 102, -- location [L102]
			type = 2, -- isEmpty
			locX = 1504,
			locY = 777,
		},
		{
			index = 87, -- number
			id = 101, -- location [L101]
			type = 2, -- isEmpty
			locX = 1504,
			locY = 735,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 88, -- number
			id = 107, -- location [L107]
			type = 2, -- isEmpty
			locX = 288,
			locY = 987,
		},
		{
			index = 89, -- number
			id = 106, -- location [L106]
			type = 2, -- isEmpty
			locX = 288,
			locY = 945,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 90, -- number
			id = 112, -- location [L112]
			type = 2, -- isEmpty
			locX = 416,
			locY = 945,
		},
		{
			index = 91, -- number
			id = 111, -- location [L111]
			type = 2, -- isEmpty
			locX = 416,
			locY = 903,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 92, -- number
			id = 17, -- location [L17]
			type = 2, -- isEmpty
			locX = 1952,
			locY = 819,
		},
		{
			index = 93, -- number
			id = 120, -- location [L120]
			type = 2, -- isEmpty
			locX = 800,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p7]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 94, -- number
			id = 123, -- location [L123]
			type = 2, -- isEmpty
			locX = 800,
			locY = 945,
		},
		{
			index = 95, -- number
			id = 122, -- location [L122]
			type = 2, -- isEmpty
			locX = 800,
			locY = 903,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 96, -- number
			id = 128, -- location [L128]
			type = 2, -- isEmpty
			locX = 928,
			locY = 945,
		},
		{
			index = 97, -- number
			id = 127, -- location [L127]
			type = 2, -- isEmpty
			locX = 928,
			locY = 903,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 98, -- number
			id = 135, -- location [L135]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 1029,
		},
		{
			index = 99, -- number
			id = 134, -- location [L134]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 987,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 100, -- number
			id = 144, -- location [L144]
			type = 2, -- isEmpty
			locX = 1312,
			locY = 1029,
		},
		{
			index = 101, -- number
			id = 143, -- location [L143]
			type = 2, -- isEmpty
			locX = 1312,
			locY = 987,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 102, -- number
			id = 155, -- location [L155]
			type = 2, -- isEmpty
			locX = 416,
			locY = 1281,
		},
		{
			index = 103, -- number
			id = 154, -- location [L154]
			type = 2, -- isEmpty
			locX = 416,
			locY = 1239,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 104, -- number
			id = 165, -- location [L165]
			type = 2, -- isEmpty
			locX = 736,
			locY = 1281,
		},
		{
			index = 105, -- number
			id = 164, -- location [L164]
			type = 2, -- isEmpty
			locX = 736,
			locY = 1239,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 106, -- number
			id = 173, -- location [L173]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 1197,
		},
		{
			index = 107, -- number
			id = 172, -- location [L172]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 1155,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 108, -- number
			id = 179, -- location [L179]
			type = 2, -- isEmpty
			locX = 1120,
			locY = 1281,
		},
		{
			index = 109, -- number
			id = 178, -- location [L178]
			type = 2, -- isEmpty
			locX = 1120,
			locY = 1239,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 110, -- number
			id = 188, -- location [L188]
			type = 2, -- isEmpty
			locX = 1440,
			locY = 1239,
		},
		{
			index = 111, -- number
			id = 187, -- location [L187]
			type = 2, -- isEmpty
			locX = 1440,
			locY = 1197,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 112, -- number
			id = 16, -- location [L16]
			type = 2, -- isEmpty
			locX = 1952,
			locY = 777,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "90*[p6]-[p5]",
				},
			},
		},
		{
			index = 113, -- number
			id = 198, -- location [L198]
			type = 2, -- isEmpty
			locX = 672,
			locY = 1323,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p7]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 114, -- number
			id = 201, -- location [L201]
			type = 2, -- isEmpty
			locX = 672,
			locY = 1449,
		},
		{
			index = 115, -- number
			id = 200, -- location [L200]
			type = 2, -- isEmpty
			locX = 672,
			locY = 1407,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 116, -- number
			id = 207, -- location [L207]
			type = 2, -- isEmpty
			locX = 736,
			locY = 1533,
		},
		{
			index = 117, -- number
			id = 206, -- location [L206]
			type = 2, -- isEmpty
			locX = 736,
			locY = 1491,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 118, -- number
			id = 211, -- location [L211]
			type = 2, -- isEmpty
			locX = 800,
			locY = 1449,
		},
		{
			index = 119, -- number
			id = 210, -- location [L210]
			type = 2, -- isEmpty
			locX = 800,
			locY = 1407,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 120, -- number
			id = 220, -- location [L220]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 1533,
		},
		{
			index = 121, -- number
			id = 219, -- location [L219]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 1491,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 122, -- number
			id = 228, -- location [L228]
			type = 2, -- isEmpty
			locX = 1184,
			locY = 1491,
		},
		{
			index = 123, -- number
			id = 227, -- location [L227]
			type = 2, -- isEmpty
			locX = 1184,
			locY = 1449,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 124, -- number
			id = 233, -- location [L233]
			type = 2, -- isEmpty
			locX = 1312,
			locY = 1449,
		},
		{
			index = 125, -- number
			id = 232, -- location [L232]
			type = 2, -- isEmpty
			locX = 1312,
			locY = 1407,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 126, -- number
			id = 251, -- location [L251]
			type = 0, -- undefined
			locX = 1248,
			locY = 189,
			texts = {
				"<fix> Высота: {[p5] div [p6]}<clr>.<clrEnd>{((([p5]*100) div [p6]) mod 100)*(1-2*([p5]<0))} м</fix>\n<fix> Запас топлива: {[p7] div [p8]}<clr>.<clrEnd>{((([p7]*100) div [p8]) mod 100)*(1-2*([p7]<0))} кг</fix>\n<fix> Вертикальная скорость: {[p37] div [p38]}<clr>.<clrEnd>{((([p37]*100) div [p38]) mod 100)*(1-2*([p37]<0))} м/с</fix>\n<fix> -----------------------------</fix>\n<fix> Расход топлива: [p53] кг</fix>\n<fix> Время: [p54] с</fix>\n<fix> [d55]</fix>\n\n<clr>!!! Поздравляем с успешным прилунением !!!<clrEnd>\n",
			},
			paramsChanges = { -- amount: 56
				{
					index = "[p51]",
					changingFormula = "[p51] + 1",
				},
			},
		},
		{
			index = 127, -- number
			id = 253, -- location [L253]
			type = 0, -- undefined
			locX = 1632,
			locY = 231,
			texts = {
				"<fix> Высота: {[p5] div [p6]}<clr>.<clrEnd>{((([p5]*100) div [p6]) mod 100)*(1-2*([p5]<0))} м</fix>\n<fix> Запас топлива: {[p7] div [p8]}<clr>.<clrEnd>{((([p7]*100) div [p8]) mod 100)*(1-2*([p7]<0))} кг</fix>\n<fix> Вертикальная скорость: {[p37] div [p38]}<clr>.<clrEnd>{((([p37]*100) div [p38]) mod 100)*(1-2*([p37]<0))} м/с</fix>\n<fix> -----------------------------</fix>\n<fix> Расход топлива: [p53] кг</fix>\n<fix> Время: [p54] с</fix>\n<fix> [d55]</fix>\n",
			},
		},
		{
			index = 128, -- number
			id = 260, -- location [L260]
			type = 3, -- isSuccess
			locX = 1568,
			locY = 273,
			texts = {
				"<fix> Высота: {[p5] div [p6]}<clr>.<clrEnd>{((([p5]*100) div [p6]) mod 100)*(1-2*([p5]<0))} м</fix>\n<fix> Запас топлива: {[p7] div [p8]}<clr>.<clrEnd>{((([p7]*100) div [p8]) mod 100)*(1-2*([p7]<0))} кг</fix>\n<fix> Вертикальная скорость: {[p37] div [p38]}<clr>.<clrEnd>{((([p37]*100) div [p38]) mod 100)*(1-2*([p37]<0))} м/с</fix>\n<fix> Горизонтальная скорость: {[p15] div [p16]}<clr>.<clrEnd>{((([p15]*100) div [p16]) mod 100)*(1-2*([p15]<0))} м/с</fix>\n<fix> Расстояние до цели: {[p39] div [p40]}<clr>.<clrEnd>{((([p39]*100) div [p40]) mod 100)*(1-2*([p39]<0))} км</fix>\n<fix> -----------------------------</fix>\n<fix> Расход топлива: [p53] кг</fix>\n<fix> Время: [p54] с</fix>\n<fix> Угол: [p55] г</fix>\n\nВот так я успешно приземлился в Море Спокойствия. \n\nС этого небольшого перелёта началась наша знаменитая эпопея. Перелёт Кон-Тики с Луны на Землю. Нам предстояло многое - стыковка с орбитальной станцией, выход в точку либрации, вход в атмосферу и успешное приводнение в Атлантическом океане...\n\nНо это уже другая история.\n",
			},
			media = {
				{
					img = "lunolet_4.jpg",
				},
			},
		},
		{
			index = 129, -- number
			id = 261, -- location [L261]
			type = 4, -- isFaily
			locX = 1568,
			locY = 231,
			texts = {
				"<fix> Высота: {[p5] div [p6]}<clr>.<clrEnd>{((([p5]*100) div [p6]) mod 100)*(1-2*([p5]<0))} м</fix>\n<fix> Запас топлива: {[p7] div [p8]}<clr>.<clrEnd>{((([p7]*100) div [p8]) mod 100)*(1-2*([p7]<0))} кг</fix>\n<fix> Вертикальная скорость: {[p37] div [p38]}<clr>.<clrEnd>{((([p37]*100) div [p38]) mod 100)*(1-2*([p37]<0))} м/с</fix>\n<fix> Горизонтальная скорость: {[p15] div [p16]}<clr>.<clrEnd>{((([p15]*100) div [p16]) mod 100)*(1-2*([p15]<0))} м/с</fix>\n<fix> Расстояние до цели: {[p39] div [p40]}<clr>.<clrEnd>{((([p39]*100) div [p40]) mod 100)*(1-2*([p39]<0))} км</fix>\n<fix> -----------------------------</fix>\n<fix> Расход топлива: [p53] кг</fix>\n<fix> Время: [p54] с</fix>\n<fix> Угол: [p55] г</fix>\n\nНе представляю, как это могло получиться. Прилунился я вполне удачно, но не совсем там где планировалось.\nКоршунов много и с выражением ругался. В результате, меня спасли до того как кончился кислород, Коршунов перегнал корабль сам и полетел один.\n\nОб успешном завершении рейса Кон-Тики я узнал из газет. А в отпуск на Землю полетел как и все, на лайнере.\nСо стюардессами, водой и конфетами...\n",
			},
			media = {
				{
					img = "lunolet_7.jpg",
				},
			},
		},
		{
			index = 130, -- number
			id = 262, -- location [L262]
			type = 4, -- isFaily
			locX = 1568,
			locY = 189,
			texts = {
				"<fix> Высота: {[p5] div [p6]}<clr>.<clrEnd>{((([p5]*100) div [p6]) mod 100)*(1-2*([p5]<0))} м</fix>\n<fix> Запас топлива: {[p7] div [p8]}<clr>.<clrEnd>{((([p7]*100) div [p8]) mod 100)*(1-2*([p7]<0))} кг</fix>\n<fix> Вертикальная скорость: {[p37] div [p38]}<clr>.<clrEnd>{((([p37]*100) div [p38]) mod 100)*(1-2*([p37]<0))} м/с</fix>\n<fix> Горизонтальная скорость: {[p15] div [p16]}<clr>.<clrEnd>{((([p15]*100) div [p16]) mod 100)*(1-2*([p15]<0))} м/с</fix>\n<fix> Расстояние до цели: {[p39] div [p40]}<clr>.<clrEnd>{((([p39]*100) div [p40]) mod 100)*(1-2*([p39]<0))} км</fix>\n<fix> -----------------------------</fix>\n<fix> Расход топлива: [p53] кг</fix>\n<fix> Время: [p54] с</fix>\n<fix> Угол: [p55] г</fix>\n\nВот так, не начавшись, завершилась эта история. \n\nМне удалось выпрыгнуть в последний момент, но аппарат разбился вдребезги.\n\nНа Землю мы полетели на лайнере. Коршунов со мной не разговаривал.\n",
			},
			media = {
				{
					img = "lunolet_7.jpg",
				},
			},
		},
		{
			index = 131, -- number
			id = 263, -- location [L263]
			type = 0, -- undefined
			locX = 1504,
			locY = 273,
			texts = {
				"<fix> Высота: {[p5] div [p6]}<clr>.<clrEnd>{((([p5]*100) div [p6]) mod 100)*(1-2*([p5]<0))} м</fix>\n<fix> Запас топлива: {[p7] div [p8]}<clr>.<clrEnd>{((([p7]*100) div [p8]) mod 100)*(1-2*([p7]<0))} кг</fix>\n<fix> Вертикальная скорость: {[p37] div [p38]}<clr>.<clrEnd>{((([p37]*100) div [p38]) mod 100)*(1-2*([p37]<0))} м/с</fix>\n<fix> Горизонтальная скорость: {[p15] div [p16]}<clr>.<clrEnd>{((([p15]*100) div [p16]) mod 100)*(1-2*([p15]<0))} м/с</fix>\n<fix> Расстояние до цели: {[p39] div [p40]}<clr>.<clrEnd>{((([p39]*100) div [p40]) mod 100)*(1-2*([p39]<0))} км</fix>\n<fix> -----------------------------</fix>\n<fix> Расход топлива: [p53] кг</fix>\n<fix> Время: [p54] с</fix>\n<fix> Угол: [p55] г</fix>\n",
			},
		},
		{
			index = 132, -- number
			id = 235, -- location [L235]
			type = 2, -- isEmpty
			locX = 1504,
			locY = 189,
		},
		{
			index = 133, -- number
			id = 68, -- location [L68]
			type = 2, -- isEmpty
			locX = 1504,
			locY = 315,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 134, -- number
			id = 38, -- location [L38]
			type = 2, -- isEmpty
			locX = 608,
			locY = 315,
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "[p4]*100+7",
				},
			},
		},
		{
			index = 135, -- number
			id = 44, -- location [L44]
			type = 2, -- isEmpty
			locX = 800,
			locY = 315,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 136, -- number
			id = 50, -- location [L50]
			type = 2, -- isEmpty
			locX = 864,
			locY = 315,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 137, -- number
			id = 53, -- location [L53]
			type = 2, -- isEmpty
			locX = 992,
			locY = 315,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 138, -- number
			id = 59, -- location [L59]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 315,
		},
		{
			index = 139, -- number
			id = 74, -- location [L74]
			type = 2, -- isEmpty
			locX = 288,
			locY = 567,
		},
		{
			index = 140, -- number
			id = 94, -- location [L94]
			type = 2, -- isEmpty
			locX = 1312,
			locY = 567,
			paramsChanges = { -- amount: 56
				{
					index = "[p31]",
					changingFormula = "[p5]",
				},
				{
					index = "[p32]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 141, -- number
			id = 103, -- location [L103]
			type = 2, -- isEmpty
			locX = 288,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 142, -- number
			id = 108, -- location [L108]
			type = 2, -- isEmpty
			locX = 352,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p27]",
				},
				{
					index = "[p6]",
					changingFormula = "[p28]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 143, -- number
			id = 113, -- location [L113]
			type = 2, -- isEmpty
			locX = 480,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p21]",
					changingFormula = "[p5]",
				},
				{
					index = "[p22]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 144, -- number
			id = 18, -- location [L18]
			type = 2, -- isEmpty
			locX = 2016,
			locY = 777,
		},
		{
			index = 145, -- number
			id = 19, -- location [L19]
			type = 2, -- isEmpty
			locX = 2016,
			locY = 861,
		},
		{
			index = 146, -- number
			id = 124, -- location [L124]
			type = 2, -- isEmpty
			locX = 864,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p19]",
				},
				{
					index = "[p6]",
					changingFormula = "[p20]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 147, -- number
			id = 129, -- location [L129]
			type = 2, -- isEmpty
			locX = 992,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p15]",
				},
				{
					index = "[p6]",
					changingFormula = "[p16]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 148, -- number
			id = 136, -- location [L136]
			type = 2, -- isEmpty
			locX = 1120,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p15]",
					changingFormula = "[p5]",
				},
				{
					index = "[p16]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 149, -- number
			id = 145, -- location [L145]
			type = 2, -- isEmpty
			locX = 1376,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p39]",
					changingFormula = "[p5]",
				},
				{
					index = "[p40]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 150, -- number
			id = 156, -- location [L156]
			type = 2, -- isEmpty
			locX = 480,
			locY = 1071,
			paramsChanges = { -- amount: 56
				{
					index = "[p37]",
					changingFormula = "[p5]",
				},
				{
					index = "[p38]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 151, -- number
			id = 166, -- location [L166]
			type = 2, -- isEmpty
			locX = 800,
			locY = 1071,
			paramsChanges = { -- amount: 56
				{
					index = "[p35]",
					changingFormula = "[p5]",
				},
				{
					index = "[p36]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 152, -- number
			id = 174, -- location [L174]
			type = 2, -- isEmpty
			locX = 1120,
			locY = 1071,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 153, -- number
			id = 180, -- location [L180]
			type = 2, -- isEmpty
			locX = 1184,
			locY = 1071,
			paramsChanges = { -- amount: 56
				{
					index = "[p41]",
					changingFormula = "[p5]",
				},
				{
					index = "[p42]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 154, -- number
			id = 189, -- location [L189]
			type = 2, -- isEmpty
			locX = 1504,
			locY = 1071,
			paramsChanges = { -- amount: 56
				{
					index = "[p19]",
					changingFormula = "[p5]",
				},
				{
					index = "[p20]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 155, -- number
			id = 202, -- location [L202]
			type = 2, -- isEmpty
			locX = 736,
			locY = 1323,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 156, -- number
			id = 208, -- location [L208]
			type = 2, -- isEmpty
			locX = 800,
			locY = 1323,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p7]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 157, -- number
			id = 212, -- location [L212]
			type = 2, -- isEmpty
			locX = 864,
			locY = 1323,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p37]",
				},
				{
					index = "[p6]",
					changingFormula = "[p38]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 158, -- number
			id = 221, -- location [L221]
			type = 2, -- isEmpty
			locX = 1120,
			locY = 1323,
		},
		{
			index = 159, -- number
			id = 229, -- location [L229]
			type = 2, -- isEmpty
			locX = 1248,
			locY = 1323,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p19]",
				},
				{
					index = "[p6]",
					changingFormula = "[p20]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 160, -- number
			id = 234, -- location [L234]
			type = 2, -- isEmpty
			locX = 1376,
			locY = 1323,
		},
		{
			index = 161, -- number
			id = 255, -- location [L255]
			type = 0, -- undefined
			locX = 1632,
			locY = 189,
			texts = {
				"<fix> Высота: {[p5] div [p6]}<clr>.<clrEnd>{((([p5]*100) div [p6]) mod 100)*(1-2*([p5]<0))} м</fix>\n<fix> Запас топлива: {[p7] div [p8]}<clr>.<clrEnd>{((([p7]*100) div [p8]) mod 100)*(1-2*([p7]<0))} кг</fix>\n<fix> Вертикальная скорость: {[p37] div [p38]}<clr>.<clrEnd>{((([p37]*100) div [p38]) mod 100)*(1-2*([p37]<0))} м/с</fix>\n<fix> -----------------------------</fix>\n<fix> Расход топлива: [p53] кг</fix>\n<fix> Время: [p54] с</fix>\n<fix> [d55]</fix>\n",
			},
		},
		{
			index = 162, -- number
			id = 257, -- location [L257]
			type = 0, -- undefined
			locX = 1696,
			locY = 189,
			texts = {
				"<fix> Высота: {[p5] div [p6]}<clr>.<clrEnd>{((([p5]*100) div [p6]) mod 100)*(1-2*([p5]<0))} м</fix>\n<fix> Запас топлива: {[p7] div [p8]}<clr>.<clrEnd>{((([p7]*100) div [p8]) mod 100)*(1-2*([p7]<0))} кг</fix>\n<fix> Вертикальная скорость: {[p37] div [p38]}<clr>.<clrEnd>{((([p37]*100) div [p38]) mod 100)*(1-2*([p37]<0))} м/с</fix>\n<fix> -----------------------------</fix>\n<fix> Расход топлива: [p53] кг</fix>\n<fix> Время: [p54] с</fix>\n<fix> [d55]</fix>\n",
			},
		},
		{
			index = 163, -- number
			id = 254, -- location [L254]
			type = 2, -- isEmpty
			locX = 1696,
			locY = 231,
		},
		{
			index = 164, -- number
			id = 266, -- location [L266]
			type = 0, -- undefined
			locX = 1312,
			locY = 231,
			texts = {
				"<fix> Высота: {[p5] div [p6]}<clr>.<clrEnd>{((([p5]*100) div [p6]) mod 100)*(1-2*([p5]<0))} м</fix>\n<fix> Запас топлива: {[p7] div [p8]}<clr>.<clrEnd>{((([p7]*100) div [p8]) mod 100)*(1-2*([p7]<0))} кг</fix>\n<fix> Вертикальная скорость: {[p37] div [p38]}<clr>.<clrEnd>{((([p37]*100) div [p38]) mod 100)*(1-2*([p37]<0))} м/с</fix>\n<fix> Горизонтальная скорость: {[p15] div [p16]}<clr>.<clrEnd>{((([p15]*100) div [p16]) mod 100)*(1-2*([p15]<0))} м/с</fix>\n<fix> Расстояние до цели: {[p39] div [p40]}<clr>.<clrEnd>{((([p39]*100) div [p40]) mod 100)*(1-2*([p39]<0))} км</fix>\n<fix> -----------------------------</fix>\n<fix> Расход топлива: [p53] кг</fix>\n<fix> Время: [p54] с</fix>\n<fix> Угол: [p55] г</fix>\n",
			},
		},
		{
			index = 165, -- number
			id = 268, -- location [L268]
			type = 0, -- undefined
			locX = 1312,
			locY = 189,
			texts = {
				"<fix> Высота: {[p5] div [p6]}<clr>.<clrEnd>{((([p5]*100) div [p6]) mod 100)*(1-2*([p5]<0))} м</fix>\n<fix> Запас топлива: {[p7] div [p8]}<clr>.<clrEnd>{((([p7]*100) div [p8]) mod 100)*(1-2*([p7]<0))} кг</fix>\n<fix> Вертикальная скорость: {[p37] div [p38]}<clr>.<clrEnd>{((([p37]*100) div [p38]) mod 100)*(1-2*([p37]<0))} м/с</fix>\n<fix> Горизонтальная скорость: {[p15] div [p16]}<clr>.<clrEnd>{((([p15]*100) div [p16]) mod 100)*(1-2*([p15]<0))} м/с</fix>\n<fix> Расстояние до цели: {[p39] div [p40]}<clr>.<clrEnd>{((([p39]*100) div [p40]) mod 100)*(1-2*([p39]<0))} км</fix>\n<fix> -----------------------------</fix>\n<fix> Расход топлива: [p53] кг</fix>\n<fix> Время: [p54] с</fix>\n<fix> Угол: [p55] г</fix>\n",
			},
		},
		{
			index = 166, -- number
			id = 265, -- location [L265]
			type = 0, -- undefined
			locX = 1312,
			locY = 273,
			texts = {
				"<fix> Высота: {[p5] div [p6]}<clr>.<clrEnd>{((([p5]*100) div [p6]) mod 100)*(1-2*([p5]<0))} м</fix>\n<fix> Запас топлива: {[p7] div [p8]}<clr>.<clrEnd>{((([p7]*100) div [p8]) mod 100)*(1-2*([p7]<0))} кг</fix>\n<fix> Вертикальная скорость: {[p37] div [p38]}<clr>.<clrEnd>{((([p37]*100) div [p38]) mod 100)*(1-2*([p37]<0))} м/с</fix>\n<fix> Горизонтальная скорость: {[p15] div [p16]}<clr>.<clrEnd>{((([p15]*100) div [p16]) mod 100)*(1-2*([p15]<0))} м/с</fix>\n<fix> Расстояние до цели: {[p39] div [p40]}<clr>.<clrEnd>{((([p39]*100) div [p40]) mod 100)*(1-2*([p39]<0))} км</fix>\n<fix> -----------------------------</fix>\n<fix> Расход топлива: [p53] кг</fix>\n<fix> Время: [p54] с</fix>\n<fix> Угол: [p55] г</fix>\n",
			},
		},
		{
			index = 167, -- number
			id = 82, -- location [L82]
			type = 2, -- isEmpty
			locX = 800,
			locY = 567,
		},
		{
			index = 168, -- number
			id = 86, -- location [L86]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 567,
			paramsChanges = { -- amount: 56
				{
					index = "[p17]",
					changingFormula = "[p5]",
				},
				{
					index = "[p18]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 169, -- number
			id = 70, -- location [L70]
			type = 2, -- isEmpty
			locX = 1504,
			locY = 399,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p7]-[p5]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
			},
		},
		{
			index = 170, -- number
			id = 69, -- location [L69]
			type = 2, -- isEmpty
			locX = 1504,
			locY = 357,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p8]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p7]*[p6]",
				},
				{
					index = "[p8]",
					changingFormula = "[p8]*[p6]",
				},
			},
		},
		{
			index = 171, -- number
			id = 39, -- location [L39]
			type = 2, -- isEmpty
			locX = 672,
			locY = 315,
		},
		{
			index = 172, -- number
			id = 46, -- location [L46]
			type = 2, -- isEmpty
			locX = 800,
			locY = 399,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]+[p7]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
			},
		},
		{
			index = 173, -- number
			id = 45, -- location [L45]
			type = 2, -- isEmpty
			locX = 800,
			locY = 357,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p8]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p7]*[p6]",
				},
				{
					index = "[p8]",
					changingFormula = "[p8]*[p6]",
				},
			},
		},
		{
			index = 174, -- number
			id = 27, -- location [L27]
			type = 4, -- isFaily
			locX = 1952,
			locY = 945,
			texts = {
				"ЕГГОГ\n",
			},
			media = {
				{
					img = "lunolet_7.jpg",
				},
			},
		},
		{
			index = 175, -- number
			id = 5, -- location [L5]
			type = 2, -- isEmpty
			locX = 1952,
			locY = 441,
			paramsChanges = { -- amount: 56
				{
					index = "[p45]",
					changingFormula = "[p5] div [p6]",
				},
				{
					index = "[p46]",
					changingFormula = "1",
				},
				{
					index = "[p47]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 176, -- number
			id = 55, -- location [L55]
			type = 2, -- isEmpty
			locX = 992,
			locY = 399,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p7]-[p5]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
			},
		},
		{
			index = 177, -- number
			id = 54, -- location [L54]
			type = 2, -- isEmpty
			locX = 992,
			locY = 357,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p8]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p7]*[p6]",
				},
				{
					index = "[p8]",
					changingFormula = "[p8]*[p6]",
				},
			},
		},
		{
			index = 178, -- number
			id = 60, -- location [L60]
			type = 2, -- isEmpty
			locX = 1120,
			locY = 315,
		},
		{
			index = 179, -- number
			id = 76, -- location [L76]
			type = 2, -- isEmpty
			locX = 416,
			locY = 567,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p41]",
				},
				{
					index = "[p6]",
					changingFormula = "[p42]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 180, -- number
			id = 75, -- location [L75]
			type = 2, -- isEmpty
			locX = 352,
			locY = 567,
		},
		{
			index = 181, -- number
			id = 95, -- location [L95]
			type = 2, -- isEmpty
			locX = 1376,
			locY = 567,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p25]",
				},
				{
					index = "[p6]",
					changingFormula = "[p26]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 182, -- number
			id = 104, -- location [L104]
			type = 2, -- isEmpty
			locX = 288,
			locY = 861,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p6]*[p7]",
				},
				{
					index = "[p6]",
					changingFormula = "[p5]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
			},
		},
		{
			index = 183, -- number
			id = 109, -- location [L109]
			type = 2, -- isEmpty
			locX = 416,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p7]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 184, -- number
			id = 114, -- location [L114]
			type = 2, -- isEmpty
			locX = 544,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p39]",
				},
				{
					index = "[p6]",
					changingFormula = "[p40]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 185, -- number
			id = 20, -- location [L20]
			type = 2, -- isEmpty
			locX = 1952,
			locY = 861,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "(180*[p6]-[p5])*[p5]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p6]",
				},
			},
		},
		{
			index = 186, -- number
			id = 125, -- location [L125]
			type = 2, -- isEmpty
			locX = 928,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p7]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 187, -- number
			id = 130, -- location [L130]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 188, -- number
			id = 137, -- location [L137]
			type = 2, -- isEmpty
			locX = 1184,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "[p4]*100+56",
				},
			},
		},
		{
			index = 189, -- number
			id = 146, -- location [L146]
			type = 2, -- isEmpty
			locX = 1440,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p19]",
				},
				{
					index = "[p6]",
					changingFormula = "[p20]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 190, -- number
			id = 157, -- location [L157]
			type = 2, -- isEmpty
			locX = 544,
			locY = 1071,
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "[p4]*100+66",
				},
			},
		},
		{
			index = 191, -- number
			id = 167, -- location [L167]
			type = 2, -- isEmpty
			locX = 864,
			locY = 1071,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p41]",
				},
				{
					index = "[p6]",
					changingFormula = "[p42]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 192, -- number
			id = 176, -- location [L176]
			type = 2, -- isEmpty
			locX = 1120,
			locY = 1155,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p7]-[p5]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
			},
		},
		{
			index = 193, -- number
			id = 175, -- location [L175]
			type = 2, -- isEmpty
			locX = 1120,
			locY = 1113,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p8]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p7]*[p6]",
				},
				{
					index = "[p8]",
					changingFormula = "[p8]*[p6]",
				},
			},
		},
		{
			index = 194, -- number
			id = 181, -- location [L181]
			type = 2, -- isEmpty
			locX = 1248,
			locY = 1071,
		},
		{
			index = 195, -- number
			id = 190, -- location [L190]
			type = 2, -- isEmpty
			locX = 288,
			locY = 1323,
		},
		{
			index = 196, -- number
			id = 204, -- location [L204]
			type = 2, -- isEmpty
			locX = 736,
			locY = 1407,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p7]-[p5]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
			},
		},
		{
			index = 197, -- number
			id = 203, -- location [L203]
			type = 2, -- isEmpty
			locX = 736,
			locY = 1365,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p8]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p7]*[p6]",
				},
				{
					index = "[p8]",
					changingFormula = "[p8]*[p6]",
				},
			},
		},
		{
			index = 198, -- number
			id = 213, -- location [L213]
			type = 2, -- isEmpty
			locX = 928,
			locY = 1323,
		},
		{
			index = 199, -- number
			id = 222, -- location [L222]
			type = 2, -- isEmpty
			locX = 1120,
			locY = 1365,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "0",
				},
				{
					index = "[p6]",
					changingFormula = "1",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
			},
		},
		{
			index = 200, -- number
			id = 223, -- location [L223]
			type = 2, -- isEmpty
			locX = 1120,
			locY = 1407,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]+2",
				},
				{
					index = "[p50]",
					changingFormula = "1",
				},
			},
		},
		{
			index = 201, -- number
			id = 230, -- location [L230]
			type = 2, -- isEmpty
			locX = 1312,
			locY = 1323,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p7]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 202, -- number
			id = 40, -- location [L40]
			type = 2, -- isEmpty
			locX = 736,
			locY = 315,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p5]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p6]",
				},
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 203, -- number
			id = 139, -- location [L139]
			type = 2, -- isEmpty
			locX = 1312,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 204, -- number
			id = 150, -- location [L150]
			type = 2, -- isEmpty
			locX = 416,
			locY = 1071,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 205, -- number
			id = 159, -- location [L159]
			type = 2, -- isEmpty
			locX = 672,
			locY = 1071,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p35]",
				},
				{
					index = "[p6]",
					changingFormula = "[p36]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 206, -- number
			id = 267, -- location [L267]
			type = 2, -- isEmpty
			locX = 1312,
			locY = 273,
		},
		{
			index = 207, -- number
			id = 83, -- location [L83]
			type = 2, -- isEmpty
			locX = 864,
			locY = 567,
		},
		{
			index = 208, -- number
			id = 87, -- location [L87]
			type = 2, -- isEmpty
			locX = 1120,
			locY = 567,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p7]",
				},
				{
					index = "[p6]",
					changingFormula = "[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
				{
					index = "[p11]",
					changingFormula = "[p5]",
				},
				{
					index = "[p12]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 209, -- number
			id = 192, -- location [L192]
			type = 2, -- isEmpty
			locX = 416,
			locY = 1323,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p23]",
				},
				{
					index = "[p6]",
					changingFormula = "[p24]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 210, -- number
			id = 6, -- location [L6]
			type = 2, -- isEmpty
			locX = 2016,
			locY = 441,
		},
		{
			index = 211, -- number
			id = 184, -- location [L184]
			type = 2, -- isEmpty
			locX = 1440,
			locY = 1071,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 212, -- number
			id = 77, -- location [L77]
			type = 2, -- isEmpty
			locX = 480,
			locY = 567,
		},
		{
			index = 213, -- number
			id = 80, -- location [L80]
			type = 2, -- isEmpty
			locX = 672,
			locY = 567,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p33]",
				},
				{
					index = "[p6]",
					changingFormula = "[p34]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 214, -- number
			id = 96, -- location [L96]
			type = 2, -- isEmpty
			locX = 1440,
			locY = 567,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p41]",
				},
				{
					index = "[p6]",
					changingFormula = "[p42]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 215, -- number
			id = 115, -- location [L115]
			type = 2, -- isEmpty
			locX = 608,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p21]",
				},
				{
					index = "[p6]",
					changingFormula = "[p22]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 216, -- number
			id = 21, -- location [L21]
			type = 2, -- isEmpty
			locX = 1952,
			locY = 903,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*4",
				},
				{
					index = "[p45]",
					changingFormula = "40500*[p6]-[p5]",
				},
				{
					index = "[p46]",
					changingFormula = "[p6]",
				},
			},
		},
		{
			index = 217, -- number
			id = 132, -- location [L132]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 903,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]+[p7]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
			},
		},
		{
			index = 218, -- number
			id = 131, -- location [L131]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 861,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p8]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p7]*[p6]",
				},
				{
					index = "[p8]",
					changingFormula = "[p8]*[p6]",
				},
			},
		},
		{
			index = 219, -- number
			id = 138, -- location [L138]
			type = 2, -- isEmpty
			locX = 1248,
			locY = 819,
		},
		{
			index = 220, -- number
			id = 147, -- location [L147]
			type = 2, -- isEmpty
			locX = 1504,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "-[p5]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 221, -- number
			id = 158, -- location [L158]
			type = 2, -- isEmpty
			locX = 608,
			locY = 1071,
		},
		{
			index = 222, -- number
			id = 168, -- location [L168]
			type = 2, -- isEmpty
			locX = 928,
			locY = 1071,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p31]",
				},
				{
					index = "[p6]",
					changingFormula = "[p32]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 223, -- number
			id = 183, -- location [L183]
			type = 2, -- isEmpty
			locX = 1376,
			locY = 1071,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p31]",
				},
				{
					index = "[p6]",
					changingFormula = "[p32]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 224, -- number
			id = 182, -- location [L182]
			type = 2, -- isEmpty
			locX = 1312,
			locY = 1071,
		},
		{
			index = 225, -- number
			id = 191, -- location [L191]
			type = 2, -- isEmpty
			locX = 352,
			locY = 1323,
		},
		{
			index = 226, -- number
			id = 224, -- location [L224]
			type = 2, -- isEmpty
			locX = 1184,
			locY = 1323,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 227, -- number
			id = 141, -- location [L141]
			type = 2, -- isEmpty
			locX = 1312,
			locY = 903,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p7]-[p5]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
			},
		},
		{
			index = 228, -- number
			id = 140, -- location [L140]
			type = 2, -- isEmpty
			locX = 1312,
			locY = 861,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p8]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p7]*[p6]",
				},
				{
					index = "[p8]",
					changingFormula = "[p8]*[p6]",
				},
			},
		},
		{
			index = 229, -- number
			id = 152, -- location [L152]
			type = 2, -- isEmpty
			locX = 416,
			locY = 1155,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]+[p7]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
			},
		},
		{
			index = 230, -- number
			id = 151, -- location [L151]
			type = 2, -- isEmpty
			locX = 416,
			locY = 1113,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p8]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p7]*[p6]",
				},
				{
					index = "[p8]",
					changingFormula = "[p8]*[p6]",
				},
			},
		},
		{
			index = 231, -- number
			id = 160, -- location [L160]
			type = 2, -- isEmpty
			locX = 736,
			locY = 1071,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 232, -- number
			id = 88, -- location [L88]
			type = 2, -- isEmpty
			locX = 1184,
			locY = 567,
			paramsChanges = { -- amount: 56
				{
					index = "[p19]",
					changingFormula = "[p5]",
				},
				{
					index = "[p20]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 233, -- number
			id = 193, -- location [L193]
			type = 2, -- isEmpty
			locX = 480,
			locY = 1323,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p21]",
				},
				{
					index = "[p6]",
					changingFormula = "[p22]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 234, -- number
			id = 7, -- location [L7]
			type = 2, -- isEmpty
			locX = 1952,
			locY = 483,
		},
		{
			index = 235, -- number
			id = 8, -- location [L8]
			type = 2, -- isEmpty
			locX = 2016,
			locY = 483,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p14]*[p5]+[p13]*[p6]*[p6]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p5]*[p14]*2",
				},
			},
		},
		{
			index = 236, -- number
			id = 185, -- location [L185]
			type = 2, -- isEmpty
			locX = 1440,
			locY = 1113,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p6]*[p7]",
				},
				{
					index = "[p6]",
					changingFormula = "[p5]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
			},
		},
		{
			index = 237, -- number
			id = 79, -- location [L79]
			type = 2, -- isEmpty
			locX = 608,
			locY = 567,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p27]",
				},
				{
					index = "[p6]",
					changingFormula = "[p28]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 238, -- number
			id = 78, -- location [L78]
			type = 2, -- isEmpty
			locX = 544,
			locY = 567,
		},
		{
			index = 239, -- number
			id = 81, -- location [L81]
			type = 2, -- isEmpty
			locX = 736,
			locY = 567,
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "[p4]*100+28",
				},
			},
		},
		{
			index = 240, -- number
			id = 97, -- location [L97]
			type = 2, -- isEmpty
			locX = 1504,
			locY = 567,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 241, -- number
			id = 116, -- location [L116]
			type = 2, -- isEmpty
			locX = 672,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p17]",
				},
				{
					index = "[p6]",
					changingFormula = "[p18]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 242, -- number
			id = 22, -- location [L22]
			type = 2, -- isEmpty
			locX = 2016,
			locY = 903,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p46]*[p47]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p45]",
				},
			},
		},
		{
			index = 243, -- number
			id = 214, -- location [L214]
			type = 2, -- isEmpty
			locX = 992,
			locY = 1323,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p13]",
				},
				{
					index = "[p6]",
					changingFormula = "[p14]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 244, -- number
			id = 148, -- location [L148]
			type = 2, -- isEmpty
			locX = 288,
			locY = 1071,
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "[p4]*100+62",
				},
			},
		},
		{
			index = 245, -- number
			id = 169, -- location [L169]
			type = 2, -- isEmpty
			locX = 992,
			locY = 1071,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p19]",
				},
				{
					index = "[p6]",
					changingFormula = "[p20]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 246, -- number
			id = 225, -- location [L225]
			type = 2, -- isEmpty
			locX = 1184,
			locY = 1365,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p6]*[p7]",
				},
				{
					index = "[p6]",
					changingFormula = "[p5]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
			},
		},
		{
			index = 247, -- number
			id = 162, -- location [L162]
			type = 2, -- isEmpty
			locX = 736,
			locY = 1155,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]+[p7]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
			},
		},
		{
			index = 248, -- number
			id = 161, -- location [L161]
			type = 2, -- isEmpty
			locX = 736,
			locY = 1113,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p8]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p7]*[p6]",
				},
				{
					index = "[p8]",
					changingFormula = "[p8]*[p6]",
				},
			},
		},
		{
			index = 249, -- number
			id = 89, -- location [L89]
			type = 2, -- isEmpty
			locX = 1248,
			locY = 567,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 250, -- number
			id = 194, -- location [L194]
			type = 2, -- isEmpty
			locX = 544,
			locY = 1323,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p17]",
				},
				{
					index = "[p6]",
					changingFormula = "[p18]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 251, -- number
			id = 84, -- location [L84]
			type = 2, -- isEmpty
			locX = 928,
			locY = 567,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p35]",
				},
				{
					index = "[p6]",
					changingFormula = "[p36]",
				},
				{
					index = "[p7]",
					changingFormula = "[p5]",
				},
				{
					index = "[p8]",
					changingFormula = "[p6]",
				},
				{
					index = "[p9]",
					changingFormula = "[p7]",
				},
				{
					index = "[p10]",
					changingFormula = "[p8]",
				},
				{
					index = "[p11]",
					changingFormula = "[p9]",
				},
				{
					index = "[p12]",
					changingFormula = "[p10]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 252, -- number
			id = 99, -- location [L99]
			type = 2, -- isEmpty
			locX = 1504,
			locY = 651,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]+[p7]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
			},
		},
		{
			index = 253, -- number
			id = 98, -- location [L98]
			type = 2, -- isEmpty
			locX = 1504,
			locY = 609,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p8]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p7]*[p6]",
				},
				{
					index = "[p8]",
					changingFormula = "[p8]*[p6]",
				},
			},
		},
		{
			index = 254, -- number
			id = 117, -- location [L117]
			type = 2, -- isEmpty
			locX = 736,
			locY = 819,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 255, -- number
			id = 23, -- location [L23]
			type = 2, -- isEmpty
			locX = 2016,
			locY = 819,
		},
		{
			index = 256, -- number
			id = 215, -- location [L215]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 1323,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 257, -- number
			id = 149, -- location [L149]
			type = 2, -- isEmpty
			locX = 352,
			locY = 1071,
		},
		{
			index = 258, -- number
			id = 170, -- location [L170]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 1071,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p7]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 259, -- number
			id = 90, -- location [L90]
			type = 2, -- isEmpty
			locX = 1248,
			locY = 609,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p6]*[p7]",
				},
				{
					index = "[p6]",
					changingFormula = "[p5]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
			},
		},
		{
			index = 260, -- number
			id = 195, -- location [L195]
			type = 2, -- isEmpty
			locX = 608,
			locY = 1323,
			paramsChanges = { -- amount: 56
				{
					index = "[p13]",
					changingFormula = "[p5]",
				},
				{
					index = "[p14]",
					changingFormula = "[p6]",
				},
				{
					index = "[p50]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 261, -- number
			id = 12, -- location [L12]
			type = 2, -- isEmpty
			locX = 992,
			locY = 189,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*180*113",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*355",
				},
			},
		},
		{
			index = 262, -- number
			id = 13, -- location [L13]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 189,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*9",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*10",
				},
			},
		},
		{
			index = 263, -- number
			id = 217, -- location [L217]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 1407,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]+[p7]",
				},
				{
					index = "[p7]",
					changingFormula = "[p9]",
				},
				{
					index = "[p8]",
					changingFormula = "[p10]",
				},
				{
					index = "[p9]",
					changingFormula = "[p11]",
				},
				{
					index = "[p10]",
					changingFormula = "[p12]",
				},
			},
		},
		{
			index = 264, -- number
			id = 216, -- location [L216]
			type = 2, -- isEmpty
			locX = 1056,
			locY = 1365,
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*[p8]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6]*[p8]",
				},
				{
					index = "[p7]",
					changingFormula = "[p7]*[p6]",
				},
				{
					index = "[p8]",
					changingFormula = "[p8]*[p6]",
				},
			},
		},
		{
			index = 265, -- number
			id = 269, -- location [L269]
			type = 2, -- isEmpty
			locX = 1376,
			locY = 189,
		},
		{
			index = 266, -- number
			id = 252, -- location [L252]
			type = 0, -- undefined
			locX = 1248,
			locY = 273,
			texts = {
				"<fix> Высота: {[p5] div [p6]}<clr>.<clrEnd>{((([p5]*100) div [p6]) mod 100)*(1-2*([p5]<0))} м</fix>\n<fix> Запас топлива: {[p7] div [p8]}<clr>.<clrEnd>{((([p7]*100) div [p8]) mod 100)*(1-2*([p7]<0))} кг</fix>\n<fix> Вертикальная скорость: {[p37] div [p38]}<clr>.<clrEnd>{((([p37]*100) div [p38]) mod 100)*(1-2*([p37]<0))} м/с</fix>\n<fix> -----------------------------</fix>\n<fix> Расход топлива: [p53] кг</fix>\n<fix> Время: [p54] с</fix>\n<fix> [d55]</fix>\n\n<clr>!!! Вы разбились !!!<clrEnd>\n",
			},
		},
		{
			index = 267, -- number
			id = 258, -- location [L258]
			type = 2, -- isEmpty
			locX = 1632,
			locY = 273,
		},
		{
			index = 268, -- number
			id = 256, -- location [L256]
			type = 2, -- isEmpty
			locX = 1696,
			locY = 273,
		},
	},
	jumps = {
		{
			index = 1, -- number
			id = 450, -- jump [J450]
			fromLocationId = 236, -- from[L236]
			toLocationId = 239, -- to[L239]
			text = "Сегодня обойдёмся без полётов",
		},
		{
			index = 2, -- number
			id = 451, -- jump [J451]
			fromLocationId = 236, -- from[L236]
			toLocationId = 237, -- to[L237]
			text = "Деньги - ничто, жажда - всё",
			paramsChanges = { -- amount: 56
				{
					index = "[p3]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 3, -- number
			id = 452, -- jump [J452]
			fromLocationId = 236, -- from[L236]
			toLocationId = 237, -- to[L237]
			text = "Идёт",
			formulaToPass = "[p2]>=500",
			paramsChanges = { -- amount: 56
				{
					index = "[p2]",
					changingFormula = "[p2] - 500",
				},
				{
					index = "[p3]",
					changingFormula = "500",
				},
			},
		},
		{
			index = 4, -- number
			id = 453, -- jump [J453]
			fromLocationId = 236, -- from[L236]
			toLocationId = 237, -- to[L237]
			text = "Спорим на тысячу",
			description = "Мелко, Эдик, если спорить, то уж на все деньги!\n",
			formulaToPass = "[p2]>=1000",
			paramsChanges = { -- amount: 56
				{
					index = "[p2]",
					changingFormula = "[p2] - 1000",
				},
				{
					index = "[p3]",
					changingFormula = "1000",
				},
			},
		},
		{
			index = 5, -- number
			id = 458, -- jump [J458]
			fromLocationId = 239, -- from[L239]
			toLocationId = 240, -- to[L240]
			text = "Конечно присоединяйтесь",
			paramsChanges = { -- amount: 56
				{
					index = "[p52]",
					changingFormula = "1",
				},
			},
		},
		{
			index = 6, -- number
			id = 459, -- jump [J459]
			fromLocationId = 239, -- from[L239]
			toLocationId = 240, -- to[L240]
			text = "Мы уже уходим, кофе всё равно нет",
			paramsChanges = { -- amount: 56
				{
					index = "[p52]",
					changingFormula = "2",
				},
			},
		},
		{
			index = 7, -- number
			id = 454, -- jump [J454]
			fromLocationId = 237, -- from[L237]
			toLocationId = 238, -- to[L238]
			text = "Посмотрим что тут у нас",
		},
		{
			index = 8, -- number
			id = 460, -- jump [J460]
			fromLocationId = 240, -- from[L240]
			toLocationId = 241, -- to[L241]
			text = "Незнакомец встал и пошёл в дальний конец зала",
		},
		{
			index = 9, -- number
			id = 455, -- jump [J455]
			fromLocationId = 238, -- from[L238]
			toLocationId = 28, -- to[L28]
			text = "Полетели!",
			formulaToPass = "[p51]<10",
		},
		{
			index = 10, -- number
			id = 456, -- jump [J456]
			fromLocationId = 238, -- from[L238]
			toLocationId = 239, -- to[L239]
			text = "Хватит полётов на сегодня",
			formulaToPass = "[p51]>0",
		},
		{
			index = 11, -- number
			id = 457, -- jump [J457]
			fromLocationId = 238, -- from[L238]
			toLocationId = 239, -- to[L239]
			text = "Обойдёмся без полётов сегодня",
			description = "Согласно показаниям, погода была нелётная и я вернулся за столик.\n",
			formulaToPass = "[p51]=0",
		},
		{
			index = 12, -- number
			id = 461, -- jump [J461]
			fromLocationId = 241, -- from[L241]
			toLocationId = 242, -- to[L242]
			text = "Восемь чашек???",
		},
		{
			index = 13, -- number
			id = 174, -- jump [J174]
			fromLocationId = 28, -- from[L28]
			toLocationId = 29, -- to[L29]
		},
		{
			index = 14, -- number
			id = 462, -- jump [J462]
			fromLocationId = 242, -- from[L242]
			toLocationId = 243, -- to[L243]
			text = "Давайте полетим вместе",
		},
		{
			index = 15, -- number
			id = 175, -- jump [J175]
			fromLocationId = 29, -- from[L29]
			toLocationId = 31, -- to[L31]
			priority = 10.0,
			formulaToPass = "[p5]<0",
		},
		{
			index = 16, -- number
			id = 176, -- jump [J176]
			fromLocationId = 29, -- from[L29]
			toLocationId = 30, -- to[L30]
			formulaToPass = "[p5]>=0",
		},
		{
			index = 17, -- number
			id = 463, -- jump [J463]
			fromLocationId = 243, -- from[L243]
			toLocationId = 244, -- to[L244]
			text = "Эдик поднял лицо",
		},
		{
			index = 18, -- number
			id = 178, -- jump [J178]
			fromLocationId = 31, -- from[L31]
			toLocationId = 32, -- to[L32]
			formulaToPass = "[p50]=0",
		},
		{
			index = 19, -- number
			id = 179, -- jump [J179]
			fromLocationId = 31, -- from[L31]
			toLocationId = 33, -- to[L33]
			formulaToPass = "[p50]=1",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*10",
				},
			},
		},
		{
			index = 20, -- number
			id = 180, -- jump [J180]
			fromLocationId = 31, -- from[L31]
			toLocationId = 33, -- to[L33]
			formulaToPass = "[p50]=2",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 21, -- number
			id = 177, -- jump [J177]
			fromLocationId = 30, -- from[L30]
			toLocationId = 61, -- to[L61]
		},
		{
			index = 22, -- number
			id = 464, -- jump [J464]
			fromLocationId = 244, -- from[L244]
			toLocationId = 245, -- to[L245]
			text = "Это безумие! Я отказываюсь принимать в этом участие!",
		},
		{
			index = 23, -- number
			id = 465, -- jump [J465]
			fromLocationId = 244, -- from[L244]
			toLocationId = 246, -- to[L246]
			text = "Эдик, имей совесть",
		},
		{
			index = 24, -- number
			id = 181, -- jump [J181]
			fromLocationId = 32, -- from[L32]
			toLocationId = 33, -- to[L33]
		},
		{
			index = 25, -- number
			id = 182, -- jump [J182]
			fromLocationId = 33, -- from[L33]
			toLocationId = 34, -- to[L34]
		},
		{
			index = 26, -- number
			id = 219, -- jump [J219]
			fromLocationId = 61, -- from[L61]
			toLocationId = 62, -- to[L62]
			priority = 10.0,
			formulaToPass = "[p5]=0",
		},
		{
			index = 27, -- number
			id = 220, -- jump [J220]
			fromLocationId = 61, -- from[L61]
			toLocationId = 63, -- to[L63]
			formulaToPass = "[p5]<>0",
		},
		{
			index = 28, -- number
			id = 466, -- jump [J466]
			fromLocationId = 246, -- from[L246]
			toLocationId = 247, -- to[L247]
			text = "Вдруг Коршунов захохотал!",
		},
		{
			index = 29, -- number
			id = 183, -- jump [J183]
			fromLocationId = 34, -- from[L34]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+35",
				},
			},
		},
		{
			index = 30, -- number
			id = 221, -- jump [J221]
			fromLocationId = 62, -- from[L62]
			toLocationId = 85, -- to[L85]
		},
		{
			index = 31, -- number
			id = 222, -- jump [J222]
			fromLocationId = 63, -- from[L63]
			toLocationId = 64, -- to[L64]
			formulaToPass = "[p50]=0",
		},
		{
			index = 32, -- number
			id = 223, -- jump [J223]
			fromLocationId = 63, -- from[L63]
			toLocationId = 65, -- to[L65]
			formulaToPass = "[p50]=1",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*10",
				},
			},
		},
		{
			index = 33, -- number
			id = 224, -- jump [J224]
			fromLocationId = 63, -- from[L63]
			toLocationId = 65, -- to[L65]
			formulaToPass = "[p50]=2",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 34, -- number
			id = 467, -- jump [J467]
			fromLocationId = 247, -- from[L247]
			toLocationId = 28, -- to[L28]
			text = "но перед этим...",
			description = "Предстояло перегнать наш лунолёт за <clr>250<clrEnd> км. в Море Спокойствия. Там мы собирались его дооборудовать, провести испытательные полёты и стартовать, наконец, к Земле.\n\nПилотировать аппарат предстояло мне, поскольку Коршунов остался улаживать юридические формальности.\n",
		},
		{
			index = 35, -- number
			id = 1, -- jump [J1]
			fromLocationId = 1, -- from[L1]
			toLocationId = 2, -- to[L2]
			formulaToPass = "[p5]>0",
			paramsChanges = { -- amount: 56
				{
					index = "[p45]",
					changingFormula = "[p5]",
				},
				{
					index = "[p46]",
					changingFormula = "[p6]",
				},
			},
		},
		{
			index = 36, -- number
			id = 2, -- jump [J2]
			fromLocationId = 1, -- from[L1]
			toLocationId = 2, -- to[L2]
			formulaToPass = "[p5]<0",
			paramsChanges = { -- amount: 56
				{
					index = "[p45]",
					changingFormula = "-[p5]",
				},
				{
					index = "[p46]",
					changingFormula = "[p6]",
				},
			},
		},
		{
			index = 37, -- number
			id = 3, -- jump [J3]
			fromLocationId = 1, -- from[L1]
			toLocationId = 4, -- to[L4]
			priority = 10.0,
			formulaToPass = "[p5]=0",
			paramsChanges = { -- amount: 56
				{
					index = "[p6]",
					changingFormula = "1",
				},
			},
		},
		{
			index = 38, -- number
			id = 250, -- jump [J250]
			fromLocationId = 85, -- from[L85]
			toLocationId = 248, -- to[L248]
		},
		{
			index = 39, -- number
			id = 225, -- jump [J225]
			fromLocationId = 64, -- from[L64]
			toLocationId = 65, -- to[L65]
		},
		{
			index = 40, -- number
			id = 226, -- jump [J226]
			fromLocationId = 65, -- from[L65]
			toLocationId = 66, -- to[L66]
		},
		{
			index = 41, -- number
			id = 4, -- jump [J4]
			fromLocationId = 2, -- from[L2]
			toLocationId = 4, -- to[L4]
			priority = 100.0,
			formulaToPass = "[p45]>10 and [p46]>10000 and [p46]>[p45]",
			paramsChanges = { -- amount: 56
				{
					index = "[p46]",
					changingFormula = "[p45]",
				},
			},
		},
		{
			index = 42, -- number
			id = 5, -- jump [J5]
			fromLocationId = 2, -- from[L2]
			toLocationId = 4, -- to[L4]
			priority = 100.0,
			formulaToPass = "[p45]>10000 and [p46]>10 and [p45]>[p46]",
			paramsChanges = { -- amount: 56
				{
					index = "[p45]",
					changingFormula = "[p46]",
				},
			},
		},
		{
			index = 43, -- number
			id = 6, -- jump [J6]
			fromLocationId = 2, -- from[L2]
			toLocationId = 3, -- to[L3]
			formulaToPass = "[p45]<[p46] and [p45]>0",
			paramsChanges = { -- amount: 56
				{
					index = "[p46]",
					changingFormula = "[p46] mod [p45]",
				},
			},
		},
		{
			index = 44, -- number
			id = 7, -- jump [J7]
			fromLocationId = 2, -- from[L2]
			toLocationId = 3, -- to[L3]
			formulaToPass = "[p45]>[p46] and [p46]>0",
			paramsChanges = { -- amount: 56
				{
					index = "[p45]",
					changingFormula = "[p45] mod [p46]",
				},
			},
		},
		{
			index = 45, -- number
			id = 8, -- jump [J8]
			fromLocationId = 2, -- from[L2]
			toLocationId = 4, -- to[L4]
			priority = 10.0,
			formulaToPass = "[p45]=[p46] and [p45]>0",
		},
		{
			index = 46, -- number
			id = 9, -- jump [J9]
			fromLocationId = 2, -- from[L2]
			toLocationId = 4, -- to[L4]
			priority = 10.0,
			formulaToPass = "[p45]=0",
			paramsChanges = { -- amount: 56
				{
					index = "[p45]",
					changingFormula = "[p46]",
				},
			},
		},
		{
			index = 47, -- number
			id = 10, -- jump [J10]
			fromLocationId = 2, -- from[L2]
			toLocationId = 4, -- to[L4]
			priority = 10.0,
			formulaToPass = "[p46]=0",
			paramsChanges = { -- amount: 56
				{
					index = "[p46]",
					changingFormula = "[p45]",
				},
			},
		},
		{
			index = 48, -- number
			id = 12, -- jump [J12]
			fromLocationId = 4, -- from[L4]
			toLocationId = 9, -- to[L9]
			formulaToPass = "([p1] mod 256)=9",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 49, -- number
			id = 13, -- jump [J13]
			fromLocationId = 4, -- from[L4]
			toLocationId = 14, -- to[L14]
			formulaToPass = "([p1] mod 256)=14",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 50, -- number
			id = 14, -- jump [J14]
			fromLocationId = 4, -- from[L4]
			toLocationId = 14, -- to[L14]
			formulaToPass = "([p1] mod 256)=14",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 51, -- number
			id = 15, -- jump [J15]
			fromLocationId = 4, -- from[L4]
			toLocationId = 24, -- to[L24]
			formulaToPass = "([p1] mod 256)=24",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 52, -- number
			id = 16, -- jump [J16]
			fromLocationId = 4, -- from[L4]
			toLocationId = 35, -- to[L35]
			formulaToPass = "([p1] mod 256)=35",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 53, -- number
			id = 17, -- jump [J17]
			fromLocationId = 4, -- from[L4]
			toLocationId = 41, -- to[L41]
			formulaToPass = "([p1] mod 256)=41",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 54, -- number
			id = 18, -- jump [J18]
			fromLocationId = 4, -- from[L4]
			toLocationId = 47, -- to[L47]
			formulaToPass = "([p1] mod 256)=47",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 55, -- number
			id = 19, -- jump [J19]
			fromLocationId = 4, -- from[L4]
			toLocationId = 51, -- to[L51]
			formulaToPass = "([p1] mod 256)=51",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 56, -- number
			id = 20, -- jump [J20]
			fromLocationId = 4, -- from[L4]
			toLocationId = 56, -- to[L56]
			formulaToPass = "([p1] mod 256)=56",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 57, -- number
			id = 21, -- jump [J21]
			fromLocationId = 4, -- from[L4]
			toLocationId = 71, -- to[L71]
			formulaToPass = "([p1] mod 256)=71",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 58, -- number
			id = 22, -- jump [J22]
			fromLocationId = 4, -- from[L4]
			toLocationId = 91, -- to[L91]
			formulaToPass = "([p1] mod 256)=91",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 59, -- number
			id = 23, -- jump [J23]
			fromLocationId = 4, -- from[L4]
			toLocationId = 100, -- to[L100]
			formulaToPass = "([p1] mod 256)=100",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 60, -- number
			id = 24, -- jump [J24]
			fromLocationId = 4, -- from[L4]
			toLocationId = 105, -- to[L105]
			formulaToPass = "([p1] mod 256)=105",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 61, -- number
			id = 25, -- jump [J25]
			fromLocationId = 4, -- from[L4]
			toLocationId = 110, -- to[L110]
			formulaToPass = "([p1] mod 256)=110",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 62, -- number
			id = 26, -- jump [J26]
			fromLocationId = 4, -- from[L4]
			toLocationId = 118, -- to[L118]
			formulaToPass = "([p1] mod 256)=118",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 63, -- number
			id = 27, -- jump [J27]
			fromLocationId = 4, -- from[L4]
			toLocationId = 118, -- to[L118]
			formulaToPass = "([p1] mod 256)=118",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 64, -- number
			id = 28, -- jump [J28]
			fromLocationId = 4, -- from[L4]
			toLocationId = 119, -- to[L119]
			formulaToPass = "([p1] mod 256)=119",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 65, -- number
			id = 29, -- jump [J29]
			fromLocationId = 4, -- from[L4]
			toLocationId = 121, -- to[L121]
			formulaToPass = "([p1] mod 256)=121",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 66, -- number
			id = 30, -- jump [J30]
			fromLocationId = 4, -- from[L4]
			toLocationId = 126, -- to[L126]
			formulaToPass = "([p1] mod 256)=126",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 67, -- number
			id = 31, -- jump [J31]
			fromLocationId = 4, -- from[L4]
			toLocationId = 133, -- to[L133]
			formulaToPass = "([p1] mod 256)=133",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 68, -- number
			id = 32, -- jump [J32]
			fromLocationId = 4, -- from[L4]
			toLocationId = 142, -- to[L142]
			formulaToPass = "([p1] mod 256)=142",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 69, -- number
			id = 33, -- jump [J33]
			fromLocationId = 4, -- from[L4]
			toLocationId = 153, -- to[L153]
			formulaToPass = "([p1] mod 256)=153",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 70, -- number
			id = 34, -- jump [J34]
			fromLocationId = 4, -- from[L4]
			toLocationId = 163, -- to[L163]
			formulaToPass = "([p1] mod 256)=163",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 71, -- number
			id = 35, -- jump [J35]
			fromLocationId = 4, -- from[L4]
			toLocationId = 171, -- to[L171]
			formulaToPass = "([p1] mod 256)=171",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 72, -- number
			id = 36, -- jump [J36]
			fromLocationId = 4, -- from[L4]
			toLocationId = 177, -- to[L177]
			formulaToPass = "([p1] mod 256)=177",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 73, -- number
			id = 37, -- jump [J37]
			fromLocationId = 4, -- from[L4]
			toLocationId = 186, -- to[L186]
			formulaToPass = "([p1] mod 256)=186",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 74, -- number
			id = 38, -- jump [J38]
			fromLocationId = 4, -- from[L4]
			toLocationId = 196, -- to[L196]
			formulaToPass = "([p1] mod 256)=196",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 75, -- number
			id = 39, -- jump [J39]
			fromLocationId = 4, -- from[L4]
			toLocationId = 196, -- to[L196]
			formulaToPass = "([p1] mod 256)=196",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 76, -- number
			id = 40, -- jump [J40]
			fromLocationId = 4, -- from[L4]
			toLocationId = 197, -- to[L197]
			formulaToPass = "([p1] mod 256)=197",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 77, -- number
			id = 41, -- jump [J41]
			fromLocationId = 4, -- from[L4]
			toLocationId = 199, -- to[L199]
			formulaToPass = "([p1] mod 256)=199",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 78, -- number
			id = 42, -- jump [J42]
			fromLocationId = 4, -- from[L4]
			toLocationId = 205, -- to[L205]
			formulaToPass = "([p1] mod 256)=205",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 79, -- number
			id = 43, -- jump [J43]
			fromLocationId = 4, -- from[L4]
			toLocationId = 209, -- to[L209]
			formulaToPass = "([p1] mod 256)=209",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 80, -- number
			id = 44, -- jump [J44]
			fromLocationId = 4, -- from[L4]
			toLocationId = 218, -- to[L218]
			formulaToPass = "([p1] mod 256)=218",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 81, -- number
			id = 45, -- jump [J45]
			fromLocationId = 4, -- from[L4]
			toLocationId = 226, -- to[L226]
			formulaToPass = "([p1] mod 256)=226",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 82, -- number
			id = 46, -- jump [J46]
			fromLocationId = 4, -- from[L4]
			toLocationId = 231, -- to[L231]
			formulaToPass = "([p1] mod 256)=231",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 83, -- number
			id = 468, -- jump [J468]
			fromLocationId = 248, -- from[L248]
			toLocationId = 250, -- to[L250]
			formulaToPass = "[p4]=32 and [p56]=0",
		},
		{
			index = 84, -- number
			id = 469, -- jump [J469]
			fromLocationId = 248, -- from[L248]
			toLocationId = 259, -- to[L259]
			formulaToPass = "[p4]=32 and [p56]>0",
		},
		{
			index = 85, -- number
			id = 470, -- jump [J470]
			fromLocationId = 248, -- from[L248]
			toLocationId = 249, -- to[L249]
			formulaToPass = "[p4]=28",
		},
		{
			index = 86, -- number
			id = 227, -- jump [J227]
			fromLocationId = 66, -- from[L66]
			toLocationId = 67, -- to[L67]
		},
		{
			index = 87, -- number
			id = 11, -- jump [J11]
			fromLocationId = 3, -- from[L3]
			toLocationId = 2, -- to[L2]
		},
		{
			index = 88, -- number
			id = 52, -- jump [J52]
			fromLocationId = 9, -- from[L9]
			toLocationId = 10, -- to[L10]
			formulaToPass = "[p45]>1",
		},
		{
			index = 89, -- number
			id = 53, -- jump [J53]
			fromLocationId = 9, -- from[L9]
			toLocationId = 11, -- to[L11]
			formulaToPass = "[p45]<2",
		},
		{
			index = 90, -- number
			id = 92, -- jump [J92]
			fromLocationId = 14, -- from[L14]
			toLocationId = 15, -- to[L15]
			priority = 10.0,
			formulaToPass = "[p45]>1",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5] div [p45]",
				},
				{
					index = "[p6]",
					changingFormula = "[p6] div [p45]",
				},
			},
		},
		{
			index = 91, -- number
			id = 93, -- jump [J93]
			fromLocationId = 14, -- from[L14]
			toLocationId = 15, -- to[L15]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 92, -- number
			id = 139, -- jump [J139]
			fromLocationId = 24, -- from[L24]
			toLocationId = 25, -- to[L25]
			formulaToPass = "[p45]>1",
		},
		{
			index = 93, -- number
			id = 140, -- jump [J140]
			fromLocationId = 24, -- from[L24]
			toLocationId = 26, -- to[L26]
			formulaToPass = "[p45]<2",
		},
		{
			index = 94, -- number
			id = 184, -- jump [J184]
			fromLocationId = 35, -- from[L35]
			toLocationId = 37, -- to[L37]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 95, -- number
			id = 185, -- jump [J185]
			fromLocationId = 35, -- from[L35]
			toLocationId = 36, -- to[L36]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 96, -- number
			id = 191, -- jump [J191]
			fromLocationId = 41, -- from[L41]
			toLocationId = 43, -- to[L43]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 97, -- number
			id = 192, -- jump [J192]
			fromLocationId = 41, -- from[L41]
			toLocationId = 42, -- to[L42]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 98, -- number
			id = 199, -- jump [J199]
			fromLocationId = 47, -- from[L47]
			toLocationId = 49, -- to[L49]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 99, -- number
			id = 200, -- jump [J200]
			fromLocationId = 47, -- from[L47]
			toLocationId = 48, -- to[L48]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 100, -- number
			id = 207, -- jump [J207]
			fromLocationId = 51, -- from[L51]
			toLocationId = 52, -- to[L52]
		},
		{
			index = 101, -- number
			id = 213, -- jump [J213]
			fromLocationId = 56, -- from[L56]
			toLocationId = 58, -- to[L58]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 102, -- number
			id = 214, -- jump [J214]
			fromLocationId = 56, -- from[L56]
			toLocationId = 57, -- to[L57]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 103, -- number
			id = 233, -- jump [J233]
			fromLocationId = 71, -- from[L71]
			toLocationId = 73, -- to[L73]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 104, -- number
			id = 234, -- jump [J234]
			fromLocationId = 71, -- from[L71]
			toLocationId = 72, -- to[L72]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 105, -- number
			id = 258, -- jump [J258]
			fromLocationId = 91, -- from[L91]
			toLocationId = 93, -- to[L93]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 106, -- number
			id = 259, -- jump [J259]
			fromLocationId = 91, -- from[L91]
			toLocationId = 92, -- to[L92]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 107, -- number
			id = 269, -- jump [J269]
			fromLocationId = 100, -- from[L100]
			toLocationId = 102, -- to[L102]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 108, -- number
			id = 270, -- jump [J270]
			fromLocationId = 100, -- from[L100]
			toLocationId = 101, -- to[L101]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 109, -- number
			id = 277, -- jump [J277]
			fromLocationId = 105, -- from[L105]
			toLocationId = 107, -- to[L107]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 110, -- number
			id = 278, -- jump [J278]
			fromLocationId = 105, -- from[L105]
			toLocationId = 106, -- to[L106]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 111, -- number
			id = 283, -- jump [J283]
			fromLocationId = 110, -- from[L110]
			toLocationId = 112, -- to[L112]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 112, -- number
			id = 284, -- jump [J284]
			fromLocationId = 110, -- from[L110]
			toLocationId = 111, -- to[L111]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 113, -- number
			id = 294, -- jump [J294]
			fromLocationId = 118, -- from[L118]
			toLocationId = 17, -- to[L17]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+119",
				},
			},
		},
		{
			index = 114, -- number
			id = 295, -- jump [J295]
			fromLocationId = 119, -- from[L119]
			toLocationId = 120, -- to[L120]
		},
		{
			index = 115, -- number
			id = 297, -- jump [J297]
			fromLocationId = 121, -- from[L121]
			toLocationId = 123, -- to[L123]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 116, -- number
			id = 298, -- jump [J298]
			fromLocationId = 121, -- from[L121]
			toLocationId = 122, -- to[L122]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 117, -- number
			id = 303, -- jump [J303]
			fromLocationId = 126, -- from[L126]
			toLocationId = 128, -- to[L128]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 118, -- number
			id = 304, -- jump [J304]
			fromLocationId = 126, -- from[L126]
			toLocationId = 127, -- to[L127]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 119, -- number
			id = 312, -- jump [J312]
			fromLocationId = 133, -- from[L133]
			toLocationId = 135, -- to[L135]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 120, -- number
			id = 313, -- jump [J313]
			fromLocationId = 133, -- from[L133]
			toLocationId = 134, -- to[L134]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 121, -- number
			id = 323, -- jump [J323]
			fromLocationId = 142, -- from[L142]
			toLocationId = 144, -- to[L144]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 122, -- number
			id = 324, -- jump [J324]
			fromLocationId = 142, -- from[L142]
			toLocationId = 143, -- to[L143]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 123, -- number
			id = 336, -- jump [J336]
			fromLocationId = 153, -- from[L153]
			toLocationId = 155, -- to[L155]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 124, -- number
			id = 337, -- jump [J337]
			fromLocationId = 153, -- from[L153]
			toLocationId = 154, -- to[L154]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 125, -- number
			id = 348, -- jump [J348]
			fromLocationId = 163, -- from[L163]
			toLocationId = 165, -- to[L165]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 126, -- number
			id = 349, -- jump [J349]
			fromLocationId = 163, -- from[L163]
			toLocationId = 164, -- to[L164]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 127, -- number
			id = 357, -- jump [J357]
			fromLocationId = 171, -- from[L171]
			toLocationId = 173, -- to[L173]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 128, -- number
			id = 358, -- jump [J358]
			fromLocationId = 171, -- from[L171]
			toLocationId = 172, -- to[L172]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 129, -- number
			id = 365, -- jump [J365]
			fromLocationId = 177, -- from[L177]
			toLocationId = 179, -- to[L179]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 130, -- number
			id = 366, -- jump [J366]
			fromLocationId = 177, -- from[L177]
			toLocationId = 178, -- to[L178]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 131, -- number
			id = 378, -- jump [J378]
			fromLocationId = 186, -- from[L186]
			toLocationId = 188, -- to[L188]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 132, -- number
			id = 379, -- jump [J379]
			fromLocationId = 186, -- from[L186]
			toLocationId = 187, -- to[L187]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 133, -- number
			id = 391, -- jump [J391]
			fromLocationId = 196, -- from[L196]
			toLocationId = 16, -- to[L16]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+197",
				},
			},
		},
		{
			index = 134, -- number
			id = 392, -- jump [J392]
			fromLocationId = 197, -- from[L197]
			toLocationId = 198, -- to[L198]
		},
		{
			index = 135, -- number
			id = 394, -- jump [J394]
			fromLocationId = 199, -- from[L199]
			toLocationId = 201, -- to[L201]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 136, -- number
			id = 395, -- jump [J395]
			fromLocationId = 199, -- from[L199]
			toLocationId = 200, -- to[L200]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 137, -- number
			id = 402, -- jump [J402]
			fromLocationId = 205, -- from[L205]
			toLocationId = 207, -- to[L207]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 138, -- number
			id = 403, -- jump [J403]
			fromLocationId = 205, -- from[L205]
			toLocationId = 206, -- to[L206]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 139, -- number
			id = 407, -- jump [J407]
			fromLocationId = 209, -- from[L209]
			toLocationId = 211, -- to[L211]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 140, -- number
			id = 408, -- jump [J408]
			fromLocationId = 209, -- from[L209]
			toLocationId = 210, -- to[L210]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 141, -- number
			id = 421, -- jump [J421]
			fromLocationId = 218, -- from[L218]
			toLocationId = 220, -- to[L220]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 142, -- number
			id = 422, -- jump [J422]
			fromLocationId = 218, -- from[L218]
			toLocationId = 219, -- to[L219]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 143, -- number
			id = 434, -- jump [J434]
			fromLocationId = 226, -- from[L226]
			toLocationId = 228, -- to[L228]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 144, -- number
			id = 435, -- jump [J435]
			fromLocationId = 226, -- from[L226]
			toLocationId = 227, -- to[L227]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 145, -- number
			id = 440, -- jump [J440]
			fromLocationId = 231, -- from[L231]
			toLocationId = 233, -- to[L233]
			formulaToPass = "[p45]<=1",
		},
		{
			index = 146, -- number
			id = 441, -- jump [J441]
			fromLocationId = 231, -- from[L231]
			toLocationId = 232, -- to[L232]
			priority = 10.0,
			formulaToPass = "[p45]>1",
		},
		{
			index = 147, -- number
			id = 472, -- jump [J472]
			fromLocationId = 250, -- from[L250]
			toLocationId = 251, -- to[L251]
			priority = 100.0,
			formulaToPass = "[p5]<[p6] and -[p37]<5*[p38]",
		},
		{
			index = 148, -- number
			id = 473, -- jump [J473]
			fromLocationId = 250, -- from[L250]
			toLocationId = 252, -- to[L252]
			priority = 50.0,
			formulaToPass = "[p5]<[p6] and -[p37]>=5*[p38]",
		},
		{
			index = 149, -- number
			id = 474, -- jump [J474]
			fromLocationId = 250, -- from[L250]
			toLocationId = 253, -- to[L253]
		},
		{
			index = 150, -- number
			id = 495, -- jump [J495]
			fromLocationId = 259, -- from[L259]
			toLocationId = 260, -- to[L260]
			priority = 100.0,
			formulaToPass = "[p5]<[p6] and [p56]=2 and -[p37]<5*[p38] and -[p15]<5*[p16] and [p15]<5*[p16] and [p39]<10*[p40] and -[p39]<10*[p40]",
		},
		{
			index = 151, -- number
			id = 496, -- jump [J496]
			fromLocationId = 259, -- from[L259]
			toLocationId = 261, -- to[L261]
			priority = 90.0,
			formulaToPass = "[p5]<[p6] and [p56]=2 and -[p37]<5*[p38] and -[p15]<5*[p16] and [p15]<5*[p16] and ([p39]>=10*[p40] or -[p39]>=10*[p40])",
		},
		{
			index = 152, -- number
			id = 497, -- jump [J497]
			fromLocationId = 259, -- from[L259]
			toLocationId = 262, -- to[L262]
			priority = 50.0,
			formulaToPass = "[p5]<[p6] and (-[p37]>=5*[p38] or -[p15]>=5*[p16] or [p15]>=5*[p16])",
		},
		{
			index = 153, -- number
			id = 498, -- jump [J498]
			fromLocationId = 259, -- from[L259]
			toLocationId = 263, -- to[L263]
			priority = 10.0,
			formulaToPass = "[p5]>=50*[p6] and [p56]<2",
			paramsChanges = { -- amount: 56
				{
					index = "[p56]",
					changingFormula = "2",
				},
			},
		},
		{
			index = 154, -- number
			id = 499, -- jump [J499]
			fromLocationId = 259, -- from[L259]
			toLocationId = 263, -- to[L263]
		},
		{
			index = 155, -- number
			id = 471, -- jump [J471]
			fromLocationId = 249, -- from[L249]
			toLocationId = 235, -- to[L235]
			text = "Прийти в себя",
		},
		{
			index = 156, -- number
			id = 228, -- jump [J228]
			fromLocationId = 67, -- from[L67]
			toLocationId = 68, -- to[L68]
		},
		{
			index = 157, -- number
			id = 54, -- jump [J54]
			fromLocationId = 10, -- from[L10]
			toLocationId = 11, -- to[L11]
		},
		{
			index = 158, -- number
			id = 55, -- jump [J55]
			fromLocationId = 11, -- from[L11]
			toLocationId = 9, -- to[L9]
			formulaToPass = "([p1] mod 256)=9",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 159, -- number
			id = 56, -- jump [J56]
			fromLocationId = 11, -- from[L11]
			toLocationId = 14, -- to[L14]
			formulaToPass = "([p1] mod 256)=14",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 160, -- number
			id = 57, -- jump [J57]
			fromLocationId = 11, -- from[L11]
			toLocationId = 14, -- to[L14]
			formulaToPass = "([p1] mod 256)=14",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 161, -- number
			id = 58, -- jump [J58]
			fromLocationId = 11, -- from[L11]
			toLocationId = 24, -- to[L24]
			formulaToPass = "([p1] mod 256)=24",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 162, -- number
			id = 59, -- jump [J59]
			fromLocationId = 11, -- from[L11]
			toLocationId = 35, -- to[L35]
			formulaToPass = "([p1] mod 256)=35",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 163, -- number
			id = 60, -- jump [J60]
			fromLocationId = 11, -- from[L11]
			toLocationId = 41, -- to[L41]
			formulaToPass = "([p1] mod 256)=41",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 164, -- number
			id = 61, -- jump [J61]
			fromLocationId = 11, -- from[L11]
			toLocationId = 47, -- to[L47]
			formulaToPass = "([p1] mod 256)=47",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 165, -- number
			id = 62, -- jump [J62]
			fromLocationId = 11, -- from[L11]
			toLocationId = 51, -- to[L51]
			formulaToPass = "([p1] mod 256)=51",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 166, -- number
			id = 63, -- jump [J63]
			fromLocationId = 11, -- from[L11]
			toLocationId = 56, -- to[L56]
			formulaToPass = "([p1] mod 256)=56",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 167, -- number
			id = 64, -- jump [J64]
			fromLocationId = 11, -- from[L11]
			toLocationId = 71, -- to[L71]
			formulaToPass = "([p1] mod 256)=71",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 168, -- number
			id = 65, -- jump [J65]
			fromLocationId = 11, -- from[L11]
			toLocationId = 91, -- to[L91]
			formulaToPass = "([p1] mod 256)=91",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 169, -- number
			id = 66, -- jump [J66]
			fromLocationId = 11, -- from[L11]
			toLocationId = 100, -- to[L100]
			formulaToPass = "([p1] mod 256)=100",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 170, -- number
			id = 67, -- jump [J67]
			fromLocationId = 11, -- from[L11]
			toLocationId = 105, -- to[L105]
			formulaToPass = "([p1] mod 256)=105",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 171, -- number
			id = 68, -- jump [J68]
			fromLocationId = 11, -- from[L11]
			toLocationId = 110, -- to[L110]
			formulaToPass = "([p1] mod 256)=110",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 172, -- number
			id = 69, -- jump [J69]
			fromLocationId = 11, -- from[L11]
			toLocationId = 118, -- to[L118]
			formulaToPass = "([p1] mod 256)=118",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 173, -- number
			id = 70, -- jump [J70]
			fromLocationId = 11, -- from[L11]
			toLocationId = 118, -- to[L118]
			formulaToPass = "([p1] mod 256)=118",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 174, -- number
			id = 71, -- jump [J71]
			fromLocationId = 11, -- from[L11]
			toLocationId = 119, -- to[L119]
			formulaToPass = "([p1] mod 256)=119",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 175, -- number
			id = 72, -- jump [J72]
			fromLocationId = 11, -- from[L11]
			toLocationId = 121, -- to[L121]
			formulaToPass = "([p1] mod 256)=121",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 176, -- number
			id = 73, -- jump [J73]
			fromLocationId = 11, -- from[L11]
			toLocationId = 126, -- to[L126]
			formulaToPass = "([p1] mod 256)=126",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 177, -- number
			id = 74, -- jump [J74]
			fromLocationId = 11, -- from[L11]
			toLocationId = 133, -- to[L133]
			formulaToPass = "([p1] mod 256)=133",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 178, -- number
			id = 75, -- jump [J75]
			fromLocationId = 11, -- from[L11]
			toLocationId = 142, -- to[L142]
			formulaToPass = "([p1] mod 256)=142",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 179, -- number
			id = 76, -- jump [J76]
			fromLocationId = 11, -- from[L11]
			toLocationId = 153, -- to[L153]
			formulaToPass = "([p1] mod 256)=153",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 180, -- number
			id = 77, -- jump [J77]
			fromLocationId = 11, -- from[L11]
			toLocationId = 163, -- to[L163]
			formulaToPass = "([p1] mod 256)=163",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 181, -- number
			id = 78, -- jump [J78]
			fromLocationId = 11, -- from[L11]
			toLocationId = 171, -- to[L171]
			formulaToPass = "([p1] mod 256)=171",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 182, -- number
			id = 79, -- jump [J79]
			fromLocationId = 11, -- from[L11]
			toLocationId = 177, -- to[L177]
			formulaToPass = "([p1] mod 256)=177",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 183, -- number
			id = 80, -- jump [J80]
			fromLocationId = 11, -- from[L11]
			toLocationId = 186, -- to[L186]
			formulaToPass = "([p1] mod 256)=186",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 184, -- number
			id = 81, -- jump [J81]
			fromLocationId = 11, -- from[L11]
			toLocationId = 196, -- to[L196]
			formulaToPass = "([p1] mod 256)=196",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 185, -- number
			id = 82, -- jump [J82]
			fromLocationId = 11, -- from[L11]
			toLocationId = 196, -- to[L196]
			formulaToPass = "([p1] mod 256)=196",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 186, -- number
			id = 83, -- jump [J83]
			fromLocationId = 11, -- from[L11]
			toLocationId = 197, -- to[L197]
			formulaToPass = "([p1] mod 256)=197",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 187, -- number
			id = 84, -- jump [J84]
			fromLocationId = 11, -- from[L11]
			toLocationId = 199, -- to[L199]
			formulaToPass = "([p1] mod 256)=199",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 188, -- number
			id = 85, -- jump [J85]
			fromLocationId = 11, -- from[L11]
			toLocationId = 205, -- to[L205]
			formulaToPass = "([p1] mod 256)=205",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 189, -- number
			id = 86, -- jump [J86]
			fromLocationId = 11, -- from[L11]
			toLocationId = 209, -- to[L209]
			formulaToPass = "([p1] mod 256)=209",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 190, -- number
			id = 87, -- jump [J87]
			fromLocationId = 11, -- from[L11]
			toLocationId = 218, -- to[L218]
			formulaToPass = "([p1] mod 256)=218",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 191, -- number
			id = 88, -- jump [J88]
			fromLocationId = 11, -- from[L11]
			toLocationId = 226, -- to[L226]
			formulaToPass = "([p1] mod 256)=226",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 192, -- number
			id = 89, -- jump [J89]
			fromLocationId = 11, -- from[L11]
			toLocationId = 231, -- to[L231]
			formulaToPass = "([p1] mod 256)=231",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 193, -- number
			id = 94, -- jump [J94]
			fromLocationId = 15, -- from[L15]
			toLocationId = 14, -- to[L14]
			formulaToPass = "([p1] mod 256)=14",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 194, -- number
			id = 95, -- jump [J95]
			fromLocationId = 15, -- from[L15]
			toLocationId = 14, -- to[L14]
			formulaToPass = "([p1] mod 256)=14",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 195, -- number
			id = 96, -- jump [J96]
			fromLocationId = 15, -- from[L15]
			toLocationId = 24, -- to[L24]
			formulaToPass = "([p1] mod 256)=24",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 196, -- number
			id = 97, -- jump [J97]
			fromLocationId = 15, -- from[L15]
			toLocationId = 35, -- to[L35]
			formulaToPass = "([p1] mod 256)=35",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 197, -- number
			id = 98, -- jump [J98]
			fromLocationId = 15, -- from[L15]
			toLocationId = 41, -- to[L41]
			formulaToPass = "([p1] mod 256)=41",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 198, -- number
			id = 99, -- jump [J99]
			fromLocationId = 15, -- from[L15]
			toLocationId = 47, -- to[L47]
			formulaToPass = "([p1] mod 256)=47",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 199, -- number
			id = 100, -- jump [J100]
			fromLocationId = 15, -- from[L15]
			toLocationId = 51, -- to[L51]
			formulaToPass = "([p1] mod 256)=51",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 200, -- number
			id = 101, -- jump [J101]
			fromLocationId = 15, -- from[L15]
			toLocationId = 56, -- to[L56]
			formulaToPass = "([p1] mod 256)=56",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 201, -- number
			id = 102, -- jump [J102]
			fromLocationId = 15, -- from[L15]
			toLocationId = 71, -- to[L71]
			formulaToPass = "([p1] mod 256)=71",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 202, -- number
			id = 103, -- jump [J103]
			fromLocationId = 15, -- from[L15]
			toLocationId = 91, -- to[L91]
			formulaToPass = "([p1] mod 256)=91",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 203, -- number
			id = 104, -- jump [J104]
			fromLocationId = 15, -- from[L15]
			toLocationId = 100, -- to[L100]
			formulaToPass = "([p1] mod 256)=100",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 204, -- number
			id = 105, -- jump [J105]
			fromLocationId = 15, -- from[L15]
			toLocationId = 105, -- to[L105]
			formulaToPass = "([p1] mod 256)=105",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 205, -- number
			id = 106, -- jump [J106]
			fromLocationId = 15, -- from[L15]
			toLocationId = 110, -- to[L110]
			formulaToPass = "([p1] mod 256)=110",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 206, -- number
			id = 107, -- jump [J107]
			fromLocationId = 15, -- from[L15]
			toLocationId = 118, -- to[L118]
			formulaToPass = "([p1] mod 256)=118",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 207, -- number
			id = 108, -- jump [J108]
			fromLocationId = 15, -- from[L15]
			toLocationId = 118, -- to[L118]
			formulaToPass = "([p1] mod 256)=118",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 208, -- number
			id = 109, -- jump [J109]
			fromLocationId = 15, -- from[L15]
			toLocationId = 119, -- to[L119]
			formulaToPass = "([p1] mod 256)=119",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 209, -- number
			id = 110, -- jump [J110]
			fromLocationId = 15, -- from[L15]
			toLocationId = 121, -- to[L121]
			formulaToPass = "([p1] mod 256)=121",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 210, -- number
			id = 111, -- jump [J111]
			fromLocationId = 15, -- from[L15]
			toLocationId = 126, -- to[L126]
			formulaToPass = "([p1] mod 256)=126",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 211, -- number
			id = 112, -- jump [J112]
			fromLocationId = 15, -- from[L15]
			toLocationId = 133, -- to[L133]
			formulaToPass = "([p1] mod 256)=133",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 212, -- number
			id = 113, -- jump [J113]
			fromLocationId = 15, -- from[L15]
			toLocationId = 142, -- to[L142]
			formulaToPass = "([p1] mod 256)=142",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 213, -- number
			id = 114, -- jump [J114]
			fromLocationId = 15, -- from[L15]
			toLocationId = 153, -- to[L153]
			formulaToPass = "([p1] mod 256)=153",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 214, -- number
			id = 115, -- jump [J115]
			fromLocationId = 15, -- from[L15]
			toLocationId = 163, -- to[L163]
			formulaToPass = "([p1] mod 256)=163",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 215, -- number
			id = 116, -- jump [J116]
			fromLocationId = 15, -- from[L15]
			toLocationId = 171, -- to[L171]
			formulaToPass = "([p1] mod 256)=171",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 216, -- number
			id = 117, -- jump [J117]
			fromLocationId = 15, -- from[L15]
			toLocationId = 177, -- to[L177]
			formulaToPass = "([p1] mod 256)=177",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 217, -- number
			id = 118, -- jump [J118]
			fromLocationId = 15, -- from[L15]
			toLocationId = 186, -- to[L186]
			formulaToPass = "([p1] mod 256)=186",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 218, -- number
			id = 119, -- jump [J119]
			fromLocationId = 15, -- from[L15]
			toLocationId = 196, -- to[L196]
			formulaToPass = "([p1] mod 256)=196",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 219, -- number
			id = 120, -- jump [J120]
			fromLocationId = 15, -- from[L15]
			toLocationId = 196, -- to[L196]
			formulaToPass = "([p1] mod 256)=196",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 220, -- number
			id = 121, -- jump [J121]
			fromLocationId = 15, -- from[L15]
			toLocationId = 197, -- to[L197]
			formulaToPass = "([p1] mod 256)=197",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 221, -- number
			id = 122, -- jump [J122]
			fromLocationId = 15, -- from[L15]
			toLocationId = 199, -- to[L199]
			formulaToPass = "([p1] mod 256)=199",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 222, -- number
			id = 123, -- jump [J123]
			fromLocationId = 15, -- from[L15]
			toLocationId = 205, -- to[L205]
			formulaToPass = "([p1] mod 256)=205",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 223, -- number
			id = 124, -- jump [J124]
			fromLocationId = 15, -- from[L15]
			toLocationId = 209, -- to[L209]
			formulaToPass = "([p1] mod 256)=209",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 224, -- number
			id = 125, -- jump [J125]
			fromLocationId = 15, -- from[L15]
			toLocationId = 218, -- to[L218]
			formulaToPass = "([p1] mod 256)=218",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 225, -- number
			id = 126, -- jump [J126]
			fromLocationId = 15, -- from[L15]
			toLocationId = 226, -- to[L226]
			formulaToPass = "([p1] mod 256)=226",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 226, -- number
			id = 127, -- jump [J127]
			fromLocationId = 15, -- from[L15]
			toLocationId = 231, -- to[L231]
			formulaToPass = "([p1] mod 256)=231",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 227, -- number
			id = 141, -- jump [J141]
			fromLocationId = 25, -- from[L25]
			toLocationId = 26, -- to[L26]
		},
		{
			index = 228, -- number
			id = 142, -- jump [J142]
			fromLocationId = 26, -- from[L26]
			toLocationId = 24, -- to[L24]
			formulaToPass = "([p1] mod 256)=24",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 229, -- number
			id = 143, -- jump [J143]
			fromLocationId = 26, -- from[L26]
			toLocationId = 35, -- to[L35]
			formulaToPass = "([p1] mod 256)=35",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 230, -- number
			id = 144, -- jump [J144]
			fromLocationId = 26, -- from[L26]
			toLocationId = 41, -- to[L41]
			formulaToPass = "([p1] mod 256)=41",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 231, -- number
			id = 145, -- jump [J145]
			fromLocationId = 26, -- from[L26]
			toLocationId = 47, -- to[L47]
			formulaToPass = "([p1] mod 256)=47",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 232, -- number
			id = 146, -- jump [J146]
			fromLocationId = 26, -- from[L26]
			toLocationId = 51, -- to[L51]
			formulaToPass = "([p1] mod 256)=51",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 233, -- number
			id = 147, -- jump [J147]
			fromLocationId = 26, -- from[L26]
			toLocationId = 56, -- to[L56]
			formulaToPass = "([p1] mod 256)=56",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 234, -- number
			id = 148, -- jump [J148]
			fromLocationId = 26, -- from[L26]
			toLocationId = 71, -- to[L71]
			formulaToPass = "([p1] mod 256)=71",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 235, -- number
			id = 149, -- jump [J149]
			fromLocationId = 26, -- from[L26]
			toLocationId = 91, -- to[L91]
			formulaToPass = "([p1] mod 256)=91",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 236, -- number
			id = 150, -- jump [J150]
			fromLocationId = 26, -- from[L26]
			toLocationId = 100, -- to[L100]
			formulaToPass = "([p1] mod 256)=100",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 237, -- number
			id = 151, -- jump [J151]
			fromLocationId = 26, -- from[L26]
			toLocationId = 105, -- to[L105]
			formulaToPass = "([p1] mod 256)=105",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 238, -- number
			id = 152, -- jump [J152]
			fromLocationId = 26, -- from[L26]
			toLocationId = 110, -- to[L110]
			formulaToPass = "([p1] mod 256)=110",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 239, -- number
			id = 153, -- jump [J153]
			fromLocationId = 26, -- from[L26]
			toLocationId = 118, -- to[L118]
			formulaToPass = "([p1] mod 256)=118",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 240, -- number
			id = 154, -- jump [J154]
			fromLocationId = 26, -- from[L26]
			toLocationId = 118, -- to[L118]
			formulaToPass = "([p1] mod 256)=118",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 241, -- number
			id = 155, -- jump [J155]
			fromLocationId = 26, -- from[L26]
			toLocationId = 119, -- to[L119]
			formulaToPass = "([p1] mod 256)=119",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 242, -- number
			id = 156, -- jump [J156]
			fromLocationId = 26, -- from[L26]
			toLocationId = 121, -- to[L121]
			formulaToPass = "([p1] mod 256)=121",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 243, -- number
			id = 157, -- jump [J157]
			fromLocationId = 26, -- from[L26]
			toLocationId = 126, -- to[L126]
			formulaToPass = "([p1] mod 256)=126",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 244, -- number
			id = 158, -- jump [J158]
			fromLocationId = 26, -- from[L26]
			toLocationId = 133, -- to[L133]
			formulaToPass = "([p1] mod 256)=133",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 245, -- number
			id = 159, -- jump [J159]
			fromLocationId = 26, -- from[L26]
			toLocationId = 142, -- to[L142]
			formulaToPass = "([p1] mod 256)=142",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 246, -- number
			id = 160, -- jump [J160]
			fromLocationId = 26, -- from[L26]
			toLocationId = 153, -- to[L153]
			formulaToPass = "([p1] mod 256)=153",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 247, -- number
			id = 161, -- jump [J161]
			fromLocationId = 26, -- from[L26]
			toLocationId = 163, -- to[L163]
			formulaToPass = "([p1] mod 256)=163",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 248, -- number
			id = 162, -- jump [J162]
			fromLocationId = 26, -- from[L26]
			toLocationId = 171, -- to[L171]
			formulaToPass = "([p1] mod 256)=171",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 249, -- number
			id = 163, -- jump [J163]
			fromLocationId = 26, -- from[L26]
			toLocationId = 177, -- to[L177]
			formulaToPass = "([p1] mod 256)=177",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 250, -- number
			id = 164, -- jump [J164]
			fromLocationId = 26, -- from[L26]
			toLocationId = 186, -- to[L186]
			formulaToPass = "([p1] mod 256)=186",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 251, -- number
			id = 165, -- jump [J165]
			fromLocationId = 26, -- from[L26]
			toLocationId = 196, -- to[L196]
			formulaToPass = "([p1] mod 256)=196",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 252, -- number
			id = 166, -- jump [J166]
			fromLocationId = 26, -- from[L26]
			toLocationId = 196, -- to[L196]
			formulaToPass = "([p1] mod 256)=196",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 253, -- number
			id = 167, -- jump [J167]
			fromLocationId = 26, -- from[L26]
			toLocationId = 197, -- to[L197]
			formulaToPass = "([p1] mod 256)=197",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 254, -- number
			id = 168, -- jump [J168]
			fromLocationId = 26, -- from[L26]
			toLocationId = 199, -- to[L199]
			formulaToPass = "([p1] mod 256)=199",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 255, -- number
			id = 169, -- jump [J169]
			fromLocationId = 26, -- from[L26]
			toLocationId = 205, -- to[L205]
			formulaToPass = "([p1] mod 256)=205",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 256, -- number
			id = 170, -- jump [J170]
			fromLocationId = 26, -- from[L26]
			toLocationId = 209, -- to[L209]
			formulaToPass = "([p1] mod 256)=209",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 257, -- number
			id = 171, -- jump [J171]
			fromLocationId = 26, -- from[L26]
			toLocationId = 218, -- to[L218]
			formulaToPass = "([p1] mod 256)=218",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 258, -- number
			id = 172, -- jump [J172]
			fromLocationId = 26, -- from[L26]
			toLocationId = 226, -- to[L226]
			formulaToPass = "([p1] mod 256)=226",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 259, -- number
			id = 173, -- jump [J173]
			fromLocationId = 26, -- from[L26]
			toLocationId = 231, -- to[L231]
			formulaToPass = "([p1] mod 256)=231",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1] div 256",
				},
			},
		},
		{
			index = 260, -- number
			id = 187, -- jump [J187]
			fromLocationId = 37, -- from[L37]
			toLocationId = 38, -- to[L38]
		},
		{
			index = 261, -- number
			id = 186, -- jump [J186]
			fromLocationId = 36, -- from[L36]
			toLocationId = 37, -- to[L37]
		},
		{
			index = 262, -- number
			id = 194, -- jump [J194]
			fromLocationId = 43, -- from[L43]
			toLocationId = 44, -- to[L44]
		},
		{
			index = 263, -- number
			id = 193, -- jump [J193]
			fromLocationId = 42, -- from[L42]
			toLocationId = 43, -- to[L43]
		},
		{
			index = 264, -- number
			id = 202, -- jump [J202]
			fromLocationId = 49, -- from[L49]
			toLocationId = 50, -- to[L50]
		},
		{
			index = 265, -- number
			id = 201, -- jump [J201]
			fromLocationId = 48, -- from[L48]
			toLocationId = 49, -- to[L49]
		},
		{
			index = 266, -- number
			id = 208, -- jump [J208]
			fromLocationId = 52, -- from[L52]
			toLocationId = 53, -- to[L53]
		},
		{
			index = 267, -- number
			id = 216, -- jump [J216]
			fromLocationId = 58, -- from[L58]
			toLocationId = 59, -- to[L59]
		},
		{
			index = 268, -- number
			id = 215, -- jump [J215]
			fromLocationId = 57, -- from[L57]
			toLocationId = 58, -- to[L58]
		},
		{
			index = 269, -- number
			id = 236, -- jump [J236]
			fromLocationId = 73, -- from[L73]
			toLocationId = 74, -- to[L74]
		},
		{
			index = 270, -- number
			id = 235, -- jump [J235]
			fromLocationId = 72, -- from[L72]
			toLocationId = 73, -- to[L73]
		},
		{
			index = 271, -- number
			id = 261, -- jump [J261]
			fromLocationId = 93, -- from[L93]
			toLocationId = 94, -- to[L94]
		},
		{
			index = 272, -- number
			id = 260, -- jump [J260]
			fromLocationId = 92, -- from[L92]
			toLocationId = 93, -- to[L93]
		},
		{
			index = 273, -- number
			id = 272, -- jump [J272]
			fromLocationId = 102, -- from[L102]
			toLocationId = 103, -- to[L103]
		},
		{
			index = 274, -- number
			id = 271, -- jump [J271]
			fromLocationId = 101, -- from[L101]
			toLocationId = 102, -- to[L102]
		},
		{
			index = 275, -- number
			id = 280, -- jump [J280]
			fromLocationId = 107, -- from[L107]
			toLocationId = 108, -- to[L108]
		},
		{
			index = 276, -- number
			id = 279, -- jump [J279]
			fromLocationId = 106, -- from[L106]
			toLocationId = 107, -- to[L107]
		},
		{
			index = 277, -- number
			id = 286, -- jump [J286]
			fromLocationId = 112, -- from[L112]
			toLocationId = 113, -- to[L113]
		},
		{
			index = 278, -- number
			id = 285, -- jump [J285]
			fromLocationId = 111, -- from[L111]
			toLocationId = 112, -- to[L112]
		},
		{
			index = 279, -- number
			id = 129, -- jump [J129]
			fromLocationId = 17, -- from[L17]
			toLocationId = 18, -- to[L18]
			priority = 10.0,
			formulaToPass = "[p5]>360*[p6]",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]-360*[p6]",
				},
			},
		},
		{
			index = 280, -- number
			id = 130, -- jump [J130]
			fromLocationId = 17, -- from[L17]
			toLocationId = 18, -- to[L18]
			priority = 10.0,
			formulaToPass = "[p5]<0",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]+360*[p6]",
				},
			},
		},
		{
			index = 281, -- number
			id = 131, -- jump [J131]
			fromLocationId = 17, -- from[L17]
			toLocationId = 19, -- to[L19]
			formulaToPass = "[p5]>=0 and [p5]<=360*[p6]",
		},
		{
			index = 282, -- number
			id = 296, -- jump [J296]
			fromLocationId = 120, -- from[L120]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+121",
				},
			},
		},
		{
			index = 283, -- number
			id = 300, -- jump [J300]
			fromLocationId = 123, -- from[L123]
			toLocationId = 124, -- to[L124]
		},
		{
			index = 284, -- number
			id = 299, -- jump [J299]
			fromLocationId = 122, -- from[L122]
			toLocationId = 123, -- to[L123]
		},
		{
			index = 285, -- number
			id = 306, -- jump [J306]
			fromLocationId = 128, -- from[L128]
			toLocationId = 129, -- to[L129]
		},
		{
			index = 286, -- number
			id = 305, -- jump [J305]
			fromLocationId = 127, -- from[L127]
			toLocationId = 128, -- to[L128]
		},
		{
			index = 287, -- number
			id = 315, -- jump [J315]
			fromLocationId = 135, -- from[L135]
			toLocationId = 136, -- to[L136]
		},
		{
			index = 288, -- number
			id = 314, -- jump [J314]
			fromLocationId = 134, -- from[L134]
			toLocationId = 135, -- to[L135]
		},
		{
			index = 289, -- number
			id = 326, -- jump [J326]
			fromLocationId = 144, -- from[L144]
			toLocationId = 145, -- to[L145]
		},
		{
			index = 290, -- number
			id = 325, -- jump [J325]
			fromLocationId = 143, -- from[L143]
			toLocationId = 144, -- to[L144]
		},
		{
			index = 291, -- number
			id = 339, -- jump [J339]
			fromLocationId = 155, -- from[L155]
			toLocationId = 156, -- to[L156]
		},
		{
			index = 292, -- number
			id = 338, -- jump [J338]
			fromLocationId = 154, -- from[L154]
			toLocationId = 155, -- to[L155]
		},
		{
			index = 293, -- number
			id = 351, -- jump [J351]
			fromLocationId = 165, -- from[L165]
			toLocationId = 166, -- to[L166]
		},
		{
			index = 294, -- number
			id = 350, -- jump [J350]
			fromLocationId = 164, -- from[L164]
			toLocationId = 165, -- to[L165]
		},
		{
			index = 295, -- number
			id = 360, -- jump [J360]
			fromLocationId = 173, -- from[L173]
			toLocationId = 174, -- to[L174]
		},
		{
			index = 296, -- number
			id = 359, -- jump [J359]
			fromLocationId = 172, -- from[L172]
			toLocationId = 173, -- to[L173]
		},
		{
			index = 297, -- number
			id = 368, -- jump [J368]
			fromLocationId = 179, -- from[L179]
			toLocationId = 180, -- to[L180]
		},
		{
			index = 298, -- number
			id = 367, -- jump [J367]
			fromLocationId = 178, -- from[L178]
			toLocationId = 179, -- to[L179]
		},
		{
			index = 299, -- number
			id = 381, -- jump [J381]
			fromLocationId = 188, -- from[L188]
			toLocationId = 189, -- to[L189]
		},
		{
			index = 300, -- number
			id = 380, -- jump [J380]
			fromLocationId = 187, -- from[L187]
			toLocationId = 188, -- to[L188]
		},
		{
			index = 301, -- number
			id = 128, -- jump [J128]
			fromLocationId = 16, -- from[L16]
			toLocationId = 17, -- to[L17]
		},
		{
			index = 302, -- number
			id = 393, -- jump [J393]
			fromLocationId = 198, -- from[L198]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+199",
				},
			},
		},
		{
			index = 303, -- number
			id = 397, -- jump [J397]
			fromLocationId = 201, -- from[L201]
			toLocationId = 202, -- to[L202]
		},
		{
			index = 304, -- number
			id = 396, -- jump [J396]
			fromLocationId = 200, -- from[L200]
			toLocationId = 201, -- to[L201]
		},
		{
			index = 305, -- number
			id = 405, -- jump [J405]
			fromLocationId = 207, -- from[L207]
			toLocationId = 208, -- to[L208]
		},
		{
			index = 306, -- number
			id = 404, -- jump [J404]
			fromLocationId = 206, -- from[L206]
			toLocationId = 207, -- to[L207]
		},
		{
			index = 307, -- number
			id = 410, -- jump [J410]
			fromLocationId = 211, -- from[L211]
			toLocationId = 212, -- to[L212]
		},
		{
			index = 308, -- number
			id = 409, -- jump [J409]
			fromLocationId = 210, -- from[L210]
			toLocationId = 211, -- to[L211]
		},
		{
			index = 309, -- number
			id = 424, -- jump [J424]
			fromLocationId = 220, -- from[L220]
			toLocationId = 221, -- to[L221]
		},
		{
			index = 310, -- number
			id = 423, -- jump [J423]
			fromLocationId = 219, -- from[L219]
			toLocationId = 220, -- to[L220]
		},
		{
			index = 311, -- number
			id = 437, -- jump [J437]
			fromLocationId = 228, -- from[L228]
			toLocationId = 229, -- to[L229]
		},
		{
			index = 312, -- number
			id = 436, -- jump [J436]
			fromLocationId = 227, -- from[L227]
			toLocationId = 228, -- to[L228]
		},
		{
			index = 313, -- number
			id = 443, -- jump [J443]
			fromLocationId = 233, -- from[L233]
			toLocationId = 234, -- to[L234]
		},
		{
			index = 314, -- number
			id = 442, -- jump [J442]
			fromLocationId = 232, -- from[L232]
			toLocationId = 233, -- to[L233]
		},
		{
			index = 315, -- number
			id = 475, -- jump [J475]
			fromLocationId = 251, -- from[L251]
			toLocationId = 239, -- to[L239]
			text = "На сегодня достаточно",
			paramsChanges = { -- amount: 56
				{
					index = "[p2]",
					changingFormula = "[p2] + 2*[p3]",
				},
			},
		},
		{
			index = 316, -- number
			id = 476, -- jump [J476]
			fromLocationId = 251, -- from[L251]
			toLocationId = 238, -- to[L238]
			text = "Сыграем ещё разок?",
		},
		{
			index = 317, -- number
			id = 477, -- jump [J477]
			fromLocationId = 252, -- from[L252]
			toLocationId = 239, -- to[L239]
			text = "На сегодня достаточно",
		},
		{
			index = 318, -- number
			id = 478, -- jump [J478]
			fromLocationId = 252, -- from[L252]
			toLocationId = 238, -- to[L238]
			text = "Сыграем ещё разок?",
		},
		{
			index = 319, -- number
			id = 479, -- jump [J479]
			fromLocationId = 253, -- from[L253]
			toLocationId = 255, -- to[L255]
			text = "Задать расход топлива",
		},
		{
			index = 320, -- number
			id = 480, -- jump [J480]
			fromLocationId = 253, -- from[L253]
			toLocationId = 257, -- to[L257]
			text = "Задать время расхода",
		},
		{
			index = 321, -- number
			id = 481, -- jump [J481]
			fromLocationId = 253, -- from[L253]
			toLocationId = 254, -- to[L254]
			text = "Реверс тяги",
			paramsChanges = { -- amount: 56
				{
					index = "[p55]",
					changingFormula = "180-[p55]",
				},
			},
		},
		{
			index = 322, -- number
			id = 482, -- jump [J482]
			fromLocationId = 253, -- from[L253]
			toLocationId = 239, -- to[L239]
			text = "Прервать игру",
		},
		{
			index = 323, -- number
			id = 483, -- jump [J483]
			fromLocationId = 253, -- from[L253]
			toLocationId = 235, -- to[L235]
			text = "Применить",
			formulaToPass = "[p54]>0 and [p53]*[p42]<=[p41]",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p55]",
				},
				{
					index = "[p6]",
					changingFormula = "1",
				},
				{
					index = "[p7]",
					changingFormula = "[p54]",
				},
				{
					index = "[p8]",
					changingFormula = "1",
				},
				{
					index = "[p9]",
					changingFormula = "[p53]",
				},
				{
					index = "[p10]",
					changingFormula = "1",
				},
				{
					index = "[p11]",
					changingFormula = "[p5]",
				},
				{
					index = "[p12]",
					changingFormula = "[p6]",
				},
			},
		},
		{
			index = 324, -- number
			id = 500, -- jump [J500]
			fromLocationId = 263, -- from[L263]
			toLocationId = 266, -- to[L266]
			text = "Задать расход топлива",
		},
		{
			index = 325, -- number
			id = 501, -- jump [J501]
			fromLocationId = 263, -- from[L263]
			toLocationId = 268, -- to[L268]
			text = "Задать время расхода",
		},
		{
			index = 326, -- number
			id = 502, -- jump [J502]
			fromLocationId = 263, -- from[L263]
			toLocationId = 265, -- to[L265]
			text = "Задать угол",
		},
		{
			index = 327, -- number
			id = 503, -- jump [J503]
			fromLocationId = 263, -- from[L263]
			toLocationId = 235, -- to[L235]
			text = "Применить",
			formulaToPass = "[p54]>0 and [p53]*[p42]<=[p41]",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p55]",
				},
				{
					index = "[p6]",
					changingFormula = "1",
				},
				{
					index = "[p7]",
					changingFormula = "[p54]",
				},
				{
					index = "[p8]",
					changingFormula = "1",
				},
				{
					index = "[p9]",
					changingFormula = "[p53]",
				},
				{
					index = "[p10]",
					changingFormula = "1",
				},
				{
					index = "[p11]",
					changingFormula = "[p5]",
				},
				{
					index = "[p12]",
					changingFormula = "[p6]",
				},
			},
		},
		{
			index = 328, -- number
			id = 448, -- jump [J448]
			fromLocationId = 235, -- from[L235]
			toLocationId = 82, -- to[L82]
			formulaToPass = "[p4] mod 100 = 28",
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "[p4] div 100",
				},
			},
		},
		{
			index = 329, -- number
			id = 449, -- jump [J449]
			fromLocationId = 235, -- from[L235]
			toLocationId = 86, -- to[L86]
			formulaToPass = "[p4] mod 100 = 32",
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "[p4] div 100",
				},
			},
		},
		{
			index = 330, -- number
			id = 229, -- jump [J229]
			fromLocationId = 68, -- from[L68]
			toLocationId = 70, -- to[L70]
			priority = 10.0,
			formulaToPass = "[p6]=[p8]",
		},
		{
			index = 331, -- number
			id = 230, -- jump [J230]
			fromLocationId = 68, -- from[L68]
			toLocationId = 69, -- to[L69]
			formulaToPass = "[p6]<>[p8]",
		},
		{
			index = 332, -- number
			id = 188, -- jump [J188]
			fromLocationId = 38, -- from[L38]
			toLocationId = 39, -- to[L39]
		},
		{
			index = 333, -- number
			id = 195, -- jump [J195]
			fromLocationId = 44, -- from[L44]
			toLocationId = 46, -- to[L46]
			priority = 10.0,
			formulaToPass = "[p6]=[p8]",
		},
		{
			index = 334, -- number
			id = 196, -- jump [J196]
			fromLocationId = 44, -- from[L44]
			toLocationId = 45, -- to[L45]
			formulaToPass = "[p6]<>[p8]",
		},
		{
			index = 335, -- number
			id = 203, -- jump [J203]
			fromLocationId = 50, -- from[L50]
			toLocationId = 27, -- to[L27]
			priority = 10.0,
			formulaToPass = "[p5]<0",
		},
		{
			index = 336, -- number
			id = 204, -- jump [J204]
			fromLocationId = 50, -- from[L50]
			toLocationId = 51, -- to[L51]
			priority = 10.0,
			formulaToPass = "[p5]=0",
		},
		{
			index = 337, -- number
			id = 205, -- jump [J205]
			fromLocationId = 50, -- from[L50]
			toLocationId = 51, -- to[L51]
			priority = 10.0,
			formulaToPass = "[p5]=1 and [p6]=1",
		},
		{
			index = 338, -- number
			id = 206, -- jump [J206]
			fromLocationId = 50, -- from[L50]
			toLocationId = 5, -- to[L5]
			formulaToPass = "[p5]>1 or [p6]<>1",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+51",
				},
			},
		},
		{
			index = 339, -- number
			id = 209, -- jump [J209]
			fromLocationId = 53, -- from[L53]
			toLocationId = 55, -- to[L55]
			priority = 10.0,
			formulaToPass = "[p6]=[p8]",
		},
		{
			index = 340, -- number
			id = 210, -- jump [J210]
			fromLocationId = 53, -- from[L53]
			toLocationId = 54, -- to[L54]
			formulaToPass = "[p6]<>[p8]",
		},
		{
			index = 341, -- number
			id = 217, -- jump [J217]
			fromLocationId = 59, -- from[L59]
			toLocationId = 60, -- to[L60]
		},
		{
			index = 342, -- number
			id = 237, -- jump [J237]
			fromLocationId = 74, -- from[L74]
			toLocationId = 76, -- to[L76]
			priority = 10.0,
			formulaToPass = "[p5]<0",
		},
		{
			index = 343, -- number
			id = 238, -- jump [J238]
			fromLocationId = 74, -- from[L74]
			toLocationId = 75, -- to[L75]
			formulaToPass = "[p5]>=0",
		},
		{
			index = 344, -- number
			id = 262, -- jump [J262]
			fromLocationId = 94, -- from[L94]
			toLocationId = 95, -- to[L95]
		},
		{
			index = 345, -- number
			id = 273, -- jump [J273]
			fromLocationId = 103, -- from[L103]
			toLocationId = 27, -- to[L27]
			priority = 10.0,
			formulaToPass = "[p5]=0",
		},
		{
			index = 346, -- number
			id = 274, -- jump [J274]
			fromLocationId = 103, -- from[L103]
			toLocationId = 104, -- to[L104]
			priority = 10.0,
			formulaToPass = "[p5]<0",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "-[p5]",
				},
				{
					index = "[p7]",
					changingFormula = "-[p7]",
				},
			},
		},
		{
			index = 347, -- number
			id = 275, -- jump [J275]
			fromLocationId = 103, -- from[L103]
			toLocationId = 104, -- to[L104]
			formulaToPass = "[p5]>0",
		},
		{
			index = 348, -- number
			id = 281, -- jump [J281]
			fromLocationId = 108, -- from[L108]
			toLocationId = 109, -- to[L109]
		},
		{
			index = 349, -- number
			id = 287, -- jump [J287]
			fromLocationId = 113, -- from[L113]
			toLocationId = 114, -- to[L114]
		},
		{
			index = 350, -- number
			id = 132, -- jump [J132]
			fromLocationId = 18, -- from[L18]
			toLocationId = 17, -- to[L17]
		},
		{
			index = 351, -- number
			id = 133, -- jump [J133]
			fromLocationId = 19, -- from[L19]
			toLocationId = 20, -- to[L20]
			priority = 10.0,
			formulaToPass = "[p5]>180*[p6]",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]-180*[p6]",
				},
				{
					index = "[p47]",
					changingFormula = "-1",
				},
			},
		},
		{
			index = 352, -- number
			id = 134, -- jump [J134]
			fromLocationId = 19, -- from[L19]
			toLocationId = 20, -- to[L20]
			formulaToPass = "[p5]<=180*[p6]",
			paramsChanges = { -- amount: 56
				{
					index = "[p47]",
					changingFormula = "1",
				},
			},
		},
		{
			index = 353, -- number
			id = 301, -- jump [J301]
			fromLocationId = 124, -- from[L124]
			toLocationId = 125, -- to[L125]
		},
		{
			index = 354, -- number
			id = 307, -- jump [J307]
			fromLocationId = 129, -- from[L129]
			toLocationId = 130, -- to[L130]
		},
		{
			index = 355, -- number
			id = 316, -- jump [J316]
			fromLocationId = 136, -- from[L136]
			toLocationId = 137, -- to[L137]
		},
		{
			index = 356, -- number
			id = 327, -- jump [J327]
			fromLocationId = 145, -- from[L145]
			toLocationId = 146, -- to[L146]
		},
		{
			index = 357, -- number
			id = 340, -- jump [J340]
			fromLocationId = 156, -- from[L156]
			toLocationId = 157, -- to[L157]
		},
		{
			index = 358, -- number
			id = 352, -- jump [J352]
			fromLocationId = 166, -- from[L166]
			toLocationId = 167, -- to[L167]
		},
		{
			index = 359, -- number
			id = 361, -- jump [J361]
			fromLocationId = 174, -- from[L174]
			toLocationId = 176, -- to[L176]
			priority = 10.0,
			formulaToPass = "[p6]=[p8]",
		},
		{
			index = 360, -- number
			id = 362, -- jump [J362]
			fromLocationId = 174, -- from[L174]
			toLocationId = 175, -- to[L175]
			formulaToPass = "[p6]<>[p8]",
		},
		{
			index = 361, -- number
			id = 369, -- jump [J369]
			fromLocationId = 180, -- from[L180]
			toLocationId = 181, -- to[L181]
		},
		{
			index = 362, -- number
			id = 382, -- jump [J382]
			fromLocationId = 189, -- from[L189]
			toLocationId = 190, -- to[L190]
		},
		{
			index = 363, -- number
			id = 398, -- jump [J398]
			fromLocationId = 202, -- from[L202]
			toLocationId = 204, -- to[L204]
			priority = 10.0,
			formulaToPass = "[p6]=[p8]",
		},
		{
			index = 364, -- number
			id = 399, -- jump [J399]
			fromLocationId = 202, -- from[L202]
			toLocationId = 203, -- to[L203]
			formulaToPass = "[p6]<>[p8]",
		},
		{
			index = 365, -- number
			id = 406, -- jump [J406]
			fromLocationId = 208, -- from[L208]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+209",
				},
			},
		},
		{
			index = 366, -- number
			id = 411, -- jump [J411]
			fromLocationId = 212, -- from[L212]
			toLocationId = 213, -- to[L213]
		},
		{
			index = 367, -- number
			id = 425, -- jump [J425]
			fromLocationId = 221, -- from[L221]
			toLocationId = 222, -- to[L222]
			formulaToPass = "[p50]=0",
		},
		{
			index = 368, -- number
			id = 426, -- jump [J426]
			fromLocationId = 221, -- from[L221]
			toLocationId = 223, -- to[L223]
			formulaToPass = "[p50]=1",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p5]*10",
				},
			},
		},
		{
			index = 369, -- number
			id = 427, -- jump [J427]
			fromLocationId = 221, -- from[L221]
			toLocationId = 223, -- to[L223]
			formulaToPass = "[p50]=2",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 370, -- number
			id = 438, -- jump [J438]
			fromLocationId = 229, -- from[L229]
			toLocationId = 230, -- to[L230]
		},
		{
			index = 371, -- number
			id = 444, -- jump [J444]
			fromLocationId = 234, -- from[L234]
			toLocationId = 40, -- to[L40]
			formulaToPass = "[p4] mod 100 = 7",
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "[p4] div 100",
				},
			},
		},
		{
			index = 372, -- number
			id = 445, -- jump [J445]
			fromLocationId = 234, -- from[L234]
			toLocationId = 139, -- to[L139]
			formulaToPass = "[p4] mod 100 = 56",
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "[p4] div 100",
				},
			},
		},
		{
			index = 373, -- number
			id = 446, -- jump [J446]
			fromLocationId = 234, -- from[L234]
			toLocationId = 150, -- to[L150]
			formulaToPass = "[p4] mod 100 = 62",
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "[p4] div 100",
				},
			},
		},
		{
			index = 374, -- number
			id = 447, -- jump [J447]
			fromLocationId = 234, -- from[L234]
			toLocationId = 159, -- to[L159]
			formulaToPass = "[p4] mod 100 = 66",
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "[p4] div 100",
				},
			},
		},
		{
			index = 375, -- number
			id = 485, -- jump [J485]
			fromLocationId = 255, -- from[L255]
			toLocationId = 256, -- to[L256]
			text = "Расход топлива: +1",
			paramsChanges = { -- amount: 56
				{
					index = "[p53]",
					changingFormula = "[p53]+1",
				},
			},
		},
		{
			index = 376, -- number
			id = 486, -- jump [J486]
			fromLocationId = 255, -- from[L255]
			toLocationId = 256, -- to[L256]
			text = "Расход топлива: +10",
			paramsChanges = { -- amount: 56
				{
					index = "[p53]",
					changingFormula = "[p53]+10",
				},
			},
		},
		{
			index = 377, -- number
			id = 487, -- jump [J487]
			fromLocationId = 255, -- from[L255]
			toLocationId = 256, -- to[L256]
			text = "Сбросить",
			paramsChanges = { -- amount: 56
				{
					index = "[p53]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 378, -- number
			id = 488, -- jump [J488]
			fromLocationId = 255, -- from[L255]
			toLocationId = 253, -- to[L253]
			text = "Назад",
		},
		{
			index = 379, -- number
			id = 490, -- jump [J490]
			fromLocationId = 257, -- from[L257]
			toLocationId = 258, -- to[L258]
			text = "Время расхода: +1",
			paramsChanges = { -- amount: 56
				{
					index = "[p54]",
					changingFormula = "[p54]+1",
				},
			},
		},
		{
			index = 380, -- number
			id = 491, -- jump [J491]
			fromLocationId = 257, -- from[L257]
			toLocationId = 258, -- to[L258]
			text = "Время расхода: +10",
			paramsChanges = { -- amount: 56
				{
					index = "[p54]",
					changingFormula = "[p54]+10",
				},
			},
		},
		{
			index = 381, -- number
			id = 492, -- jump [J492]
			fromLocationId = 257, -- from[L257]
			toLocationId = 258, -- to[L258]
			text = "Сбросить",
			paramsChanges = { -- amount: 56
				{
					index = "[p54]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 382, -- number
			id = 493, -- jump [J493]
			fromLocationId = 257, -- from[L257]
			toLocationId = 253, -- to[L253]
			text = "Назад",
		},
		{
			index = 383, -- number
			id = 484, -- jump [J484]
			fromLocationId = 254, -- from[L254]
			toLocationId = 253, -- to[L253]
		},
		{
			index = 384, -- number
			id = 513, -- jump [J513]
			fromLocationId = 266, -- from[L266]
			toLocationId = 267, -- to[L267]
			text = "Расход топлива: +1",
			paramsChanges = { -- amount: 56
				{
					index = "[p53]",
					changingFormula = "[p53]+1",
				},
			},
		},
		{
			index = 385, -- number
			id = 514, -- jump [J514]
			fromLocationId = 266, -- from[L266]
			toLocationId = 267, -- to[L267]
			text = "Расход топлива: +10",
			paramsChanges = { -- amount: 56
				{
					index = "[p53]",
					changingFormula = "[p53]+10",
				},
			},
		},
		{
			index = 386, -- number
			id = 515, -- jump [J515]
			fromLocationId = 266, -- from[L266]
			toLocationId = 267, -- to[L267]
			text = "Сбросить",
			paramsChanges = { -- amount: 56
				{
					index = "[p53]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 387, -- number
			id = 516, -- jump [J516]
			fromLocationId = 266, -- from[L266]
			toLocationId = 263, -- to[L263]
			text = "Назад",
		},
		{
			index = 388, -- number
			id = 518, -- jump [J518]
			fromLocationId = 268, -- from[L268]
			toLocationId = 269, -- to[L269]
			text = "Время расхода: +1",
			paramsChanges = { -- amount: 56
				{
					index = "[p54]",
					changingFormula = "[p54]+1",
				},
			},
		},
		{
			index = 389, -- number
			id = 519, -- jump [J519]
			fromLocationId = 268, -- from[L268]
			toLocationId = 269, -- to[L269]
			text = "Время расхода: +10",
			paramsChanges = { -- amount: 56
				{
					index = "[p54]",
					changingFormula = "[p54]+10",
				},
			},
		},
		{
			index = 390, -- number
			id = 520, -- jump [J520]
			fromLocationId = 268, -- from[L268]
			toLocationId = 269, -- to[L269]
			text = "Сбросить",
			paramsChanges = { -- amount: 56
				{
					index = "[p54]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 391, -- number
			id = 521, -- jump [J521]
			fromLocationId = 268, -- from[L268]
			toLocationId = 263, -- to[L263]
			text = "Назад",
		},
		{
			index = 392, -- number
			id = 505, -- jump [J505]
			fromLocationId = 265, -- from[L265]
			toLocationId = 259, -- to[L259]
			text = "Угол: 0 градусов",
			paramsChanges = { -- amount: 56
				{
					index = "[p55]",
					changingFormula = "0",
				},
			},
		},
		{
			index = 393, -- number
			id = 506, -- jump [J506]
			fromLocationId = 265, -- from[L265]
			toLocationId = 259, -- to[L259]
			text = "Угол: 45 градусов",
			paramsChanges = { -- amount: 56
				{
					index = "[p55]",
					changingFormula = "45",
				},
			},
		},
		{
			index = 394, -- number
			id = 507, -- jump [J507]
			fromLocationId = 265, -- from[L265]
			toLocationId = 259, -- to[L259]
			text = "Угол: -45 градусов",
			paramsChanges = { -- amount: 56
				{
					index = "[p55]",
					changingFormula = "-45",
				},
			},
		},
		{
			index = 395, -- number
			id = 508, -- jump [J508]
			fromLocationId = 265, -- from[L265]
			toLocationId = 259, -- to[L259]
			text = "Угол: 90 градусов",
			paramsChanges = { -- amount: 56
				{
					index = "[p55]",
					changingFormula = "90",
				},
			},
		},
		{
			index = 396, -- number
			id = 509, -- jump [J509]
			fromLocationId = 265, -- from[L265]
			toLocationId = 259, -- to[L259]
			text = "Угол: -90 градусов",
			paramsChanges = { -- amount: 56
				{
					index = "[p55]",
					changingFormula = "-90",
				},
			},
		},
		{
			index = 397, -- number
			id = 510, -- jump [J510]
			fromLocationId = 265, -- from[L265]
			toLocationId = 259, -- to[L259]
			text = "Угол: 135 градусов",
			paramsChanges = { -- amount: 56
				{
					index = "[p55]",
					changingFormula = "135",
				},
			},
		},
		{
			index = 398, -- number
			id = 511, -- jump [J511]
			fromLocationId = 265, -- from[L265]
			toLocationId = 259, -- to[L259]
			text = "Угол: -135 градусов",
			paramsChanges = { -- amount: 56
				{
					index = "[p55]",
					changingFormula = "-135",
				},
			},
		},
		{
			index = 399, -- number
			id = 512, -- jump [J512]
			fromLocationId = 265, -- from[L265]
			toLocationId = 259, -- to[L259]
			text = "Угол: 180 градусов",
			paramsChanges = { -- amount: 56
				{
					index = "[p55]",
					changingFormula = "180",
				},
			},
		},
		{
			index = 400, -- number
			id = 247, -- jump [J247]
			fromLocationId = 82, -- from[L82]
			toLocationId = 83, -- to[L83]
		},
		{
			index = 401, -- number
			id = 251, -- jump [J251]
			fromLocationId = 86, -- from[L86]
			toLocationId = 87, -- to[L87]
		},
		{
			index = 402, -- number
			id = 232, -- jump [J232]
			fromLocationId = 70, -- from[L70]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+71",
				},
			},
		},
		{
			index = 403, -- number
			id = 231, -- jump [J231]
			fromLocationId = 69, -- from[L69]
			toLocationId = 70, -- to[L70]
		},
		{
			index = 404, -- number
			id = 189, -- jump [J189]
			fromLocationId = 39, -- from[L39]
			toLocationId = 192, -- to[L192]
		},
		{
			index = 405, -- number
			id = 198, -- jump [J198]
			fromLocationId = 46, -- from[L46]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+47",
				},
			},
		},
		{
			index = 406, -- number
			id = 197, -- jump [J197]
			fromLocationId = 45, -- from[L45]
			toLocationId = 46, -- to[L46]
		},
		{
			index = 407, -- number
			id = 47, -- jump [J47]
			fromLocationId = 5, -- from[L5]
			toLocationId = 6, -- to[L6]
		},
		{
			index = 408, -- number
			id = 212, -- jump [J212]
			fromLocationId = 55, -- from[L55]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+56",
				},
			},
		},
		{
			index = 409, -- number
			id = 211, -- jump [J211]
			fromLocationId = 54, -- from[L54]
			toLocationId = 55, -- to[L55]
		},
		{
			index = 410, -- number
			id = 218, -- jump [J218]
			fromLocationId = 60, -- from[L60]
			toLocationId = 184, -- to[L184]
		},
		{
			index = 411, -- number
			id = 240, -- jump [J240]
			fromLocationId = 76, -- from[L76]
			toLocationId = 77, -- to[L77]
		},
		{
			index = 412, -- number
			id = 239, -- jump [J239]
			fromLocationId = 75, -- from[L75]
			toLocationId = 80, -- to[L80]
		},
		{
			index = 413, -- number
			id = 263, -- jump [J263]
			fromLocationId = 95, -- from[L95]
			toLocationId = 96, -- to[L96]
		},
		{
			index = 414, -- number
			id = 276, -- jump [J276]
			fromLocationId = 104, -- from[L104]
			toLocationId = 1, -- to[L1]
			formulaToPass = "[p6]<>0",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+105",
				},
			},
		},
		{
			index = 415, -- number
			id = 282, -- jump [J282]
			fromLocationId = 109, -- from[L109]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+110",
				},
			},
		},
		{
			index = 416, -- number
			id = 288, -- jump [J288]
			fromLocationId = 114, -- from[L114]
			toLocationId = 115, -- to[L115]
		},
		{
			index = 417, -- number
			id = 135, -- jump [J135]
			fromLocationId = 20, -- from[L20]
			toLocationId = 21, -- to[L21]
		},
		{
			index = 418, -- number
			id = 302, -- jump [J302]
			fromLocationId = 125, -- from[L125]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+126",
				},
			},
		},
		{
			index = 419, -- number
			id = 308, -- jump [J308]
			fromLocationId = 130, -- from[L130]
			toLocationId = 132, -- to[L132]
			priority = 10.0,
			formulaToPass = "[p6]=[p8]",
		},
		{
			index = 420, -- number
			id = 309, -- jump [J309]
			fromLocationId = 130, -- from[L130]
			toLocationId = 131, -- to[L131]
			formulaToPass = "[p6]<>[p8]",
		},
		{
			index = 421, -- number
			id = 317, -- jump [J317]
			fromLocationId = 137, -- from[L137]
			toLocationId = 138, -- to[L138]
		},
		{
			index = 422, -- number
			id = 328, -- jump [J328]
			fromLocationId = 146, -- from[L146]
			toLocationId = 147, -- to[L147]
		},
		{
			index = 423, -- number
			id = 341, -- jump [J341]
			fromLocationId = 157, -- from[L157]
			toLocationId = 158, -- to[L158]
		},
		{
			index = 424, -- number
			id = 353, -- jump [J353]
			fromLocationId = 167, -- from[L167]
			toLocationId = 168, -- to[L168]
		},
		{
			index = 425, -- number
			id = 364, -- jump [J364]
			fromLocationId = 176, -- from[L176]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+177",
				},
			},
		},
		{
			index = 426, -- number
			id = 363, -- jump [J363]
			fromLocationId = 175, -- from[L175]
			toLocationId = 176, -- to[L176]
		},
		{
			index = 427, -- number
			id = 370, -- jump [J370]
			fromLocationId = 181, -- from[L181]
			toLocationId = 183, -- to[L183]
			priority = 10.0,
			formulaToPass = "[p5]<0",
		},
		{
			index = 428, -- number
			id = 371, -- jump [J371]
			fromLocationId = 181, -- from[L181]
			toLocationId = 182, -- to[L182]
			formulaToPass = "[p5]>=0",
		},
		{
			index = 429, -- number
			id = 383, -- jump [J383]
			fromLocationId = 190, -- from[L190]
			toLocationId = 191, -- to[L191]
		},
		{
			index = 430, -- number
			id = 401, -- jump [J401]
			fromLocationId = 204, -- from[L204]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+205",
				},
			},
		},
		{
			index = 431, -- number
			id = 400, -- jump [J400]
			fromLocationId = 203, -- from[L203]
			toLocationId = 204, -- to[L204]
		},
		{
			index = 432, -- number
			id = 412, -- jump [J412]
			fromLocationId = 213, -- from[L213]
			toLocationId = 40, -- to[L40]
			formulaToPass = "[p4] mod 100 = 7",
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "[p4] div 100",
				},
			},
		},
		{
			index = 433, -- number
			id = 413, -- jump [J413]
			fromLocationId = 213, -- from[L213]
			toLocationId = 139, -- to[L139]
			formulaToPass = "[p4] mod 100 = 56",
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "[p4] div 100",
				},
			},
		},
		{
			index = 434, -- number
			id = 414, -- jump [J414]
			fromLocationId = 213, -- from[L213]
			toLocationId = 150, -- to[L150]
			formulaToPass = "[p4] mod 100 = 62",
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "[p4] div 100",
				},
			},
		},
		{
			index = 435, -- number
			id = 415, -- jump [J415]
			fromLocationId = 213, -- from[L213]
			toLocationId = 159, -- to[L159]
			formulaToPass = "[p4] mod 100 = 66",
			paramsChanges = { -- amount: 56
				{
					index = "[p4]",
					changingFormula = "[p4] div 100",
				},
			},
		},
		{
			index = 436, -- number
			id = 428, -- jump [J428]
			fromLocationId = 222, -- from[L222]
			toLocationId = 223, -- to[L223]
		},
		{
			index = 437, -- number
			id = 429, -- jump [J429]
			fromLocationId = 223, -- from[L223]
			toLocationId = 224, -- to[L224]
		},
		{
			index = 438, -- number
			id = 439, -- jump [J439]
			fromLocationId = 230, -- from[L230]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+231",
				},
			},
		},
		{
			index = 439, -- number
			id = 190, -- jump [J190]
			fromLocationId = 40, -- from[L40]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+41",
				},
			},
		},
		{
			index = 440, -- number
			id = 319, -- jump [J319]
			fromLocationId = 139, -- from[L139]
			toLocationId = 141, -- to[L141]
			priority = 10.0,
			formulaToPass = "[p6]=[p8]",
		},
		{
			index = 441, -- number
			id = 320, -- jump [J320]
			fromLocationId = 139, -- from[L139]
			toLocationId = 140, -- to[L140]
			formulaToPass = "[p6]<>[p8]",
		},
		{
			index = 442, -- number
			id = 332, -- jump [J332]
			fromLocationId = 150, -- from[L150]
			toLocationId = 152, -- to[L152]
			priority = 10.0,
			formulaToPass = "[p6]=[p8]",
		},
		{
			index = 443, -- number
			id = 333, -- jump [J333]
			fromLocationId = 150, -- from[L150]
			toLocationId = 151, -- to[L151]
			formulaToPass = "[p6]<>[p8]",
		},
		{
			index = 444, -- number
			id = 343, -- jump [J343]
			fromLocationId = 159, -- from[L159]
			toLocationId = 160, -- to[L160]
		},
		{
			index = 445, -- number
			id = 489, -- jump [J489]
			fromLocationId = 256, -- from[L256]
			toLocationId = 255, -- to[L255]
		},
		{
			index = 446, -- number
			id = 494, -- jump [J494]
			fromLocationId = 258, -- from[L258]
			toLocationId = 257, -- to[L257]
		},
		{
			index = 447, -- number
			id = 517, -- jump [J517]
			fromLocationId = 267, -- from[L267]
			toLocationId = 266, -- to[L266]
		},
		{
			index = 448, -- number
			id = 522, -- jump [J522]
			fromLocationId = 269, -- from[L269]
			toLocationId = 268, -- to[L268]
		},
		{
			index = 449, -- number
			id = 248, -- jump [J248]
			fromLocationId = 83, -- from[L83]
			toLocationId = 87, -- to[L87]
		},
		{
			index = 450, -- number
			id = 252, -- jump [J252]
			fromLocationId = 87, -- from[L87]
			toLocationId = 88, -- to[L88]
		},
		{
			index = 451, -- number
			id = 385, -- jump [J385]
			fromLocationId = 192, -- from[L192]
			toLocationId = 193, -- to[L193]
		},
		{
			index = 452, -- number
			id = 48, -- jump [J48]
			fromLocationId = 6, -- from[L6]
			toLocationId = 7, -- to[L7]
			formulaToPass = "[p45]>=[p46]",
			paramsChanges = { -- amount: 56
				{
					index = "[p45]",
					changingFormula = "[p45]-[p46]",
				},
				{
					index = "[p46]",
					changingFormula = "[p46]+2",
				},
				{
					index = "[p47]",
					changingFormula = "[p47]+1",
				},
			},
		},
		{
			index = 453, -- number
			id = 49, -- jump [J49]
			fromLocationId = 6, -- from[L6]
			toLocationId = 8, -- to[L8]
			formulaToPass = "[p45]<[p46]",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "[p47]",
				},
				{
					index = "[p6]",
					changingFormula = "1",
				},
			},
		},
		{
			index = 454, -- number
			id = 374, -- jump [J374]
			fromLocationId = 184, -- from[L184]
			toLocationId = 27, -- to[L27]
			priority = 10.0,
			formulaToPass = "[p5]=0",
		},
		{
			index = 455, -- number
			id = 375, -- jump [J375]
			fromLocationId = 184, -- from[L184]
			toLocationId = 185, -- to[L185]
			priority = 10.0,
			formulaToPass = "[p5]<0",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "-[p5]",
				},
				{
					index = "[p7]",
					changingFormula = "-[p7]",
				},
			},
		},
		{
			index = 456, -- number
			id = 376, -- jump [J376]
			fromLocationId = 184, -- from[L184]
			toLocationId = 185, -- to[L185]
			formulaToPass = "[p5]>0",
		},
		{
			index = 457, -- number
			id = 241, -- jump [J241]
			fromLocationId = 77, -- from[L77]
			toLocationId = 79, -- to[L79]
			priority = 10.0,
			formulaToPass = "[p5]=0",
		},
		{
			index = 458, -- number
			id = 242, -- jump [J242]
			fromLocationId = 77, -- from[L77]
			toLocationId = 78, -- to[L78]
			formulaToPass = "[p5]<>0",
		},
		{
			index = 459, -- number
			id = 245, -- jump [J245]
			fromLocationId = 80, -- from[L80]
			toLocationId = 81, -- to[L81]
		},
		{
			index = 460, -- number
			id = 264, -- jump [J264]
			fromLocationId = 96, -- from[L96]
			toLocationId = 97, -- to[L97]
		},
		{
			index = 461, -- number
			id = 289, -- jump [J289]
			fromLocationId = 115, -- from[L115]
			toLocationId = 116, -- to[L116]
		},
		{
			index = 462, -- number
			id = 136, -- jump [J136]
			fromLocationId = 21, -- from[L21]
			toLocationId = 22, -- to[L22]
		},
		{
			index = 463, -- number
			id = 311, -- jump [J311]
			fromLocationId = 132, -- from[L132]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+133",
				},
			},
		},
		{
			index = 464, -- number
			id = 310, -- jump [J310]
			fromLocationId = 131, -- from[L131]
			toLocationId = 132, -- to[L132]
		},
		{
			index = 465, -- number
			id = 318, -- jump [J318]
			fromLocationId = 138, -- from[L138]
			toLocationId = 214, -- to[L214]
		},
		{
			index = 466, -- number
			id = 329, -- jump [J329]
			fromLocationId = 147, -- from[L147]
			toLocationId = 148, -- to[L148]
		},
		{
			index = 467, -- number
			id = 342, -- jump [J342]
			fromLocationId = 158, -- from[L158]
			toLocationId = 214, -- to[L214]
		},
		{
			index = 468, -- number
			id = 354, -- jump [J354]
			fromLocationId = 168, -- from[L168]
			toLocationId = 169, -- to[L169]
		},
		{
			index = 469, -- number
			id = 373, -- jump [J373]
			fromLocationId = 183, -- from[L183]
			toLocationId = 184, -- to[L184]
		},
		{
			index = 470, -- number
			id = 372, -- jump [J372]
			fromLocationId = 182, -- from[L182]
			toLocationId = 28, -- to[L28]
		},
		{
			index = 471, -- number
			id = 384, -- jump [J384]
			fromLocationId = 191, -- from[L191]
			toLocationId = 114, -- to[L114]
		},
		{
			index = 472, -- number
			id = 430, -- jump [J430]
			fromLocationId = 224, -- from[L224]
			toLocationId = 27, -- to[L27]
			priority = 10.0,
			formulaToPass = "[p5]=0",
		},
		{
			index = 473, -- number
			id = 431, -- jump [J431]
			fromLocationId = 224, -- from[L224]
			toLocationId = 225, -- to[L225]
			priority = 10.0,
			formulaToPass = "[p5]<0",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "-[p5]",
				},
				{
					index = "[p7]",
					changingFormula = "-[p7]",
				},
			},
		},
		{
			index = 474, -- number
			id = 432, -- jump [J432]
			fromLocationId = 224, -- from[L224]
			toLocationId = 225, -- to[L225]
			formulaToPass = "[p5]>0",
		},
		{
			index = 475, -- number
			id = 322, -- jump [J322]
			fromLocationId = 141, -- from[L141]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+142",
				},
			},
		},
		{
			index = 476, -- number
			id = 321, -- jump [J321]
			fromLocationId = 140, -- from[L140]
			toLocationId = 141, -- to[L141]
		},
		{
			index = 477, -- number
			id = 335, -- jump [J335]
			fromLocationId = 152, -- from[L152]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+153",
				},
			},
		},
		{
			index = 478, -- number
			id = 334, -- jump [J334]
			fromLocationId = 151, -- from[L151]
			toLocationId = 152, -- to[L152]
		},
		{
			index = 479, -- number
			id = 344, -- jump [J344]
			fromLocationId = 160, -- from[L160]
			toLocationId = 162, -- to[L162]
			priority = 10.0,
			formulaToPass = "[p6]=[p8]",
		},
		{
			index = 480, -- number
			id = 345, -- jump [J345]
			fromLocationId = 160, -- from[L160]
			toLocationId = 161, -- to[L161]
			formulaToPass = "[p6]<>[p8]",
		},
		{
			index = 481, -- number
			id = 253, -- jump [J253]
			fromLocationId = 88, -- from[L88]
			toLocationId = 89, -- to[L89]
		},
		{
			index = 482, -- number
			id = 386, -- jump [J386]
			fromLocationId = 193, -- from[L193]
			toLocationId = 194, -- to[L194]
		},
		{
			index = 483, -- number
			id = 50, -- jump [J50]
			fromLocationId = 7, -- from[L7]
			toLocationId = 6, -- to[L6]
		},
		{
			index = 484, -- number
			id = 51, -- jump [J51]
			fromLocationId = 8, -- from[L8]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+9",
				},
			},
		},
		{
			index = 485, -- number
			id = 377, -- jump [J377]
			fromLocationId = 185, -- from[L185]
			toLocationId = 1, -- to[L1]
			formulaToPass = "[p6]<>0",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+186",
				},
			},
		},
		{
			index = 486, -- number
			id = 244, -- jump [J244]
			fromLocationId = 79, -- from[L79]
			toLocationId = 80, -- to[L80]
		},
		{
			index = 487, -- number
			id = 243, -- jump [J243]
			fromLocationId = 78, -- from[L78]
			toLocationId = 84, -- to[L84]
		},
		{
			index = 488, -- number
			id = 246, -- jump [J246]
			fromLocationId = 81, -- from[L81]
			toLocationId = 248, -- to[L248]
		},
		{
			index = 489, -- number
			id = 265, -- jump [J265]
			fromLocationId = 97, -- from[L97]
			toLocationId = 99, -- to[L99]
			priority = 10.0,
			formulaToPass = "[p6]=[p8]",
		},
		{
			index = 490, -- number
			id = 266, -- jump [J266]
			fromLocationId = 97, -- from[L97]
			toLocationId = 98, -- to[L98]
			formulaToPass = "[p6]<>[p8]",
		},
		{
			index = 491, -- number
			id = 290, -- jump [J290]
			fromLocationId = 116, -- from[L116]
			toLocationId = 117, -- to[L117]
		},
		{
			index = 492, -- number
			id = 137, -- jump [J137]
			fromLocationId = 22, -- from[L22]
			toLocationId = 23, -- to[L23]
		},
		{
			index = 493, -- number
			id = 416, -- jump [J416]
			fromLocationId = 214, -- from[L214]
			toLocationId = 215, -- to[L215]
		},
		{
			index = 494, -- number
			id = 330, -- jump [J330]
			fromLocationId = 148, -- from[L148]
			toLocationId = 149, -- to[L149]
		},
		{
			index = 495, -- number
			id = 355, -- jump [J355]
			fromLocationId = 169, -- from[L169]
			toLocationId = 170, -- to[L170]
		},
		{
			index = 496, -- number
			id = 433, -- jump [J433]
			fromLocationId = 225, -- from[L225]
			toLocationId = 1, -- to[L1]
			formulaToPass = "[p6]<>0",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+226",
				},
			},
		},
		{
			index = 497, -- number
			id = 347, -- jump [J347]
			fromLocationId = 162, -- from[L162]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+163",
				},
			},
		},
		{
			index = 498, -- number
			id = 346, -- jump [J346]
			fromLocationId = 161, -- from[L161]
			toLocationId = 162, -- to[L162]
		},
		{
			index = 499, -- number
			id = 254, -- jump [J254]
			fromLocationId = 89, -- from[L89]
			toLocationId = 27, -- to[L27]
			priority = 10.0,
			formulaToPass = "[p5]=0",
		},
		{
			index = 500, -- number
			id = 255, -- jump [J255]
			fromLocationId = 89, -- from[L89]
			toLocationId = 90, -- to[L90]
			priority = 10.0,
			formulaToPass = "[p5]<0",
			paramsChanges = { -- amount: 56
				{
					index = "[p5]",
					changingFormula = "-[p5]",
				},
				{
					index = "[p7]",
					changingFormula = "-[p7]",
				},
			},
		},
		{
			index = 501, -- number
			id = 256, -- jump [J256]
			fromLocationId = 89, -- from[L89]
			toLocationId = 90, -- to[L90]
			formulaToPass = "[p5]>0",
		},
		{
			index = 502, -- number
			id = 387, -- jump [J387]
			fromLocationId = 194, -- from[L194]
			toLocationId = 195, -- to[L195]
		},
		{
			index = 503, -- number
			id = 249, -- jump [J249]
			fromLocationId = 84, -- from[L84]
			toLocationId = 85, -- to[L85]
		},
		{
			index = 504, -- number
			id = 268, -- jump [J268]
			fromLocationId = 99, -- from[L99]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+100",
				},
			},
		},
		{
			index = 505, -- number
			id = 267, -- jump [J267]
			fromLocationId = 98, -- from[L98]
			toLocationId = 99, -- to[L99]
		},
		{
			index = 506, -- number
			id = 291, -- jump [J291]
			fromLocationId = 117, -- from[L117]
			toLocationId = 12, -- to[L12]
			formulaToPass = "1=0",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+118",
				},
			},
		},
		{
			index = 507, -- number
			id = 292, -- jump [J292]
			fromLocationId = 117, -- from[L117]
			toLocationId = 13, -- to[L13]
			formulaToPass = "1=2",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+118",
				},
			},
		},
		{
			index = 508, -- number
			id = 293, -- jump [J293]
			fromLocationId = 117, -- from[L117]
			toLocationId = 118, -- to[L118]
			formulaToPass = "1=1",
		},
		{
			index = 509, -- number
			id = 138, -- jump [J138]
			fromLocationId = 23, -- from[L23]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+24",
				},
			},
		},
		{
			index = 510, -- number
			id = 417, -- jump [J417]
			fromLocationId = 215, -- from[L215]
			toLocationId = 217, -- to[L217]
			priority = 10.0,
			formulaToPass = "[p6]=[p8]",
		},
		{
			index = 511, -- number
			id = 418, -- jump [J418]
			fromLocationId = 215, -- from[L215]
			toLocationId = 216, -- to[L216]
			formulaToPass = "[p6]<>[p8]",
		},
		{
			index = 512, -- number
			id = 331, -- jump [J331]
			fromLocationId = 149, -- from[L149]
			toLocationId = 192, -- to[L192]
		},
		{
			index = 513, -- number
			id = 356, -- jump [J356]
			fromLocationId = 170, -- from[L170]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+171",
				},
			},
		},
		{
			index = 514, -- number
			id = 257, -- jump [J257]
			fromLocationId = 90, -- from[L90]
			toLocationId = 1, -- to[L1]
			formulaToPass = "[p6]<>0",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+91",
				},
			},
		},
		{
			index = 515, -- number
			id = 388, -- jump [J388]
			fromLocationId = 195, -- from[L195]
			toLocationId = 12, -- to[L12]
			formulaToPass = "1=0",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+196",
				},
			},
		},
		{
			index = 516, -- number
			id = 389, -- jump [J389]
			fromLocationId = 195, -- from[L195]
			toLocationId = 13, -- to[L13]
			formulaToPass = "1=2",
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+196",
				},
			},
		},
		{
			index = 517, -- number
			id = 390, -- jump [J390]
			fromLocationId = 195, -- from[L195]
			toLocationId = 196, -- to[L196]
			formulaToPass = "1=1",
		},
		{
			index = 518, -- number
			id = 90, -- jump [J90]
			fromLocationId = 12, -- from[L12]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+14",
				},
			},
		},
		{
			index = 519, -- number
			id = 91, -- jump [J91]
			fromLocationId = 13, -- from[L13]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+14",
				},
			},
		},
		{
			index = 520, -- number
			id = 420, -- jump [J420]
			fromLocationId = 217, -- from[L217]
			toLocationId = 1, -- to[L1]
			paramsChanges = { -- amount: 56
				{
					index = "[p1]",
					changingFormula = "[p1]*256+218",
				},
			},
		},
		{
			index = 521, -- number
			id = 419, -- jump [J419]
			fromLocationId = 216, -- from[L216]
			toLocationId = 217, -- to[L217]
		},
	},
}


--[[
QM/QMM File Format Specification (Space Rangers Quest Format)
==============================================================

## Overview
QM (Quest Master) and QMM (Quest Master Modified) are binary file formats 
used for text-based adventure quests in Space Rangers game series.
Files may be compressed using zlib/pako compression.

## File Reading Algorithm

### Step 1: Check for Compression
1. Read first 2 bytes
2. If bytes are 0x78 0x9C (zlib magic): decompress entire file with zlib
3. Continue with decompressed data

### Step 2: Read Header Magic
Position: 0x00
- Read 4 bytes: magic signature
  - QM files: specific magic value (varies by version)
  - Check against known TGE versions (4.2.x, 4.3.x, 5.x)

### Step 3: Read Version Info
Position: 0x04
- Read 4 bytes (int32): major version
- Read 4 bytes (int32): minor version
- Read 4 bytes (int32): revision
Example: version 5.2.10 = major:5, minor:2, revision:10

### Step 4: Read Quest Metadata

#### Quest Header Block
Read in sequence:
1. Quest name:
   - Read 4 bytes (int32): string length N
   - Read N bytes: UTF-8/CP1251 string
   
2. Task text (given to player):
   - Read 4 bytes (int32): string length
   - Read string data
   
3. Success text:
   - Read 4 bytes (int32): string length
   - Read string data
   
4. Failure text:
   - Read 4 bytes (int32): string length
   - Read string data
   
5. Race identifiers:
   - Read 4 bytes (int32): from_race (0-5: Maloc, Peleng, People, Fei, Gaal, Klingon/None)
   - Read 4 bytes (int32): to_race (same encoding)
   
6. Planet/Star names:
   - Read string: from_planet
   - Read string: from_star
   - Read string: to_planet
   - Read string: to_star
   
7. Quest settings:
   - Read 4 bytes (int32): difficulty (0-100)
   - Read 4 bytes (int32): days_to_complete
   - Read 4 bytes (int32): money_reward
   
8. Ranger type required:
   - Read 4 bytes (int32): required_ranger_type
     (0=any, 1=trader, 2=pirate, 3=warrior)

### Step 5: Read Parameters Section

1. Read 4 bytes (int32): parameter_count (max 48 for v4.x, 96 for v5.x)

2. For each parameter (loop parameter_count times):
   
   a) Read 4 bytes (int32): parameter_id (usually sequential)
   
   b) Parameter name:
      - Read 4 bytes (int32): name_length
      - Read name_length bytes: UTF-8 string
   
   c) Read 4 bytes (int32): min_value
   
   d) Read 4 bytes (int32): max_value
   
   e) Initial values:
      - Read 4 bytes (int32): initial_values_count
      - For each initial value:
        - Read 4 bytes (int32): value OR
        - Read range specification string
   
   f) Read 1 byte: parameter_type
      - 0 = normal
      - 1 = success (quest ends successfully)
      - 2 = fail (quest ends in failure)
      - 3 = death (player dies)
   
   g) If parameter_type != 0:
      - Read 4 bytes (int32): critical_value
   
   h) Read 1 byte (boolean): is_money_parameter
   
   i) Read 1 byte (boolean): show_when_zero
   
   j) Display ranges:
      - Read 4 bytes (int32): ranges_count
      - For each range:
        - Read 4 bytes (int32): range_min
        - Read 4 bytes (int32): range_max
        - Read string: display_format
          (can contain <>, [pX], {expressions})

### Step 6: Read Locations Section

1. Read 4 bytes (int32): locations_count

2. For each location:
   
   a) Read 4 bytes (int32): location_id
   
   b) Read 1 byte: location_type
      - 0 = normal
      - 1 = starting location
      - 2 = success ending
      - 3 = fail ending
      - 4 = death ending
   
   c) Read 1 byte (boolean): is_empty
      (if true, text shown only when transition has no description)
   
   d) Read 1 byte (boolean): day_passed
      (if true, one game day passes when entering this location)
   
   e) Description texts:
      - Read 4 bytes (int32): texts_count (1-10)
      - For each text:
        - Read string: description_text
   
   f) Read string: description_selection_formula
      (expression or range like [1..5] to choose which text to show)
   
   g) Parameter modifications:
      - Read 4 bytes (int32): modifications_count
      - For each modification:
        - Read 4 bytes (int32): parameter_index
        - Read 1 byte: modification_type
          - 0 = add value
          - 1 = subtract value
          - 2 = percentage change
          - 3 = assign value
          - 4 = expression evaluation
        - Read string: value_or_expression
        - Read 1 byte: show_change_in_stats
   
   h) Parameter visibility:
      - For each parameter (48 or 96):
        - Read 1 byte: visibility_change
          - 0 = no change
          - 1 = show parameter
          - 2 = hide parameter
   
   i) Critical value messages:
      - For each parameter:
        - Read 1 byte (boolean): has_custom_message
        - If true:
          - Read string: custom_critical_message
   
   j) Editor position:
      - Read 4 bytes (float): x_position
      - Read 4 bytes (float): y_position

### Step 7: Read Transitions Section

1. Read 4 bytes (int32): transitions_count

2. For each transition:
   
   a) Read 4 bytes (int32): transition_id
   
   b) Read 4 bytes (int32): from_location_id
   
   c) Read 4 bytes (int32): to_location_id
   
   d) Read 4 bytes (float): priority
      (used for random selection when multiple transitions compete)
   
   e) Read 1 byte (boolean): day_passed
   
   f) Read string: question_text
      (shown as choice to player; empty = automatic transition)
   
   g) Description texts:
      - Read 4 bytes (int32): texts_count (0-10)
      - For each text:
        - Read string: description_text
   
   h) Read string: description_selection_formula
   
   i) Read 4 bytes (int32): pass_count_limit
      (0 = unlimited, N = can pass N times)
   
   j) Read 1 byte (boolean): always_show
      (if true, show even when unavailable)
   
   k) Read 1 byte: display_order (0-9)
      (controls vertical position in choice list)
   
   l) Logic formula:
      - Read string: global_logic_formula
        (expression that must evaluate to true for transition to be available)
   
   m) Parameter conditions:
      - Read 4 bytes (int32): conditions_count
      - For each condition:
        - Read 4 bytes (int32): parameter_index
        - Read 1 byte: condition_type
          - 0 = must be in range
          - 1 = must not be in range
          - 2 = must equal values
          - 3 = must not equal values
          - 4 = must be multiple of
          - 5 = must not be multiple of
        - Read 4 bytes (int32): values_count
        - For each value:
          - Read 4 bytes (int32): value OR
          - Read range specification
   
   n) Parameter modifications:
      (same format as in locations)
   
   o) Parameter visibility:
      (same format as in locations)
   
   p) Critical value messages:
      (same format as in locations)
   
   q) Editor position for arrow drawing:
      - Read 4 bytes (float): control_point_x
      - Read 4 bytes (float): control_point_y

### Step 8: Read Additional Data (v5.x only)

For version 5.x and above:
1. Read 4 bytes (int32): has_extended_data
2. If has_extended_data != 0:
   - Read extended parameter data (48 additional parameters)
   - Read extended features flags
   - Read compatibility data

## Data Types Reference

### String Reading
--]]