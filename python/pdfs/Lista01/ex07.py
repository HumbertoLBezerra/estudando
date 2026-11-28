#Um funcionário recebe um salário fixo mais 4% de comissão sobre vendas. Faça um programa
#que receba o salário fixo do funcionário e o valor de suas vendas, calcule e mostre o valor da
#comissão e do seu salário final.

print("Esse programa vai calcular o seu salário com o adicional das comissões de suas vendas! ")
salario = float(input("Insira o valor do seu salário: "))
comissao = float(input("Insira o valor das suas vendas esse mês: "))

salarioCompleto = salario+(comissao*0.04)

print("O seu salário total esse mês é de: ", f"{salarioCompleto:.2f}")