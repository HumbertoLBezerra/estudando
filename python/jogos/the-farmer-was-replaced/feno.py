while True:
	if get_water() <= 0.93:
		use_item(Items.Water)
	if can_harvest():
		harvest()