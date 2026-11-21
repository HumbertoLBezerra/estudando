import farming, utils

while True:
	tamanho = get_world_size()-1
	for i in range(get_world_size()):
		for i in range(get_world_size()):
			if i != tamanho:
				if i%2==0:
					utils.regar(0.5)
					farming.colher()
					farming.cenoura()
				else:
					utils.regar(0.5)
					farming.colher()
					plant(Entities.Tree)
				move(North)
			else:
				farming.colher()
				move(North)
		move(East)

		for i in range(get_world_size()):
			if i != tamanho:
				if i%2==0:
					utils.regar(0.5)
					farming.colher()
					plant(Entities.Tree)
				else:
					utils.regar(0.5)
					farming.colher()
					farming.cenoura()
				move(North)
			else:
				farming.colher()
				move(North)
		move(East)

