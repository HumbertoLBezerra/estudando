#Faça um programa que receba o preço de um produto, calcule e mostre o novo preço, sabendo-
#se que este sofreu um desconto de 10%.

print("Esse programa vai aplicar um desconto de 10% no valor do produto inserido!")

valor = float(input("Insira o valor do produto: "))

print("O valor atual com desconto de 10% é: ", f"{valor*0.9:.2f}")