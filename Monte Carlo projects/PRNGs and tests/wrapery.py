import matplotlib.pyplot as plt
plt.rcParams["figure.figsize"] = (6, 4)

def generate_numbers(generator_name, n, parameters, zero_one):
    result = []            
    if generator_name == 'LCG':
        for i in LCG(n, parameters[0], parameters[1], parameters[2], parameters[3], zero_one):
            result.append(i)
    elif generator_name == 'GLCG':
        for i in GLCG(n, parameters[0], parameters[1], parameters[2], zero_one):
            result.append(i)
    elif generator_name == 'Lagged_Fibonacci':
        if len(parameters) == 3:
            init = None
        else:
            init=parameters[3]
        for i in lag_Fib_gen(n,  parameters[0], parameters[1], parameters[2], zero_one, init):
            result.append(i)
    elif generator_name == 'Subtractive_Lagged_Fibonacci':
        if len(parameters) == 3:
            init = None
        else:
            init=parameters[3]
        for i in sub_lag_Fib_gen(n,  parameters[0], parameters[1], parameters[2], zero_one, init):
            result.append(i)
    elif generator_name == 'RC4':
        for i in RC4(n,  parameters[0], parameters[1], zero_one):
            result.append(i)
    elif generator_name == 'XORG':
        for i in xorg(n,  parameters[0]):
            result.append(i)
    
    return(result)

    
 def plot_numbers(generator_name, n, parameters, zero_one):

    result = generate_numbers(generator_name, n, parameters, zero_one)
    
    plt.plot(result)
    plt.grid()
    plt.title(generator_name)
    plt.ylim(0,1)
    plt.show()

    plt.hist(result, bins=10, range=(0,1))
    plt.grid()
    plt.title(generator_name)
    plt.show()   
    

def test_rng(test_name, x, parameters=10):
          
    if test_name == 'CHI2':
        return chisquare_test(x, parameters)
    elif test_name == 'KS':
        return KS_test(x)
    elif test_name == 'FM':
        return freq_monobit_test(x)
    elif test_name == 'RUNS':
        return runs_test(x)


