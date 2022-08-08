from fractions import gcd
def input1(file):
    a = []
    f = open(file, "r")
    str = f.readline()
    while(str != ""):
        a.append(str.strip().split(" "))
        str = f.readline()
    for i in range(len(a)):
        a[i][0] = int(a[i][0])
        a[i][1] = int(a[i][1])
    return a
elliptic = input1("ellipticpairs.txt")

def eval(n):
    w = open("ncomparetablefor"+ str(n) + ".txt", "w+")
    w.write("\documentclass{amsart}\n\usepackage{amssymb}\n\usepackage{longtable}\\begin{document}\n\\begin{center}\n\\begin{longtable}{| c | c |}\n\hline\n$(a , b)$ & $(\\frac{(a - 1)}{"  + str(n)  + "}, \\frac{(b + 1)}{ "+ str(n) + "}$\\\\\n\hline\n")
    for i in range(len(elliptic)):
        a = str(int((elliptic[i][0] - 1) / n))
        b = str(int((elliptic[i][1] - 1) / n))
        w.write("$(" + str(elliptic[i][0]) + ", " + str(elliptic[i][1]) + ")$ & $(" + a + ", " + b + ")$\\\\\n\hline\n")
    w.write("\end{longtable}\n\end{center}\n\end{document}")

def gentable(e, filename):
    w = open(filename, "w")
    w.write("\documentclass{amsart}\n\usepackage{amssymb}\n\usepackage{longtable}\\begin{document}\n\\begin{center}\n\\begin{longtable}{| c | c |}\n\hline\n$(a , b)$ & $(a \mod 3, b \mod 3)$\\\\\n\hline\n")
    for i in range(len(elliptic)):
        a = str(e[i][0])
        b = str(e[i][1])
        w.write("$(" + elliptic[i][0] + ", " + elliptic[i][1] + ")$ & $(" + a + ", " + b + ")$\\\\\n\hline\n")
    w.write("\end{longtable}\n\end{center}\n\end{document}")


def allsame(a):
    ret = True
    standard = a[0][0]
    for i in range(len(a)):
        if standard != a[i][0] or standard != a[i][1]:
            ret = False
            break
    return ret


def modsame(n):
    a = []
    i = 1
    while i < n + 1:
        f = []
        for j in range(len(elliptic)):
            f.append([elliptic[j][0] % i, elliptic[j][1] % i])
        if(allsame(f)):
            print "called"
            a.append(["Elliptic Pairs", "\mod " + str(i)])
        i = i + 1
    return a

def gentable2(e, filename):
    w = open(filename, "w+")
    w.write("\documentclass{amsart}\n\usepackage{amssymb}\n\usepackage{longtable}\\begin{document}\n\\begin{center}\n\\begin{longtable}{| c | c | c |}\n\hline\n$u$ & $6u+1$ & In Set?\\\\\n\hline\n")
    for i in range(e):
        a = str(e[i][0])
        b = str(e[i][1])
        c = str(e[i][2])
        w.write(a + " & " + b + " & " + c + "\\\\\n")
    w.write("\end{longtable}\n\end{center}\n\end{document}")

def contains(e, f):
    for i in range(len(e)):
        for j in range(len(e[0])):
            if f == e[i][j]:
                return True
    return False

def getdata(n):
    e = []
    for i in range(n + 1):
        x = "x"
        if(contains(elliptic, 6 * i + 1)):
            x = "\checkmark"
        e.append([i, 6 * i + 1, x])
        if i % 1000 == 0:
            print i
    gentable2(e, "6ntablefor" + str(n)+ ".txt")
    print "----------\nDONE\n-------"

def gentable3(e, filename):
    w = open(filename, "w+")
    w.write("\documentclass{amsart}\n\usepackage{amssymb}\n\usepackage{longtable}\\begin{document}\n\\begin{center}\n\\begin{longtable}{| c | c |}\n\hline\n$n$ & $6n + 1$\\\\\n\hline\n")
    for i in range(len(e)):
        a = str(e[i][0])
        b = str(e[i][1])
        w.write(a + " & " + b + "\\\\\n\hline\n")
    w.write("\end{longtable}\n\end{center}\n\end{document}")


def getdata2(n):
    e = []
    for i in range(n + 1):
        if(contains(elliptic, 6 * i + 1)):
            e.append([i, 6 * i + 1])
        if i % 1000 == 0:
            print i
    gentable3(e, "6ntablefor" + str(n)+ ".txt")
    print "----------\nDONE\n-------"

def getdata3(n):
    e = []
    for i in range(n + 1):
        if(contains(elliptic, 2 * i + 1)):
            e.append([i, 2 * i + 1])
        if i % 1000 == 0:
            print i
    gentable3(e, "2ntablefor" + str(n)+ ".txt")
    print "----------\nDONE\n-------"

def f7(seq):
    seen = set()
    seen_add = seen.add
    return [x for x in seq if not (x in seen or seen_add(x))]

def input2(file):
    a = []
    f = open(file, "r")
    str = f.readline()
    while(str != ""):
        e = (str.strip().split(" "))
        a.append(e[0])
        a.append(e[1])
        str = f.readline()
    for i in range(len(a)):
        a[i] = int(a[i])
    a.sort()
    return a
ell = f7(input2("ellipticpairs.txt"))

def getdataadv(m):
    e = []
    for i in range(len(ell)):
        e.append([ int((ell[i] - 1) / m), ell[i]])
        if i % 1000 == 0:
            print i
    gentable3(e, str(m) + "ntable" + ".txt")
    print "----------\nDONE\n-------"

def biggap():
    big = 0
    for i in  range(1, len(ell)):
        if abs(ell[i] - ell[i - 1]) > big:
            big = abs(ell[i] - ell[i - 1])
    return big
print biggap()

def allcoprime(n):
    e = []
    for i in range(len(elliptic)):
        e.append([int((elliptic[i][0] - 1) / n), int((elliptic[i][1] - 1) / n)])
    for i in range(len(e)):
        if(gcd(e[i][0], e[i][1]) != 1 and gcd(e[i][0], e[i][1]) != 3 and e[i][0] != e[i][1]):
            print "NOT TRUE. Exception: " + str(e[i][0]) + " " + str(e[i][1])
            return False
    return True
print allcoprime(6)