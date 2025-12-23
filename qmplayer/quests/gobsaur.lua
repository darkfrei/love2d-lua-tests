return {
	header = 1111111122,
	givingRace = 8,
	whenDone = 0,
	planetRace = 64,
	playerCareer = 7,
	playerRace = 31,
	reputationChange = 0,
	screenSizeX = 1280,
	screenSizeY = 977,
	widthSize = 30,
	heightSize = 18,
	defaultJumpCountLimit = 1,
	hardness = 10,
	 
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
		FromPlanet = "<FromPLanet>",
		FromStar = "<FromStar>",
		Ranger = "Ranger",
		Parsec = "<Parsec>",
		Artefact = "<Artefact>",
	},
	taskText = "Несколько дней назад на необитаемой планете <ToPlanet>, система <ToStar>, при загадочных обстоятельствах пропали два наших исследователя, изучавших местную фауну. Неожиданно связь с ними оборвалась, и мы можем только теряться в догадках, что с ними произошло. <Ranger>, мы предлагаем вам отправиться в место их последней стоянки и выяснить, живы ли они. Если нет, то ваша задача - найти диск, на котором ученые фиксировали свои наблюдения. Если вы привезете его нам к <Date>, ваш гонорар составит <Money> cr, и как добросовестный исследователь, вы получите признание научной общественности нашей планеты.",
	successText = "<Ranger>, ваш рассказ приводит нас в трепет! Жаль, что такие блестящие ученые, как <clr>Ялгир Элфеду<clrEnd> и <clr>Аналла Онк<clrEnd>, погибли в зубах нецивилизованного животного. Впрочем, мы благодарим вас за доставленную ценную информацию. Ваш гонорар уже перечислен на ваш счет.",
	-- amount params: 24
	params = {
		{
			index = "[p1]",
			name = "Кость",
			min = -1,
			max = 1,
			showWhenZero = false,
			critType = 1,
			critValueString = "Сообщение достижения критического значения параметром 1",
			starting = "[0]",
			showingInfo = {
				{from=-1, to=0, str=""},
				{from=1, to=1, str="У вас есть кость"},
			},
		},
		{
			index = "[p2]",
			name = "Череп",
			min = -1,
			max = 1,
			showWhenZero = false,
			critType = 1,
			critValueString = "Сообщение достижения критического значения параметром 2",
			starting = "[0]",
			showingInfo = {
				{from=-1, to=0, str=""},
				{from=1, to=1, str="У вас есть череп"},
			},
		},
		{
			index = "[p3]",
			name = "Диск",
			min = 0,
			max = 1,
			showWhenZero = false,
			critType = 1,
			critValueString = "Сообщение достижения критического значения параметром 3",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Диск у вас"},
			},
		},
		{
			index = "[p4]",
			name = "Сытость гобзавра",
			min = 0,
			max = 3,
			type = 3,
			critValueString = "Сердитый и голодный гобзавр не выдерживает такой наглой провокации, бросается на вас и разрывает в мелкие клочья. Наконец ему будет чем утолить голод.",
			starting = "[0]",
			showingInfo = {
				{from=0, to=0, str="Гобзавр не осознает голод"},
				{from=1, to=1, str="Гобзавр голоден"},
				{from=2, to=2, str="Гобзавр сыт"},
				{from=3, to=3, str="Гобзавр смертельно голоден"},
			},
		},
		{
			index = "[p5]",
			name = "Настроение гобзавра",
			min = 0,
			max = 3,
			type = 3,
			critValueString = "Наконец заинтригованный гобзавр не выдерживает и сломя голову бросается к вам, чтобы тоже поиграть; только вместо черепа он хватает зубами вас и пинает до тех пор, пока вы не испускаете дух.",
			starting = "[0]",
			showingInfo = {
				{from=0, to=0, str="Гобзавр сердит"},
				{from=1, to=1, str="Гобзавр заинтригован"},
				{from=2, to=2, str="Гобзавр хочет поиграть"},
				{from=3, to=3, str="Гобзавр дико рад"},
			},
		},
		{
			index = "[p6]",
			name = "Положение гобзавра",
			min = 0,
			max = 2,
			critValueString = "Вы подошли почти к самой дальней стене берлоги, но гобзавр проснулся и понял, что покушаются на его собственность. Издав вопль, он наклонился и скушал вас вместе со всеми потрохами.",
			starting = "[0]",
			showingInfo = {
				{from=0, to=0, str="Гобзавр спит"},
				{from=1, to=1, str="Гобзавр бодрствует"},
				{from=2, to=2, str="Гобзавр снаружи пещеры"},
			},
		},
		{
			index = "[p7]",
			name = "Параметр номер 7",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 7",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 7: <>"},
			},
		},
		{
			index = "[p8]",
			name = "Параметр номер 8",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 8",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 8: <>"},
			},
		},
		{
			index = "[p9]",
			name = "Параметр номер 9",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 9",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 9: <>"},
			},
		},
		{
			index = "[p10]",
			name = "Параметр номер 10",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 10",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 10: <>"},
			},
		},
		{
			index = "[p11]",
			name = "Параметр номер 11",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 11",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 11: <>"},
			},
		},
		{
			index = "[p12]",
			name = "Параметр номер 12",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 12",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 12: <>"},
			},
		},
		{
			index = "[p13]",
			name = "Параметр номер 13",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 13",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 13: <>"},
			},
		},
		{
			index = "[p14]",
			name = "Параметр номер 14",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 14",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 14: <>"},
			},
		},
		{
			index = "[p15]",
			name = "Параметр номер 15",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 15",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 15: <>"},
			},
		},
		{
			index = "[p16]",
			name = "Параметр номер 16",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 16",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 16: <>"},
			},
		},
		{
			index = "[p17]",
			name = "Параметр номер 17",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 17",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 17: <>"},
			},
		},
		{
			index = "[p18]",
			name = "Параметр номер 18",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 18",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 18: <>"},
			},
		},
		{
			index = "[p19]",
			name = "Параметр номер 19",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 19",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 19: <>"},
			},
		},
		{
			index = "[p20]",
			name = "Параметр номер 20",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 20",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 20: <>"},
			},
		},
		{
			index = "[p21]",
			name = "Параметр номер 21",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 21",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 21: <>"},
			},
		},
		{
			index = "[p22]",
			name = "Параметр номер 22",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 22",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 22: <>"},
			},
		},
		{
			index = "[p23]",
			name = "Параметр номер 23",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 23",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 23: <>"},
			},
		},
		{
			index = "[p24]",
			name = "Параметр номер 24",
			min = 0,
			max = 1,
			critType = 1,
			active = false,
			critValueString = "Сообщение достижения критического значения параметром 24",
			starting = "[0]",
			showingInfo = {
				{from=0, to=1, str="Параметр номер 24: <>"},
			},
		},
	},
	locations = {
		{
			index = 1, -- number
			id = 1, -- location [L1]
			type = 1, -- isStarting
			locX = 21,
			locY = 459,
			texts = {
				"Пользуясь полученными координатами, вы, <Ranger>, приземлились точно на месте бывшей стоянки ученых. Действительно, она представляла собой жалкое зрелище - искореженный тент, разбросанные столы, аппаратура и посуда. Но самое главное, что бросилось вам в глаза - это огромные следы, ведущие от стоянки в чащу!",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
		},
		{
			index = 2, -- number
			id = 2, -- location [L2]
			type = 4, -- isFaily
			locX = 63,
			locY = 513,
			texts = {
				"Вы немедленно забрались в свой корабль, задернули все шторы и принялись дрожать от страха. И нечего тут, в круг обязанностей космического рейнджера не входит усмирение диких животных.",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
		},
		{
			index = 3, -- number
			id = 3, -- location [L3]
			type = 0, -- undefined
			locX = 105,
			locY = 459,
			texts = {
				"Вы пошли по следам и вскоре пришли к большой пещере, из которой доносился громкий храп. Заглянув внутрь, вы обнаружили разбросанные повсюду кости и в дальнем углу берлоги - огромного монстра. Раз в пять выше вас, зеленый, с длинными ногами, длинным носом и висячими ушами, он мирно похрапывал на куче костей. Вы напрягли память и вспомнили из курса зоологии, что сие животное называлось гобзавр.\r\nВаши предположения подтвердились: за спящим монстром виднелись еще не до конца истлевшие трупы фэян. Бедняги. Чтобы добраться туда, нужно обойти гобзавра, а делать это вам хотелось меньше всего. Хотя он и спал, кто знает, насколько чуток его сон.\r\nЧто делать?",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
		},
		{
			index = 4, -- number
			id = 4, -- location [L4]
			type = 2, -- isEmpty
			locX = 189,
			locY = 459,
			texts = {
				"Что же дальше?",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
		},
		{
			index = 5, -- number
			id = 5, -- location [L5]
			type = 4, -- isFaily
			locX = 357,
			locY = 783,
			texts = {
				"Гобзавр, не будь дурак, понял, что покушаются на его собственность. Возмущенный таким поворотом дел, он растерзал вас в мелкие клочья.\r\nНикогда не бери то, что принадлежит гобзавру, когда он в плохом настроении, вспомнили вы мудрое наставление школьной учительницы.\r\nЖаль, что вы всегда плохо учились в школе и не усвоили этот урок.",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
		},
		{
			index = 6, -- number
			id = 6, -- location [L6]
			type = 4, -- isFaily
			locX = 357,
			locY = 189,
			texts = {
				"Гобзавр, не разделяя ваших дружественных намерений, издает ужасный вопль и откусывает вам и руку, и все остальное, что выдается далеко из тела.\r\nЖаль, вы никогда не умели обращаться с животными. Да и они, признаться, всегда вас недолюбливали.",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
		},
		{
			index = 7, -- number
			id = 7, -- location [L7]
			type = 2, -- isEmpty
			locX = 273,
			locY = 459,
			texts = {
				"Что дальше?",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
		},
		{
			index = 8, -- number
			id = 8, -- location [L8]
			type = 2, -- isEmpty
			locX = 357,
			locY = 459,
			texts = {
				"Что дальше?",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
		},
		{
			index = 9, -- number
			id = 9, -- location [L9]
			type = 2, -- isEmpty
			locX = 441,
			locY = 459,
			texts = {
				"Что дальше?",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
		},
		{
			index = 10, -- number
			id = 10, -- location [L10]
			type = 2, -- isEmpty
			locX = 525,
			locY = 459,
			texts = {
				"Что дальше?",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
		},
		{
			index = 11, -- number
			id = 11, -- location [L11]
			type = 2, -- isEmpty
			locX = 609,
			locY = 459,
			texts = {
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
		},
		{
			index = 12, -- number
			id = 12, -- location [L12]
			type = 2, -- isEmpty
			locX = 693,
			locY = 459,
			texts = {
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
		},
		{
			index = 13, -- number
			id = 13, -- location [L13]
			type = 0, -- undefined
			locX = 777,
			locY = 567,
			texts = {
				"Вот он - мини-диск с фэянскими наклейками! Вам остается лишь покинуть это место и добраться невредимым до корабля. Гобзавр снаружи неуклюже прыгает, играя с черепом. Очевидно, ему понравилась ваша игра!",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
			paramsChanges = { -- amount: 24
				{
					index = "[p3]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 14, -- number
			id = 14, -- location [L14]
			type = 2, -- isEmpty
			locX = 777,
			locY = 459,
			texts = {
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
		},
		{
			index = 15, -- number
			id = 15, -- location [L15]
			type = 3, -- isSuccess
			locX = 861,
			locY = 567,
			texts = {
				"Да! Вы покинули пещеру и достигли своего корабля, в то время как гобзавр сопел и пыхтел, играя с черепом и не обращая на окружающую обстановку никакого внимания. Поблагодарив судьбу за свое чудесное избавление, вы впервые за сегодня позволили себе расслабиться.\r\n<Ranger>, а ты настоящий спец по монстрам, сделали вы себе комплимент. Еще один замечательный талант в вашем послужном списке.",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
		},
		{
			index = 16, -- number
			id = 16, -- location [L16]
			type = 0, -- undefined
			locX = 861,
			locY = 621,
			texts = {
				"Тут вы замечаете, что гобзавр оставляет свою игру и, пыхтя и пуская дым из огромных ноздрей, направляет в вашу сторону недобрый взгляд. Что-то здесь явно неладно.",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
		},
		{
			index = 17, -- number
			id = 17, -- location [L17]
			type = 2, -- isEmpty
			locX = 903,
			locY = 621,
			texts = {
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			},
			paramsChanges = { -- amount: 24
				{
					index = "[p4]",
					change = 3,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
					critText = "Краем сознания вы понимаете, что ваша песенка спета, но еще не теряете надежды затеряться где-нибудь в лесной чаще.\r\nГобзавр - хозяин прилегающей территории, абориген и бывалый охотник.\r\nНаконец он вкусно пообедал...",
				},
			},
		},
	},
	jumps = {
		{
			index = 1, -- number
			id = 2, -- jump [J2]
			fromLocationId = 1, -- from[L1]
			toLocationId = 2, -- to[L2]
			jumpingCountLimit = 1,
			text = "Немедленно улетать! Это страшный монстр неизученной местной породы, который не оставит от вас даже воспоминания!",
		},
		{
			index = 2, -- number
			id = 3, -- jump [J3]
			fromLocationId = 1, -- from[L1]
			toLocationId = 3, -- to[L3]
			jumpingCountLimit = 1,
			text = "Идти по следам",
		},
		{
			index = 3, -- number
			id = 4, -- jump [J4]
			fromLocationId = 3, -- from[L3]
			toLocationId = 4, -- to[L4]
			jumpingCountLimit = 1,
			text = "Слегка пошуметь, оставаясь на месте",
			description = "Вы произвели несколько шумов, и гобзавр проснулся. Да, по его виду не сказать, что он вам рад - он пыхтит и недовольно роет носом землю, с опаской поглядывая на вас.",
			paramsChanges = { -- amount: 24
				{
					index = "[p6]",
					change = 1,
					showingType = 2, -- hide
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 4, -- number
			id = 5, -- jump [J5]
			fromLocationId = 3, -- from[L3]
			toLocationId = 5, -- to[L5]
			jumpingCountLimit = 1,
			text = "Искать диск",
			description = "Тихонько, чтобы не разбудить монстра, вы направляетесь в дальний угол пещеры, чтобы обыскать лежащие в углу трупы...",
		},
		{
			index = 5, -- number
			id = 6, -- jump [J6]
			fromLocationId = 4, -- from[L4]
			toLocationId = 5, -- to[L5]
			jumpingCountLimit = 1,
			text = "Искать диск",
			description = "Тихонько, чтобы не разбудить монстра, вы направляетесь в дальний угол пещеры, чтобы обыскать лежащие в углу трупы...",
		},
		{
			index = 6, -- number
			id = 7, -- jump [J7]
			fromLocationId = 4, -- from[L4]
			toLocationId = 6, -- to[L6]
			jumpingCountLimit = 1,
			text = "Подойти и погладить гобзавра",
			description = "Вы приближаетесь к страшному монстру и протягиваете к нему руку, чтобы по-дружески потрепать по загривку...",
		},
		{
			index = 7, -- number
			id = 8, -- jump [J8]
			fromLocationId = 3, -- from[L3]
			toLocationId = 6, -- to[L6]
			jumpingCountLimit = 1,
			text = "Подойти и погладить гобзавра",
			description = "Вы приближаетесь к страшному монстру и протягиваете к нему руку, чтобы по-дружески потрепать по загривку...",
		},
		{
			index = 8, -- number
			id = 10, -- jump [J10]
			fromLocationId = 4, -- from[L4]
			toLocationId = 7, -- to[L7]
			jumpingCountLimit = 1,
			text = "Поднять с земли череп",
			description = "Вы поднимаете большой длинный череп одного из местных животных, когда-то съеденного гобзавром.",
			paramsChanges = { -- amount: 24
				{
					index = "[p2]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 9, -- number
			id = 11, -- jump [J11]
			fromLocationId = 7, -- from[L7]
			toLocationId = 6, -- to[L6]
			jumpingCountLimit = 1,
			text = "Подойти и погладить гобзавра",
			description = "Вы приближаетесь к страшному монстру и протягиваете к нему руку, чтобы по-дружески потрепать по загривку...",
		},
		{
			index = 10, -- number
			id = 12, -- jump [J12]
			fromLocationId = 7, -- from[L7]
			toLocationId = 5, -- to[L5]
			jumpingCountLimit = 1,
			text = "Искать диск",
			description = "Тихонько, чтобы не разбудить монстра, вы направляетесь в дальний угол пещеры, чтобы обыскать лежащие в углу трупы...",
		},
		{
			index = 11, -- number
			id = 13, -- jump [J13]
			fromLocationId = 7, -- from[L7]
			toLocationId = 8, -- to[L8]
			jumpingCountLimit = 1,
			text = "Поглодать кость",
			description = "Вы принялись жадно глодать грязную кость, делая вид, что с удовольствием кушаете. Глядя на эту сцену, гобзавр начинает испускать слюнки.",
			paramsChanges = { -- amount: 24
				{
					index = "[p4]",
					change = 1,
					showingType = 1, -- show
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 12, -- number
			id = 15, -- jump [J15]
			fromLocationId = 7, -- from[L7]
			toLocationId = 8, -- to[L8]
			jumpingCountLimit = 1,
			text = "Поиграть с черепом",
			description = "Вы принимаетесь подбрасывать череп в воздух. Гобзавр с интересом следит за вашими действиями. Кажется, он явно заинтригован.",
			paramsChanges = { -- amount: 24
				{
					index = "[p5]",
					change = 1,
					showingType = 1, -- show
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 13, -- number
			id = 16, -- jump [J16]
			fromLocationId = 4, -- from[L4]
			toLocationId = 7, -- to[L7]
			jumpingCountLimit = 1,
			text = "Поднять с земли кость",
			description = "Вы поднимаете лежащую на полу кость, очевидно принадлежащую животному, съеденному когда-то гобзавром.",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 14, -- number
			id = 17, -- jump [J17]
			fromLocationId = 7, -- from[L7]
			toLocationId = 8, -- to[L8]
			jumpingCountLimit = 1,
			text = "Бросить кость гобзавру",
			description = "Вы бросаете кость к ногам гобзавра. По его виду не скажешь, что он сильно голоден. Гобзавр нюхает кость и отпинывает ее ногой в угол пещеры.",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 15, -- number
			id = 18, -- jump [J18]
			fromLocationId = 8, -- from[L8]
			toLocationId = 9, -- to[L9]
			jumpingCountLimit = 1,
			text = "Бросить кость гобзавру",
			description = "Вы бросаете кость, гобзавр ловит ее на лету и с жадностью глотает, не жуя. Удивительно, на что способна реклама - эта кость лежала тут не один день, и гобзавр даже не замечал ее, и вот теперь после нескольких простых рекламаций он схрумкал ее так, словно это был царский обед.",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
				{
					index = "[p4]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 16, -- number
			id = 19, -- jump [J19]
			fromLocationId = 8, -- from[L8]
			toLocationId = 9, -- to[L9]
			jumpingCountLimit = 1,
			text = "Продолжать глодать кость",
			description = "Вы с еще большим усердием принялись глодать кость, аппетитно причмокивая...",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
				{
					index = "[p4]",
					change = 3,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
				{
					index = "[p5]",
					change = 0,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
					critText = "Сердитый и голодный гобзавр не выдерживает такой наглой провокации, бросается на вас и разрывает в мелкие клочья. Наконец ему будет чем утолить голод.",
				},
			},
		},
		{
			index = 17, -- number
			id = 21, -- jump [J21]
			fromLocationId = 7, -- from[L7]
			toLocationId = 8, -- to[L8]
			jumpingCountLimit = 1,
			text = "Поднять с земли череп",
			description = "Вы поднимаете большой длинный череп одного из местных животных, когда-то съеденного гобзавром.",
			paramsChanges = { -- amount: 24
				{
					index = "[p2]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 18, -- number
			id = 22, -- jump [J22]
			fromLocationId = 8, -- from[L8]
			toLocationId = 9, -- to[L9]
			jumpingCountLimit = 1,
			text = "Поднять с земли череп",
			description = "Вы поднимаете большой длинный череп одного из местных животных, когда-то съеденного гобзавром.",
			paramsChanges = { -- amount: 24
				{
					index = "[p2]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 19, -- number
			id = 23, -- jump [J23]
			fromLocationId = 7, -- from[L7]
			toLocationId = 8, -- to[L8]
			jumpingCountLimit = 1,
			text = "Поднять с земли кость",
			description = "Вы поднимаете лежащую на полу кость, очевидно принадлежащую животному, съеденному когда-то гобзавром.",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 20, -- number
			id = 24, -- jump [J24]
			fromLocationId = 8, -- from[L8]
			toLocationId = 9, -- to[L9]
			jumpingCountLimit = 1,
			text = "Поднять с земли кость",
			description = "Вы поднимаете лежащую на полу кость, очевидно принадлежащую животному, съеденному когда-то гобзавром.",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 21, -- number
			id = 25, -- jump [J25]
			fromLocationId = 8, -- from[L8]
			toLocationId = 9, -- to[L9]
			jumpingCountLimit = 1,
			text = "Поиграть с черепом",
			description = "Вы принимаетесь подбрасывать череп в воздух. Гобзавр с интересом следит за вашими действиями. Кажется, он явно заинтригован.",
			paramsChanges = { -- amount: 24
				{
					index = "[p5]",
					change = 1,
					showingType = 1, -- show
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 22, -- number
			id = 26, -- jump [J26]
			fromLocationId = 8, -- from[L8]
			toLocationId = 9, -- to[L9]
			jumpingCountLimit = 1,
			text = "Поглодать кость",
			description = "Вы принялись жадно глодать грязную кость, делая вид, что с удовольствием кушаете. Глядя на эту сцену, гобзавр начинает испускать слюнки.",
			paramsChanges = { -- amount: 24
				{
					index = "[p4]",
					change = 1,
					showingType = 1, -- show
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 23, -- number
			id = 27, -- jump [J27]
			fromLocationId = 8, -- from[L8]
			toLocationId = 9, -- to[L9]
			jumpingCountLimit = 1,
			text = "Продолжать играть с черепом",
			description = "\"Ля-ля-ля\", поете вы, подкидывая череп и ловя его руками. Да, до чего только не вынужден снисходить космический рейнджер ради благородной цели. Со временем вы замечаете, что гобзавр начинает подпрыгивать в такт вам, весело помахивая ушами.",
			paramsChanges = { -- amount: 24
				{
					index = "[p5]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 24, -- number
			id = 28, -- jump [J28]
			fromLocationId = 9, -- from[L9]
			toLocationId = 10, -- to[L10]
			jumpingCountLimit = 1,
			text = "Поднять с земли череп",
			description = "Вы поднимаете большой длинный череп одного из местных животных, когда-то съеденного гобзавром.",
			paramsChanges = { -- amount: 24
				{
					index = "[p2]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 25, -- number
			id = 29, -- jump [J29]
			fromLocationId = 9, -- from[L9]
			toLocationId = 10, -- to[L10]
			jumpingCountLimit = 1,
			text = "Поднять с земли кость",
			description = "Вы поднимаете лежащую на полу кость, очевидно принадлежащую животному, съеденному когда-то гобзавром.",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 26, -- number
			id = 30, -- jump [J30]
			fromLocationId = 9, -- from[L9]
			toLocationId = 10, -- to[L10]
			jumpingCountLimit = 1,
			text = "Поглодать кость",
			description = "Вы принялись жадно глодать грязную кость, делая вид, что с удовольствием кушаете. Глядя на эту сцену, гобзавр начинает испускать слюнки.",
			paramsChanges = { -- amount: 24
				{
					index = "[p4]",
					change = 1,
					showingType = 1, -- show
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 27, -- number
			id = 31, -- jump [J31]
			fromLocationId = 9, -- from[L9]
			toLocationId = 10, -- to[L10]
			jumpingCountLimit = 1,
			text = "Бросить кость гобзавру",
			description = "Вы бросаете кость к ногам гобзавра. По его виду не скажешь, что он сильно голоден. Гобзавр нюхает кость и отпинывает ее ногой в угол пещеры.",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 28, -- number
			id = 32, -- jump [J32]
			fromLocationId = 9, -- from[L9]
			toLocationId = 10, -- to[L10]
			jumpingCountLimit = 1,
			text = "Поиграть с черепом",
			description = "Вы принимаетесь подбрасывать череп в воздух. Гобзавр с интересом следит за вашими действиями. Кажется, он явно заинтригован.",
			paramsChanges = { -- amount: 24
				{
					index = "[p5]",
					change = 1,
					showingType = 1, -- show
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 29, -- number
			id = 33, -- jump [J33]
			fromLocationId = 8, -- from[L8]
			toLocationId = 9, -- to[L9]
			jumpingCountLimit = 1,
			text = "Бросить кость гобзавру",
			description = "Вы бросаете кость к ногам гобзавра. По его виду не скажешь, что он сильно голоден. Гобзавр нюхает кость и отпинывает ее ногой в угол пещеры.",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 30, -- number
			id = 34, -- jump [J34]
			fromLocationId = 9, -- from[L9]
			toLocationId = 10, -- to[L10]
			jumpingCountLimit = 1,
			text = "Бросить кость гобзавру",
			description = "Вы бросаете кость, гобзавр ловит ее на лету и с жадностью глотает, не жуя. Удивительно, на что способна реклама - эта кость лежала тут не один день, и гобзавр даже не замечал ее, и вот теперь после нескольких простых рекламаций он схрумкал ее так, словно это был царский обед.",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
				{
					index = "[p4]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 31, -- number
			id = 35, -- jump [J35]
			fromLocationId = 9, -- from[L9]
			toLocationId = 10, -- to[L10]
			jumpingCountLimit = 1,
			text = "Продолжать глодать кость",
			description = "Вы с еще большим усердием принялись глодать кость, аппетитно причмокивая...",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
				{
					index = "[p4]",
					change = 3,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 32, -- number
			id = 36, -- jump [J36]
			fromLocationId = 9, -- from[L9]
			toLocationId = 10, -- to[L10]
			jumpingCountLimit = 1,
			text = "Продолжать играть с черепом",
			description = "\"Ля-ля-ля\", поете вы, подкидывая череп и ловя его руками. Да, до чего только не вынужден снисходить космический рейнджер ради благородной цели. Со временем вы замечаете, что гобзавр начинает подпрыгивать в такт вам, весело помахивая ушами.",
			paramsChanges = { -- amount: 24
				{
					index = "[p5]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 33, -- number
			id = 37, -- jump [J37]
			fromLocationId = 9, -- from[L9]
			toLocationId = 10, -- to[L10]
			jumpingCountLimit = 1,
			text = "Продолжать играть с черепом",
			description = "Вы пинаете череп, забивая его в импровизированные ворота на другом конце берлоги.",
			paramsChanges = { -- amount: 24
				{
					index = "[p5]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
					critText = "Наконец заинтригованный гобзавр не выдерживает и сломя голову бросается к вам, чтобы тоже поиграть; только вместо черепа он хватает зубами вас и пинает до тех пор, пока вы не испускаете дух.",
				},
			},
		},
		{
			index = 34, -- number
			id = 38, -- jump [J38]
			fromLocationId = 8, -- from[L8]
			toLocationId = 5, -- to[L5]
			jumpingCountLimit = 1,
			text = "Искать диск",
			description = "Тихонько, чтобы не разбудить монстра, вы направляетесь в дальний угол пещеры, чтобы обыскать лежащие в углу трупы...",
		},
		{
			index = 35, -- number
			id = 39, -- jump [J39]
			fromLocationId = 9, -- from[L9]
			toLocationId = 5, -- to[L5]
			jumpingCountLimit = 1,
			text = "Искать диск",
			description = "Тихонько, чтобы не разбудить монстра, вы направляетесь в дальний угол пещеры, чтобы обыскать лежащие в углу трупы...",
		},
		{
			index = 36, -- number
			id = 40, -- jump [J40]
			fromLocationId = 10, -- from[L10]
			toLocationId = 5, -- to[L5]
			jumpingCountLimit = 1,
			text = "Искать диск",
			description = "Тихонько, чтобы не разбудить монстра, вы направляетесь в дальний угол пещеры, чтобы обыскать лежащие в углу трупы...",
		},
		{
			index = 37, -- number
			id = 41, -- jump [J41]
			fromLocationId = 8, -- from[L8]
			toLocationId = 6, -- to[L6]
			jumpingCountLimit = 1,
			text = "Подойти и погладить гобзавра",
			description = "Вы приближаетесь к страшному монстру и протягиваете к нему руку, чтобы по-дружески потрепать по загривку...",
		},
		{
			index = 38, -- number
			id = 42, -- jump [J42]
			fromLocationId = 9, -- from[L9]
			toLocationId = 6, -- to[L6]
			jumpingCountLimit = 1,
			text = "Подойти и погладить гобзавра",
			description = "Вы приближаетесь к страшному монстру и протягиваете к нему руку, чтобы по-дружески потрепать по загривку...",
		},
		{
			index = 39, -- number
			id = 43, -- jump [J43]
			fromLocationId = 10, -- from[L10]
			toLocationId = 6, -- to[L6]
			jumpingCountLimit = 1,
			text = "Подойти и погладить гобзавра",
			description = "Вы приближаетесь к страшному монстру и протягиваете к нему руку, чтобы по-дружески потрепать по загривку...",
		},
		{
			index = 40, -- number
			id = 44, -- jump [J44]
			fromLocationId = 10, -- from[L10]
			toLocationId = 11, -- to[L11]
			jumpingCountLimit = 1,
			text = "Продолжать играть с черепом",
			description = "Вы пинаете череп, забивая его в импровизированные ворота на другом конце берлоги.",
			paramsChanges = { -- amount: 24
				{
					index = "[p5]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
					critText = "Наконец заинтригованный гобзавр не выдерживает и сломя голову бросается к вам, чтобы тоже поиграть; только вместо черепа он хватает зубами вас и пинает до тех пор, пока вы не испускаете дух.",
				},
			},
		},
		{
			index = 41, -- number
			id = 45, -- jump [J45]
			fromLocationId = 10, -- from[L10]
			toLocationId = 11, -- to[L11]
			jumpingCountLimit = 1,
			text = "Продолжать глодать кость",
			description = "Вы с еще большим усердием принялись глодать кость, аппетитно причмокивая...",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
				{
					index = "[p4]",
					change = 3,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 42, -- number
			id = 46, -- jump [J46]
			fromLocationId = 10, -- from[L10]
			toLocationId = 11, -- to[L11]
			jumpingCountLimit = 1,
			text = "Поиграть с черепом",
			description = "Вы принимаетесь подбрасывать череп в воздух. Гобзавр с интересом следит за вашими действиями. Кажется, он явно заинтригован.",
			paramsChanges = { -- amount: 24
				{
					index = "[p5]",
					change = 1,
					showingType = 1, -- show
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 43, -- number
			id = 47, -- jump [J47]
			fromLocationId = 10, -- from[L10]
			toLocationId = 11, -- to[L11]
			jumpingCountLimit = 1,
			text = "Поглодать кость",
			description = "Вы принялись жадно глодать грязную кость, делая вид, что с удовольствием кушаете. Глядя на эту сцену, гобзавр начинает испускать слюнки.",
			paramsChanges = { -- amount: 24
				{
					index = "[p4]",
					change = 1,
					showingType = 1, -- show
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 44, -- number
			id = 48, -- jump [J48]
			fromLocationId = 10, -- from[L10]
			toLocationId = 11, -- to[L11]
			jumpingCountLimit = 1,
			text = "Бросить кость гобзавру",
			description = "Вы бросаете кость к ногам гобзавра. По его виду не скажешь, что он сильно голоден. Гобзавр нюхает кость и отпинывает ее ногой в угол пещеры.",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 45, -- number
			id = 49, -- jump [J49]
			fromLocationId = 10, -- from[L10]
			toLocationId = 11, -- to[L11]
			jumpingCountLimit = 1,
			text = "Бросить кость гобзавру",
			description = "Вы бросаете кость, гобзавр ловит ее на лету и с жадностью глотает, не жуя. Удивительно, на что способна реклама - эта кость лежала тут не один день, и гобзавр даже не замечал ее, и вот теперь после нескольких простых рекламаций он схрумкал ее так, словно это был царский обед.",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
				{
					index = "[p4]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 46, -- number
			id = 50, -- jump [J50]
			fromLocationId = 10, -- from[L10]
			toLocationId = 11, -- to[L11]
			jumpingCountLimit = 1,
			text = "Продолжать играть с черепом",
			description = "\"Ля-ля-ля\", поете вы, подкидывая череп и ловя его руками. Да, до чего только не вынужден снисходить космический рейнджер ради благородной цели. Со временем вы замечаете, что гобзавр начинает подпрыгивать в такт вам, весело помахивая ушами.",
			paramsChanges = { -- amount: 24
				{
					index = "[p5]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 47, -- number
			id = 51, -- jump [J51]
			fromLocationId = 7, -- from[L7]
			toLocationId = 8, -- to[L8]
			jumpingCountLimit = 1,
			text = "Выбросить череп из пещеры",
			description = "Вы выбрасываете череп подальше от входа в пещеру, но на гобзавра это не производит ровным счетом никакого впечатления.",
			paramsChanges = { -- amount: 24
				{
					index = "[p2]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 48, -- number
			id = 52, -- jump [J52]
			fromLocationId = 8, -- from[L8]
			toLocationId = 9, -- to[L9]
			jumpingCountLimit = 1,
			text = "Выбросить череп из пещеры",
			description = "Вы выбрасываете череп подальше от входа в пещеру, но на гобзавра это не производит ровным счетом никакого впечатления.",
			paramsChanges = { -- amount: 24
				{
					index = "[p2]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 49, -- number
			id = 53, -- jump [J53]
			fromLocationId = 10, -- from[L10]
			toLocationId = 11, -- to[L11]
			jumpingCountLimit = 1,
			text = "Поднять с земли кость",
			description = "Вы поднимаете лежащую на полу кость, очевидно принадлежащую животному, съеденному когда-то гобзавром.",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 50, -- number
			id = 55, -- jump [J55]
			fromLocationId = 9, -- from[L9]
			toLocationId = 10, -- to[L10]
			jumpingCountLimit = 1,
			text = "Выбросить череп из пещеры",
			description = "Вы выбрасываете череп подальше от входа в пещеру, но на гобзавра это не производит ровным счетом никакого впечатления.",
			paramsChanges = { -- amount: 24
				{
					index = "[p2]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 51, -- number
			id = 56, -- jump [J56]
			fromLocationId = 9, -- from[L9]
			toLocationId = 10, -- to[L10]
			jumpingCountLimit = 1,
			text = "Выбросить череп из пещеры",
			description = "Вы выбрасываете череп подальше от входа в пещеру, и гобзавр, заинтригованный вашей новой игрой, стремглав устремляется за ним. Вам чудом удалось отпрыгнуть в сторонку, чтобы не сгинуть под ногами монстра.",
			paramsChanges = { -- amount: 24
				{
					index = "[p2]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
				{
					index = "[p6]",
					change = 2,
					showingType = 1, -- show
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 52, -- number
			id = 57, -- jump [J57]
			fromLocationId = 10, -- from[L10]
			toLocationId = 11, -- to[L11]
			jumpingCountLimit = 1,
			text = "Выбросить череп из пещеры",
			description = "Вы выбрасываете череп подальше от входа в пещеру, но на гобзавра это не производит ровным счетом никакого впечатления.",
			paramsChanges = { -- amount: 24
				{
					index = "[p2]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 53, -- number
			id = 58, -- jump [J58]
			fromLocationId = 10, -- from[L10]
			toLocationId = 11, -- to[L11]
			jumpingCountLimit = 1,
			text = "Выбросить череп из пещеры",
			description = "Вы выбрасываете череп подальше от входа в пещеру, и гобзавр, заинтригованный вашей новой игрой, стремглав устремляется за ним. Вам чудом удалось отпрыгнуть в сторонку, чтобы не сгинуть под ногами монстра.",
			paramsChanges = { -- amount: 24
				{
					index = "[p2]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
				{
					index = "[p6]",
					change = 2,
					showingType = 1, -- show
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 54, -- number
			id = 59, -- jump [J59]
			fromLocationId = 11, -- from[L11]
			toLocationId = 12, -- to[L12]
			jumpingCountLimit = 1,
			text = "Выбросить череп из пещеры",
			description = "Вы выбрасываете череп подальше от входа в пещеру, и гобзавр, заинтригованный вашей новой игрой, стремглав устремляется за ним. Вам чудом удалось отпрыгнуть в сторонку, чтобы не сгинуть под ногами монстра.",
			paramsChanges = { -- amount: 24
				{
					index = "[p2]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
				{
					index = "[p6]",
					change = 2,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 55, -- number
			id = 60, -- jump [J60]
			fromLocationId = 11, -- from[L11]
			toLocationId = 12, -- to[L12]
			jumpingCountLimit = 1,
			text = "Продолжать играть с черепом",
			description = "\"Ля-ля-ля\", поете вы, подкидывая череп и ловя его руками. Да, до чего только не вынужден снисходить космический рейнджер ради благородной цели. Со временем вы замечаете, что гобзавр начинает подпрыгивать в такт вам, весело помахивая ушами.",
			paramsChanges = { -- amount: 24
				{
					index = "[p5]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 56, -- number
			id = 61, -- jump [J61]
			fromLocationId = 11, -- from[L11]
			toLocationId = 12, -- to[L12]
			jumpingCountLimit = 1,
			text = "Бросить кость гобзавру",
			description = "Вы бросаете кость к ногам гобзавра. По его виду не скажешь, что он сильно голоден. Гобзавр нюхает кость и отпинывает ее ногой в угол пещеры.",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 57, -- number
			id = 62, -- jump [J62]
			fromLocationId = 11, -- from[L11]
			toLocationId = 12, -- to[L12]
			jumpingCountLimit = 1,
			text = "Бросить кость гобзавру",
			description = "Вы бросаете кость, гобзавр ловит ее на лету и с жадностью глотает, не жуя. Удивительно, на что способна реклама - эта кость лежала тут не один день, и гобзавр даже не замечал ее, и вот теперь после нескольких простых рекламаций он схрумкал ее так, словно это был царский обед.",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
				{
					index = "[p4]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 58, -- number
			id = 64, -- jump [J64]
			fromLocationId = 11, -- from[L11]
			toLocationId = 12, -- to[L12]
			jumpingCountLimit = 1,
			text = "Продолжать играть с черепом",
			description = "Вы пинаете череп, забивая его в импровизированные ворота на другом конце берлоги.",
			paramsChanges = { -- amount: 24
				{
					index = "[p5]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 59, -- number
			id = 65, -- jump [J65]
			fromLocationId = 11, -- from[L11]
			toLocationId = 12, -- to[L12]
			jumpingCountLimit = 1,
			text = "Поглодать кость",
			description = "Вы принялись жадно глодать грязную кость, делая вид, что с удовольствием кушаете. Глядя на эту сцену, гобзавр начинает испускать слюнки.",
			paramsChanges = { -- amount: 24
				{
					index = "[p4]",
					change = 1,
					showingType = 1, -- show
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 60, -- number
			id = 66, -- jump [J66]
			fromLocationId = 11, -- from[L11]
			toLocationId = 12, -- to[L12]
			jumpingCountLimit = 1,
			text = "Продолжать глодать кость",
			description = "Вы с еще большим усердием принялись глодать кость, аппетитно причмокивая...",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
				{
					index = "[p4]",
					change = 3,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 61, -- number
			id = 67, -- jump [J67]
			fromLocationId = 11, -- from[L11]
			toLocationId = 12, -- to[L12]
			jumpingCountLimit = 1,
			text = "Выбросить череп из пещеры",
			description = "Вы выбрасываете череп подальше от входа в пещеру, но на гобзавра это не производит ровным счетом никакого впечатления.",
			paramsChanges = { -- amount: 24
				{
					index = "[p2]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 62, -- number
			id = 68, -- jump [J68]
			fromLocationId = 11, -- from[L11]
			toLocationId = 6, -- to[L6]
			jumpingCountLimit = 1,
			text = "Подойти и погладить гобзавра",
			description = "Вы приближаетесь к страшному монстру и протягиваете к нему руку, чтобы по-дружески потрепать по загривку...",
		},
		{
			index = 63, -- number
			id = 69, -- jump [J69]
			fromLocationId = 12, -- from[L12]
			toLocationId = 6, -- to[L6]
			jumpingCountLimit = 1,
			text = "Подойти и погладить гобзавра",
			description = "Вы приближаетесь к страшному монстру и протягиваете к нему руку, чтобы по-дружески потрепать по загривку...",
		},
		{
			index = 64, -- number
			id = 70, -- jump [J70]
			fromLocationId = 11, -- from[L11]
			toLocationId = 5, -- to[L5]
			jumpingCountLimit = 1,
			text = "Искать диск",
			description = "Тихонько, чтобы не разбудить монстра, вы направляетесь в дальний угол пещеры, чтобы обыскать лежащие в углу трупы...",
		},
		{
			index = 65, -- number
			id = 71, -- jump [J71]
			fromLocationId = 12, -- from[L12]
			toLocationId = 5, -- to[L5]
			jumpingCountLimit = 1,
			text = "Искать диск",
			description = "Тихонько, чтобы не разбудить монстра, вы направляетесь в дальний угол пещеры, чтобы обыскать лежащие в углу трупы...",
		},
		{
			index = 66, -- number
			id = 72, -- jump [J72]
			fromLocationId = 12, -- from[L12]
			toLocationId = 13, -- to[L13]
			jumpingCountLimit = 1,
			text = "Искать диск",
			description = "Путь свободен! Пока гобзавр самозабвенно играет черепом снаружи пещеры, вы обыскиваете лежащие в углу трупы.",
		},
		{
			index = 67, -- number
			id = 75, -- jump [J75]
			fromLocationId = 12, -- from[L12]
			toLocationId = 14, -- to[L14]
			jumpingCountLimit = 1,
			text = "Бросить кость гобзавру",
			description = "Вы бросаете кость, гобзавр ловит ее на лету и с жадностью глотает, не жуя. Удивительно, на что способна реклама - эта кость лежала тут не один день, и гобзавр даже не замечал ее, и вот теперь после нескольких простых рекламаций он схрумкал ее так, словно это был царский обед.",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
				{
					index = "[p4]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 68, -- number
			id = 78, -- jump [J78]
			fromLocationId = 12, -- from[L12]
			toLocationId = 14, -- to[L14]
			jumpingCountLimit = 1,
			text = "Продолжать играть с черепом",
			description = "Вы пинаете череп, забивая его в импровизированные ворота на другом конце берлоги.",
			paramsChanges = { -- amount: 24
				{
					index = "[p5]",
					change = 1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 69, -- number
			id = 79, -- jump [J79]
			fromLocationId = 12, -- from[L12]
			toLocationId = 14, -- to[L14]
			jumpingCountLimit = 1,
			text = "Продолжать глодать кость",
			description = "Вы с еще большим усердием принялись глодать кость, аппетитно причмокивая...",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = false,
					isChangeFormula = false,
					changingFormula = "",
				},
				{
					index = "[p4]",
					change = 3,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 70, -- number
			id = 80, -- jump [J80]
			fromLocationId = 14, -- from[L14]
			toLocationId = 6, -- to[L6]
			jumpingCountLimit = 1,
			text = "Подойти и погладить гобзавра",
			description = "Вы приближаетесь к страшному монстру и протягиваете к нему руку, чтобы по-дружески потрепать по загривку...",
		},
		{
			index = 71, -- number
			id = 81, -- jump [J81]
			fromLocationId = 14, -- from[L14]
			toLocationId = 5, -- to[L5]
			jumpingCountLimit = 1,
			text = "Искать диск",
			description = "Тихонько, чтобы не разбудить монстра, вы направляетесь в дальний угол пещеры, чтобы обыскать лежащие в углу трупы...",
		},
		{
			index = 72, -- number
			id = 82, -- jump [J82]
			fromLocationId = 14, -- from[L14]
			toLocationId = 13, -- to[L13]
			jumpingCountLimit = 1,
			text = "Искать диск",
			description = "Путь свободен! Пока гобзавр самозабвенно играет черепом снаружи пещеры, вы обыскиваете лежащие в углу трупы.",
		},
		{
			index = 73, -- number
			id = 83, -- jump [J83]
			fromLocationId = 12, -- from[L12]
			toLocationId = 14, -- to[L14]
			jumpingCountLimit = 1,
			text = "Выбросить череп из пещеры",
			description = "Вы выбрасываете череп подальше от входа в пещеру, и гобзавр, заинтригованный вашей новой игрой, стремглав устремляется за ним. Вам чудом удалось отпрыгнуть в сторонку, чтобы не сгинуть под ногами монстра.",
			paramsChanges = { -- amount: 24
				{
					index = "[p2]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
				{
					index = "[p6]",
					change = 2,
					showingType = 1, -- show
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 74, -- number
			id = 84, -- jump [J84]
			fromLocationId = 13, -- from[L13]
			toLocationId = 15, -- to[L15]
			text = "Выйти из пещеры",
			description = "Осторожно, чтобы не привлечь внимание гобзавра, вы выходите из пещеры и легкой трусцой направляетесь к кораблю.",
		},
		{
			index = 75, -- number
			id = 85, -- jump [J85]
			fromLocationId = 13, -- from[L13]
			toLocationId = 16, -- to[L16]
			text = "Выйти из пещеры",
			description = "Осторожно, чтобы не привлечь внимание гобзавра, вы выходите из пещеры и легкой трусцой направляетесь к кораблю.",
		},
		{
			index = 76, -- number
			id = 86, -- jump [J86]
			fromLocationId = 11, -- from[L11]
			toLocationId = 13, -- to[L13]
			jumpingCountLimit = 1,
			text = "Искать диск",
			description = "Путь свободен! Пока гобзавр самозабвенно играет черепом снаружи пещеры, вы обыскиваете лежащие в углу трупы.",
		},
		{
			index = 77, -- number
			id = 87, -- jump [J87]
			fromLocationId = 10, -- from[L10]
			toLocationId = 13, -- to[L13]
			jumpingCountLimit = 1,
			text = "Искать диск",
			description = "Путь свободен! Пока гобзавр самозабвенно играет черепом снаружи пещеры, вы обыскиваете лежащие в углу трупы.",
		},
		{
			index = 78, -- number
			id = 88, -- jump [J88]
			fromLocationId = 9, -- from[L9]
			toLocationId = 13, -- to[L13]
			jumpingCountLimit = 1,
			text = "Искать диск",
			description = "Путь свободен! Пока гобзавр самозабвенно играет черепом снаружи пещеры, вы обыскиваете лежащие в углу трупы.",
		},
		{
			index = 79, -- number
			id = 89, -- jump [J89]
			fromLocationId = 16, -- from[L16]
			toLocationId = 17, -- to[L17]
			jumpingCountLimit = 1,
			text = "Бросить гобзавру кость",
			description = "Превосходно! Гобзавр, должно быть, голоден, и вы бросаете ему кость.\r\nНо он не обратил ни малейшего внимания на эту подачку. Он голоден. Ужасно голоден. Игра с черепом, которую вы по неосторожности предложили ему, лишь усилила этот голод. Ему нужна НАСТОЯЩАЯ пища!\r\nВы переходите на бег, но он уже вовсю скачет в вашу сторону, резко сокращая дистанцию, издавая устрашающие вопли, смешанные с хрюканьем.",
			paramsChanges = { -- amount: 24
				{
					index = "[p1]",
					change = -1,
					showingType = 0, -- don't change
					isChangePercentage = false,
					isChangeValue = true,
					isChangeFormula = false,
					changingFormula = "",
				},
			},
		},
		{
			index = 80, -- number
			id = 90, -- jump [J90]
			fromLocationId = 16, -- from[L16]
			toLocationId = 17, -- to[L17]
			jumpingCountLimit = 1,
			text = "Спасаться бегством",
			description = "Отгоняя от себя дурные предчувствия, вы ускоряете шаг. Гобзавр устремляется к вам, окончательно забыв про свою игру. Вы переходите на бег, но он уже вовсю скачет в вашу сторону, резко сокращая дистанцию, издавая устрашающие вопли, смешанные с хрюканьем...",
		},
	},
}