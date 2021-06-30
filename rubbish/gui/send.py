def getFileno(temp, instr):
    fileno = temp.fileno()
    temp.truncate(0)
    temp.seek(0)
    temp.write(instr.encode("utf-8"))
    temp.flush()
    temp.seek(0)
    return fileno


def receive(rtemp):
    rtemp.flush()
    rtemp.seek(0)
    value = rtemp.read().decode("utf-8")
    rtemp.truncate(0)
    rtemp.seek(0)
    return value
