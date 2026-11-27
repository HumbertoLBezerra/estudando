#Faça um programa que receba dois inteiros, armazene o primeiro em uma variável chamada a e
#o segundo em uma variável chamada b. Depois troque o valor das variáveis, ou seja, a deverá
#ter o valor de b e vice-versa. Imprima a e b para mostrar que a troca foi realmente feita.

print("Insira dois valores, vamos atribuir eles nas variáveis A e B e então invertelos.")

a = int(input("Insira o 1° valor: "))
b = int(input("Insira o 2° valor: "))

c = a
a = b
b = c

print ("Valor de A: ", a ,"\nValor de B: ", b)