import random

def LCG(n, M=13, a=1, c=5, seed=1, zero_one=True):
    
        count = 0
        while count < n:
            next = (a * seed + c) % M
            if zero_one:
                yield next/M
            else:
                yield next
            count += 1
            seed = next


def GLCG(n, M=2**10, a=[3, 7, 68], seeds=[0, 1, 2], zero_one=True):
    
        count = 0
        while count < n:
            next = (a[0] * seeds[0] + a[1] * seeds[1] + a[2] * seeds[2]) % M
            count += 1
            seeds = [next, seeds[0], seeds[1]]
            if zero_one:
                yield next/M
            else:
                yield next



def lag_Fib_gen(n=100, M=2**10, k=1, l=2, zero_one=True, init=None):
    
    if init is None:
        init = random.sample(range(M), max(k,l))
    for i in range(max(k,l), n+max(k,l)):
        x = (init[i-k]+init[i-l]) % M
        init.append(x)
        if zero_one:
            yield x/M
        else:
            yield x


def sub_lag_Fib_gen(n=100, M=2**10, k=1, l=2, zero_one=True, init=None):
    
    if init is None:
        init = random.sample(range(M), max(k,l))
    for i in range(max(k,l), n+max(k,l)):
        x = (init[i-k]-init[i-l]) % M
        init.append(x)
        if zero_one:
            yield x/M
        else:
            yield x


def RC4(n, M=32, K=list(range(40)), zero_one=True): 

    # KSA
    S = list(range(M))
    L = len(K)
    j = 0
    for i in range(M):
        j = (j + S[i] + K[i % L]) % M
        S[i], S[j] = S[j], S[i]
    
    #PRGA
    i, j = 0, 0
    count = 0
    while count<n:
        i = (i + 1) % M
        j = (j + S[i]) % M
        S[i], S[j] = S[j], S[i]
        y = S[(S[i] + S[j]) % M]
        count += 1
        if zero_one:
            yield y/M
        else:
            yield y


def xor(p, q):
    return (p+q) % 2

def xorg(n, seed='0001011011011001000101111001001010100110110110100010000001010111111010100100001010110110000000000100110000101110011111111100111'):
    count = 0
    while count < n:
        next = xor(int(seed[-1]), int(seed[0]))
        yield next
        count += 1
        seed = seed[1:] + str(next)
        

