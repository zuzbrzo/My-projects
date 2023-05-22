# zmiana True na False na końcu funkcji generate_numbers() poskutkuje zwróceniem liczb całkowitych do M, zamiast z odcinka jednostkowego
# ale wtedy należy też zrobić to samo w funkcji num_to_bit
n = 10000 # how many numbers to generate
show = 10 # how many numbers to show

# LCG
print('LCG')
seed = 1
x_lcg = generate_numbers('LCG', n, [13, 1, 5, seed], True); 
# x_lcg = generate_numbers('LCG', n, [2**10, 3, 7, seed], True);
# x_lcg = generate_numbers('LCG', n, [2**10, 5, 7, seed], True);
print(x_lcg[:show])
print('CHI2:', test_rng('CHI2', x_lcg))
print('KS:', test_rng('KS', x_lcg))
y_lcg = num_to_bit(x_lcg, 13, True)
print('RUNS:', test_rng('RUNS', y_lcg))
print('FM:', test_rng('FM', y_lcg))
print('\n')

# GLCG
print('GLCG')
seed = [10, 11, 14]
x_glcg = generate_numbers('GLCG', n, [2**10, [3, 7, 68], seed], True); 
# x_glcg = generate_numbers('GLCG', n, [2**13-1, [3, 7, 68], seed], True);
print(x_glcg[:show])
print('CHI2:', test_rng('CHI2', x_glcg))
print('KS:', test_rng('KS', x_glcg))
y_glcg = num_to_bit(x_glcg, 2**10, True)
print('RUNS:', test_rng('RUNS', y_glcg))
print('FM:', test_rng('FM', y_glcg))
print('\n')

# Lagged Fibonacci
print('Lagged Fibonacci')
# bez podania init ziarno jest losowe
# x_lf = generate_numbers('Lagged_Fibonacci', n, [2**10, 2, 1, init=[0,1]], True); 
x_lf = generate_numbers('Lagged_Fibonacci', n, [2**10, 5, 12], True);
# x_lf = generate_numbers('Lagged_Fibonacci', n, [2**30, 100, 37], True); 
print(x_lf[:show])
print('CHI2:', test_rng('CHI2', x_lf))
print('KS:', test_rng('KS', x_lf))
y_lf = num_to_bit(x_lf, 2**10, True)
print('RUNS:', test_rng('RUNS', y_lf))
print('FM:', test_rng('FM', y_lf))
print('\n')

# Substractive Lagged Fibonacci
print('Substractive Lagged Fibonacci')
# bez podania init ziarno jest losowe
x_slf = generate_numbers('Subtractive_Lagged_Fibonacci', n, [2**10, 5, 12], True);
# x_slf = generate_numbers('Subtractive_Lagged_Fibonacci', n, [2**30, 100, 37, init=[0,1]], True); 
print(x_slf[:show])
print('CHI2:', test_rng('CHI2', x_slf))
print('KS:', test_rng('KS', x_slf))
y_slf = num_to_bit(x_slf, 2**10, True)
print('RUNS:', test_rng('RUNS', y_slf))
print('FM:', test_rng('FM', y_slf))
print('\n')

# RC4
print('RC4')
x_rc = generate_numbers('RC4', n, [32, list(range(32))], True);
# key = [15, 10, 21, 13, 24]
# x_rc = generate_numbers('RC4', n, [32, key], True); 
print(x_rc[:show])
print('CHI2:', test_rng('CHI2', x_rc))
print('KS:', test_rng('KS', x_rc))
y_rc = num_to_bit(x_rc, 32, True)
print('RUNS:', test_rng('RUNS', y_rc))
print('FM:', test_rng('FM', y_rc))
print('\n')

# XORG
print('XORG')
seed = '0001011011011001000101111001001010100110110110100010000001010111111010100100001010110110000000000100110000101110011111111100111'
x_xorg = generate_numbers('XORG', n, [seed]);
print(x_xorg[:show])
print('RUNS:', test_rng('RUNS', x_xorg))
print('FM:', test_rng('FM', x_xorg))
y_xorg = bit_to_num(x_xorg, 32, True)
print('CHI2:', test_rng('CHI2', y_xorg))
print('KS:', test_rng('KS', y_xorg))
print('\n')

# Second-level testing
print('second level testing')
test1 = 'CHI2'
# test1 = 'KS'
print(test1)
print('LCG:', second_level_test(x_lcg, test1))
print('GLCG:', second_level_test(x_glcg, test1))
print('Lag Fib:', second_level_test(x_lf, test1))
print('Sub Lag Fib:', second_level_test(x_slf, test1))
print('RC4:', second_level_test(x_rc, test1))
print('XORG:', second_level_test(y_xorg, test1))
test2 = 'FM'
print(test2)
print('LCG:', second_level_test(y_lcg, test2))
print('GLCG:', second_level_test(y_glcg, test2))
print('Lag Fib:', second_level_test(y_lf, test2))
print('Sub Lag Fib:', second_level_test(y_slf, test2))
print('RC4:', second_level_test(y_rc, test2))
print('XORG:', second_level_test(x_xorg, test2))