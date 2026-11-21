tamanho = get_world_size()
for i in range(get_world_size()):
    if (tamanho%2 != 0):
        for i in range(get_world_size()):
            if (tamanho%2 != 0):
                plant(Entities.Carrot)
                if can_harvest():
                    harvest()
                    plant(Entities.Carrot)
                move(North)
            else:
                plant(Entities.Tree)
                if can_harvest():
                    harvest()
                    plant(Entities.Tree)
                move(North)
        move(West)
    else:
        for i in range(get_world_size()):
            if (tamanho%2 == 0):
                plant(Entities.Carrot)
                if can_harvest():
                    harvest()
                    plant(Entities.Carrot)
                move(North)
            else:
                plant(Entities.Tree)
                if can_harvest():
                    harvest()
                    plant(Entities.Tree)
                move(North)
    move(West)
