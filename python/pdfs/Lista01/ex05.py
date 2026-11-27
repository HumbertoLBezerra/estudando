#Faça um programa que receba duas notas, calcule e mostre a média ponderada dessas notas,
#considerando peso 2 para a primeira e peso 3 para a segunda. 

print("Esse programa vai calcular suas médias!")

nota1 = float(input("Insira sua 1° nota: "))
nota2 = float(input("Insira sua 2° nota: "))

media = ((nota1*2)+(nota2*3))/5

print("Sua média é: ", f"{media:.2f}")