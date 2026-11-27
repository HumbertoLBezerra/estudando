#Faça um programa que receba três números reais (a, b, c), calcule e mostre a subtração do
#primeiro pelo segundo e pelo terceiro (a – b – c), a soma dos três (a + b + c), a multiplicação dos
#três (a * b * c) e a divisão dos três (a / b / c).

print("Esse programa vai solicitar 3 valores e mostrar algumas operações com eles.")
valor1 = float(input("Insira o 1° valor: "))
valor2 = float(input("Insira o 2° valor: "))
valor3= float(input("Insira o 3° valor: "))

print(valor1,"-",valor2,"-",valor3,"=",f"{valor1-valor2-valor3:.2f}")
print(valor1,"+",valor2,"+",valor3,"=",f"{valor1+valor2+valor3:.2f}")
print(valor1,"*",valor2,"*",valor3,"=",f"{valor1*valor2*valor3:.2f}")
print(valor1,"/",valor2,"/",valor3,"=",f"{valor1/valor2/valor3:.2f}")