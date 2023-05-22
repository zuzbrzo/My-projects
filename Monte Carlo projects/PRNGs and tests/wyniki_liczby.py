### załadowanie danych
import numpy as np
from matplotlib import pyplot as plt
from scipy import stats as sstats
import pandas as pd
import urllib.request

def read_digits(url):
    
    data = []
    with urllib.request.urlopen(url) as f:
        for line in f:
            data.append(line.strip())
    datastring = []
    

    for line in data:
        datastring.append(line.decode("utf-8"))

    datastring = ''.join(datastring)
    datastring = list(map(int, list(datastring)))
    
    return(np.array(datastring))
    
    
digits_pi = read_digits('http://www.math.uni.wroc.pl/~rolski/Zajecia/data.pi')
digits_e = read_digits('http://www.math.uni.wroc.pl/~rolski/Zajecia/data.e')
digits_sqrt2 = read_digits('http://www.math.uni.wroc.pl/~rolski/Zajecia/data.sqrt2')

### TESTY

comparision_numbers_dict = {'Irrational number': ['pi', 'e', 'sqrt2'], 'RUNS': [], 'FM': [], 'CHI2': [], 'KS': [], 'second level RUNS': [], 'second level FM': [], 'second level CHI2': [], 'second level KS': []}

for num in [digits_pi, digits_e, digits_sqrt2]:
    for test in ['RUNS', 'FM']:
        result = test_rng(test, num)['p-value']
        comparision_numbers_dict[test].append(result)
        result = second_level_test(num, test)['p-value']
        comparision_numbers_dict['second level '+test].append(result)
    num1 = bit_to_num(num, zero_jeden=True)
    for test in ['CHI2', 'KS']:
        result = test_rng(test, num1)['p-value']
        comparision_numbers_dict[test].append(result)
        result = second_level_test(num1, test)['p-value']
        comparision_numbers_dict['second level '+test].append(result)

comparision_numbers_table = pd.DataFrame(comparision_numbers_dict)
print(comparision_numbers_table)