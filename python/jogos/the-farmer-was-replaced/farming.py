def colher():
	if can_harvest():
		harvest()

def cenoura():
	if get_ground_type() == Grounds.Soil:
		plant(Entities.Carrot)
	else:
		till()
		plant(Entities.Carrot)

