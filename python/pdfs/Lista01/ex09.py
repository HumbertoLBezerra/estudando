#Faça um programa que receba o peso de uma pessoa em quilos, calcule e mostre esse peso em
#gramas. Sabe-se que 1 quilo = 1000 gramas.

print("Esse programa vai converter seu peso em quilos para gramas!")
peso = float(input("Por favor, insira o seu peso: "))

print("Seu pego em gramas: ", f"{(peso*1000):.2f}", "Gramas")