#Faça um programa que receba o peso de uma pessoa, calcule e mostre:
#a) O novo peso, supondo que a pessoa engordou 15% do peso digitado;
#b) O novo peso, supondo que a pessoa emagreceu 20% do peso digitado.

peso = float(input("Por favor, insira o seu peso: "))

print("Esse seria o seu peso caso engordasse 15%: ", f"{(peso*1.15):.2f}")
print("Esse seria o seu peso caso emagrecesse 20%: ", f"{(peso*0.80):.2f}")