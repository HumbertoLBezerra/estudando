while True:
	tamanho = get_world_size()
	for i in range(get_world_size()):
		if (i%2 != 0):
			for i in range(get_world_size()):
				if get_water() <= 0.5:
					use_item(Items.Water)
				if (i%2 != 0):
					if get_ground_type() == Grounds.Grassland:
						till()
						plant(Entities.Carrot)
					else:
						plant(Entities.Carrot)
					if can_harvest():
						harvest()
						plant(Entities.Carrot)
					move(North)
				else:
					if get_water() <= 0.5:
						use_item(Items.Water)
					plant(Entities.Tree)
					if can_harvest():
						harvest()
						plant(Entities.Tree)
					move(North)
		else:
			for i in range(get_world_size()):
				if (i%2 == 0):
					if get_water() <= 0.5:
						use_item(Items.Water)
					plant(Entities.Carrot)
					if get_ground_type() == Grounds.Grassland:
						till()
						plant(Entities.Carrot)
					else:
						plant(Entities.Carrot)
					if can_harvest():
						harvest()
						plant(Entities.Carrot)
					move(North)
				else:
					if get_water() <= 0.5:
						use_item(Items.Water)
					plant(Entities.Tree)
					if can_harvest():
						harvest()
						plant(Entities.Tree)
					move(North)
		move(West)
