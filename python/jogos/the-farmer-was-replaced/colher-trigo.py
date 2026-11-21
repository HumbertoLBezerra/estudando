while True:
	for i in range(get_world_size()):
		for i in range(get_world_size()):
			if get_water() <= 0.25:
				use_item(Items.Water)
			if can_harvest():
				harvest()
			move(North)
		move(West)