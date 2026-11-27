#Faça um programa que receba dois números inteiros, calcule e mostre a divisão inteira do
#primeiro pelo segundo, o resto desta divisão e a divisão real do primeiro número pelo segundo.
#O usuário sabe que o segundo número não pode ser zero, portanto, não é necessário se
#preocupar com validações.

print("Por favor insira 2 valores e esse programa vai realizar algumas divisões com eles.")
valor1 = int(input("Insira o 1° valor: "))
valor2 = int(input("Insira o 2° valor: "))

print("A divisão inteira do primeiro pelo segundo:   |", valor1,"/",valor2, "| Resultado: ",f"{valor1/valor2:.2f}")
print("O resto da divisão do primeiro pelo segundo:  |", valor1,"%",valor2, "| Resultado: ",f"{valor1%valor2:.2f}")
print("A divisão real do primeiro pelo segundo:      |", valor1,"/",valor2, "| Resultado: ",f"{valor1//valor2:.2f}")
