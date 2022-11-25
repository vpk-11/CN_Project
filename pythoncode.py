import math as ma
import numpy as np
import scipy as sp
import sympy as smp
#import matplotlib.pyplot as plt
from scipy.integrate import quad
from scipy.integrate import cumulative_trapezoid
import statistics as stat
from gurobipy import *
import subprocess

# Defining constants
R = 0.250
E = 0.991833
U0 = 25
DEL = 25
LAM = 250
LAMC = 200
ALP = 1.0250
PHI = 2.7168
GAM = 0.7
D = 700

# Finding cluster heads through MSSP and CHN
def cluster_head(arr,vel,x,y):
    n = len(vel)
    clusterheads = []
    graph = [[0]*n]*n
    edges = 0
    for i in range(0,n):
        for j in range(0,n):
            if i!=j:
                if(vel[i]>vel[j]):
                    if(y[i]==0): dirn=-1
                    else: dirn=1
                else:
                    if(y[j]==0): dirn=-1
                    else: dirn=1
                L = ma.sqrt(ma.pow(y[i] - y[j], 2)+ ma.pow(x[i] - x[j], 2))*dirn
                print(L)
                nmrt = ((-(vel[i] - vel[j]) * L) + (abs(vel[i] - vel[j]) * R))
                print(nmrt)
                dmtr = 1.0 * 2 * R * ma.pow(vel[i] - vel[j], 2)
                print(dmtr)
                print(" ")
                val = (nmrt/dmtr)
                # print(val)
                if val > E:
                    graph[i][j] = 1
                    graph[j][i] = 1
                    edges+=1
    print(graph)
    
    # Quadratic Programming Problem solver
    knapsack_model = Model('knapsack')
    x = knapsack_model.addVars(n, vtype=GRB.BINARY, name="x")
    obj_fn = -(sum(x[i] for i in range(n)))
    # x1 = np.matrix(x)
    knapsack_model.setObjective(obj_fn, GRB.MINIMIZE)
    knapsack_model.addConstr(sum(x[i] * (sum(x[j]*graph[j][i] for j in range(n))) for i in range(n)) <= 0)
    knapsack_model.addConstr(sum(x[i]*x[j] for i in range(1,n-1) for j in (i-1,i+1))<=0)
    knapsack_model.setParam('OutputFlag',False)
    knapsack_model.optimize()

    # Storing Cluster heads
    for v in knapsack_model.getVars():
        if v.x == 1:
            print(v.varName,v.x)
            if v.varName[3:4] == ']':
                clusterheads.append(int(v.varName[2:3]))
            else:
                clusterheads.append(int(v.varName[2:4]))
            

    sizeo = len(clusterheads)
    if(sizeo == 0):
        for v in knapsack_model.getVars():
            if v.x == 0:
                print(v.varName,v.x)
                if v.varName[3:4] == ']':
                    clusterheads.append(int(v.varName[2:3]))
                else:
                    clusterheads.append(int(v.varName[2:4]))
    
    # Debugging
    for p in range(sizeo):
        print(clusterheads[p])

    return clusterheads


# Modified K-Means Algorithm
def kmeans(arr,vel,x,y,C):
    n = len(vel)
    m = len(C)
    linkr = [[0] * n] * n
    T = [[0] * n] * n
    visited = [False] * n
    # print(visited)
    for qq in range(m):
        visited[C[qq]] = True
    
    # Creating dictionary for cluster head - node pairs
    final = {C[k]:[] for k in range(0,m)}

    # Finding mean, std.deviation and variance
    
    
    if len(vel) > 1:
        variance = stat.variance(vel)
        stand = stat.stdev(vel)
        mean = stat.mean(vel)
    else:
        variance = 1
        stand = 1
        mean = 0
    denm = 2 * variance
    constantVar = 4*R/(stand*2.505)
    t=smp.Symbol('t')
    f = 1/(t**2) * smp.exp(-(2*R/(t)-mean)/denm)  
    maxans = 0
    ind = -1  

    # Creating clusters
    for i in range(0, n):
        flag = 0
        for j in range(0, m):
            if visited[i]!=True:
                # print(i)
                flag = 1
                L = ma.sqrt(ma.pow(y[i] - y[C[j]], 2) + ma.pow(x[i] - x[C[j]], 2))
                delV = vel[i] - vel[C[j]]
                T[i][j] = L / delV

                # Integrate
                intgr = smp.integrate(f,(t,0,T[i][j]))
                
                
                if LAM<LAMC:
                    intgr = constantVar * (LAM/LAMC) * intgr
                else :
                    intgr = constantVar * intgr
                if intgr > maxans:
                    maxans = intgr
                    ind = j
        if flag == 1:
            visited[i] = True
            final[C[ind]].append(i)
        maxans = 0

    # Cluster maintainence
    flag1 = False
    for key2 in range(m):
        if len(final[C[key2]])!=0:
            flag1= True
            break
    if flag1 == True:
        temp1=[]
        for key1 in range(m):
            if len(final[C[key1]])==0:
                visited[C[key1]]=False
                temp1.append(C[key1])
        for i in temp1:
            del final[i]
            C.remove(i)
        m = len(C)

    # Updating Cluster heads
    for i in range(0,n):
        flag = 0
        for j in range(0,m):
            if visited[i]!=True:
                # print(i)
                flag = 1
                L = ma.sqrt(ma.pow(y[i]-y[C[j]],2)+ma.pow(x[i]-x[C[j]],2))
                delV = vel[i] - vel[C[j]]
                T[i][j] = L / delV
                intgr = smp.integrate(f,(t,0,T[i][j]))
                if LAM<LAMC:
                    intgr = (LAM/LAMC) * intgr
                if intgr>maxans:
                    maxans = intgr
                    ind = j
        if flag==1:
            visited[i]=True
            final[C[ind]].append(i)
        maxans=0

    # Storing into one string
    str1 = ""
    for ti in range(m):
        str1+= str(C[ti])
        # str1+=" "
        for o in final[C[ti]]:
            str1 += " "
            str1 += str(o)
            # str1+= " "
        if ti!=m-1:
            str1+='\n'
    # File Handling
    file = open("Cluster.txt",'w')

    file.write(str1)
    file.close()

# arr = [1,2,3,4,5,6,7,8,9,10]
# vel = [60,70,-70,65,-75,90,120,-60,95,110]
# x = [7,3,1,2,2,4,5,9,6,80]
# # vel = [60,70,-70,-62,85,90,100,-60,-95,110]
# # x = [0.120,0.130,0.140,0.150,0.160,0.170,0.170,0.180,0.190,0.200]
# y = [1,1,0,0,1,1,1,0,0,1]
# # y = [0.500,0.500,0.250,0.250,0.500,0.500,0.500,0.250,0.250,0.500]
def advancekmeans(x,y,vel,C):
    w1=0.4
    w2=0.6
    n = len(vel)
    m = len(C)
    final = {C[k]:[] for k in range(0,m)}
    visited = [False] * n
    for qq in range(m):
        visited[C[qq]] = True
    maxans = 0
    ind = -1 
    for i in range(n):
        flag = 0
        for j in range(m):
            if visited[i]!=True:
                flag=1
                param1 = w1 * (vel[i] - vel[C[j]]/max(vel))
                L = ma.sqrt(ma.pow(y[i] - y[C[j]], 2) + ma.pow(x[i] - x[C[j]], 2))
                param2 = w2 * L
                intgr = param1 - param2
                if intgr > maxans:
                        maxans = intgr
                        ind = j
        if flag == 1:
            visited[i] = True
            final[C[ind]].append(i)
        maxans = 0

    flag1 = False
    for key2 in range(m):
        if len(final[C[key2]])!=0:
            flag1= True
            break
    if flag1 == True:
        temp1=[]
        for key1 in range(m):
            if len(final[C[key1]])==0:
                visited[C[key1]]=False
                temp1.append(C[key1])
        for i in temp1:
            del final[i]
            C.remove(i)
        m = len(C)
    
    
    for i in range(n):
        flag = 0
        for j in range(m):
            if visited[i]!=True:
                flag = 1
                if vel[i]>0:
                    param1 = 10
                else :
                    param1 = -1
                param1 = w1 * (vel[i] - vel[C[j]]/max(vel))
                L = ma.sqrt(ma.pow(y[i] - y[C[j]], 2) + ma.pow(x[i] - x[C[j]], 2))
                param2 = w2 * L
                intgr = param1 - param2
                if intgr > maxans:
                        maxans = intgr
                        ind = j
        if flag == 1:
            visited[i] = True
            final[C[ind]].append(i)
        maxans = 0

    str1 = ""
    for ti in range(m):
        str1+= str(C[ti])
        # str1+=" "
        for o in final[C[ti]]:
            str1 += " "
            str1 += str(o)
            # str1+= " "
        if ti!=m-1:
            str1+='\n'
    # File Handling
    file = open("Cluster.txt",'w')

    file.write(str1)
    file.close()


def remaining_nodes(x,y,vel,t):
    for i in vel:
        if abs(i*t)>D:
            ind = vel.index(i)
            vel.pop(ind)
            x.pop(ind)
            y.pop(ind)
        elif i==0:
            ind = vel.index(i)
            vel.pop(ind)
            x.pop(ind)
            y.pop(ind)
        else:
            ind = vel.index(i)
            x[ind]=x[ind]+(i*t)
    

arr = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
# vel = [60,70,-70,65,-75,90,120,-60,95,110]



# vel = [60,70,65,-85,75,90,120,-100,-115,110]

vel = [60,70,65,-85,75,90,120,-100,-115,110,61,71,82,93,104]
# vel = [60,70,65,85,75,90,120,100,115,110,61,71,82,93,104]
print(len(vel))

# Distances are in metres/10
x = [7,3,1,2,2,4,5,5,6,8,12,11,7,4,7]
print(len(x))
y = [1,1,1,0,1,1,1,0,0,1,1,1,1,1,1,1]
print(len(y))
# Storing into one string
def inputtxt(x,y,vel,arr):
    str1 = ""
    m = len(vel)
    for ti in range(m):
        str1 += str(arr[ti] - 1)
        str1 += " "
        str1 += str(x[ti] + 250)
        str1 += " "
        if y[ti] == 1:
            str1 += str(500)
        else:
            str1 += str(250)
        str1 += " "
        str1 += str(abs(vel[ti]))
        str1 += " "
        if y[ti] == 1:
            str1 += str(999)
            str1 += " "
            str1 += str(500)
        else:
            str1 += str(1)
            str1 += " "
            str1 += str(250)
        if ti!=m-1:
            str1+='\n'

    #File Handling
    file = open("Input.txt",'w')
    file.write(str1)
    file.close()

# upvel=vel
inputtxt(x,y,vel,arr)
ch = cluster_head(arr,vel,x,y)
kmeans(arr,vel,x,y,ch)
# advancekmeans(x,y,vel,ch)
# subprocess.call(['sh','./test.sh'])

# remaining_nodes(x,y,vel,40)
# ch = cluster_head(arr,vel,x,y)
# # kmeans(arr,vel,x,y,ch)
# inputtxt(x,y,vel,arr)
# advancekmeans(x,y,vel,ch)
# # subprocess.call(['sh','./shellscript.sh'])

# remaining_nodes(x,y,vel,50)
# ch = cluster_head(arr,vel,x,y)
# # kmeans(arr,vel,x,y,ch)
# inputtxt(x,y,vel,arr)
# advancekmeans(x,y,vel,ch)
# # subprocess.call(['sh','./shellscript.sh'])

# remaining_nodes(x,y,vel,60)
# ch = cluster_head(arr,vel,x,y)
# # kmeans(arr,vel,x,y,ch)
# inputtxt(x,y,vel,arr)
# advancekmeans(x,y,vel,ch)
# subprocess.call(['sh','./shellscript.sh'])

# ch = cluster_head(arr,vel,x,y)
# kmeans(arr,vel,x,y,ch)