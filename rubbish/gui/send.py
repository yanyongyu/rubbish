

def getFileno(temp, instr):
    fileno = temp.fileno()
    temp.truncate(0)
    temp.seek(0)
    temp.write(instr)
    temp.flush()
    temp.seek(0)

    print(temp.read())
    return fileno


def recieve(rtemp):
    rtemp.flush()
    rtemp.seek(0)
    value = rtemp.read().decode('utf-8')
    return value
