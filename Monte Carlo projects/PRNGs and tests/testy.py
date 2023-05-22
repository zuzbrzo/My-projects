import numpy as np
from scipy.stats import norm
from scipy import stats, special
from numpy import histogram, sqrt

def chisquare_test(x, k=15):
    '''
    input: floats from 0 to 1
    '''
    n = len(x)   
    observed = np.histogram(x, bins=k, range=(0,1))[0]
    expected = [n/k]*k
    statistic = np.sum((observed-expected)**2/expected)
    p_value = 1-stats.chi2.cdf(statistic, k-1)
    
    return({'statistic':statistic, 'p-value':p_value})

def KS_test(x):
    '''
    input: floats from 0 to 1
    '''
    x = sorted(np.array(x))
    n = len(x)
    Dn_plus = np.max(x - np.arange(n)/n)
    Dn_minus = np.max(np.arange(1, n+1)/n - x)
    Dn = max(Dn_plus, Dn_minus)
    p_value = special.kolmogorov(n**0.5*Dn)
    
    return({'statistic':Dn, 'p-value':p_value})

def freq_monobit_test(x):
    '''
    input: bits
    '''
    x = [2*int(el)-1 for el in x]
    n = len(x)
    statistic = abs(sum(x))/sqrt(n)
    p_value = 2*(1-norm.cdf(statistic))

    return({'statistic': statistic, 'p-value': p_value})

def runs_test(x):
    '''
    input: bits
    '''
    n = len(x)
    tau = 2/n**0.5
    x = np.array(list(map(int, x)))
    pi_n = np.mean(x)
    y = (x[1:]+x[:-1]) %2
    
    if(np.abs(pi_n-0.5) >= tau):
        V_n = np.NaN
        p_value = 0
    else:
        V_n = np.sum(y) + 1
        p_value = erfc(abs(V_n-2*n*pi_n*(1-pi_n))/(2*pi_n*(1-pi_n)*sqrt(2*n)))

    return({'statistic': V_n, 'p-value': p_value})


def second_level_test(x, test_name, test2_name='CHI2', bins=100, parameters=15):
    
    x = np.array(x) 
    p_values = []
    n = len(x) # mamy ciąg n liczb losowych
    N = int(np.floor(n/bins)) # dzielimy n liczb losowych na bins przedziałów każdy długości N

    for i in range(bins): 
        p_value = test_rng(test_name, x[N*i:N*(i+1)-1], parameters)['p-value']
        p_values.append(p_value)
    
    return test_rng(test2_name, p_values)