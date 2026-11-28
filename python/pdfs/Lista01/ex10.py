#Faça um programa que calcule e mostre a área de um trapézio. Sabe-se que
#área do trapézio=(( base maior +base menor )⋅altura)/2 . Seu programa deve receber os valores para a base maior, base menor e altura.

print("Esse programa vai calcular a área de um trapézio!")

baseMenor = float(input("Insira o valor da base menor: "))
baseMaior = float(input("Insira do valor da base maior: "))
altura = float(input("Insira o valor da altura: "))

areaTrapezio = ((baseMaior+baseMenor)*altura)/2

print("O valor da área do trapézio é: ", f"{areaTrapezio:.2f}", "cm²")

