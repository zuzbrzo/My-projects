def num_to_bit(x, M, zero_jeden=False):
    multiply = 1
    if zero_jeden:
        multiply = M
    result = ""
    for num in x:
        result += format(M*num, f"0{int(np.log2(M))}b")
    return result


def bit_to_num(x, M=10, zero_jeden=True):
    divide = 1
    if zero_jeden:
        divide = 2**M
    parts = []
    temp_word = ''
    for i in x:
        temp_word += str(i)
        if len(temp_word)==M:
            parts.append(temp_word)
            temp_word = ''
    if len(x)%M != 0:
        parts.append(temp_word)

    result = []
    for l in parts:
        result.append(int(l,2)/divide)
    return result