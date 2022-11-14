import math as ma
import numpy as np
import scipy as sp
import sympy as smp
#import matplotlib.pyplot as plt
from scipy.integrate import quad
from scipy.integrate import cumulative_trapezoid
import statistics as stat
from gurobipy import *

#Defining constants
R = 0.250
E = 0.991833
U0 = 25
DEL = 25
LAM = 250
LAMC = 200
ALP = 1.0250
PHI = 2.7168
GAM = 0.7

#Finding cluster heads through MSSP and CHN
def cluster_head(arr,vel,x,y):
    n = len(arr)
    clusterheads = []
    graph = [[0]*n]*n
    for i in range(0,n):
        for j in range(0,n):
            if i!=j:
                L = ma.sqrt(ma.pow(y[i]-y[j],2)+ma.pow(x[i]-x[j],2))
                nmrt = (-(vel[i]-vel[j]) * L) + (abs(vel[i]-vel[j])*R)
                dmtr = 1.0 * 2 * R * ma.pow(vel[i]-vel[j],2)
                #print(dmtr)
                val = nmrt/dmtr
                #print(val)
                if val > E:
                    graph[i][j]=1
                    graph[j][i]=1
    #print(graph)
    
    knapsack_model = Model('knapsack')
    x = knapsack_model.addVars(n,vtype=GRB.BINARY,name="x")
    obj_fn = -(sum(x[i] for i in range(n)))
    #x1 = np.matrix(x)
    knapsack_model.setObjective(obj_fn, GRB.MINIMIZE)
    knapsack_model.addConstr(sum(x[i]*(sum(x[j]*graph[j][i] for j in range(n))) for i in range(n))<=0)
    #knapsack_model.addConstr(x[i]+x[i+1]<=1 for i in range(n))
    knapsack_model.setParam('OutputFlag',False)
    knapsack_model.optimize()
    for v in knapsack_model.getVars():
        if v.x==1:
            clusterheads.append(int(v.varName[2:3]))
            # print(v.varName,v.x)

    # sizeo = len(clusterheads)
    
    #Debugging
    # for p in range(sizeo):
    #     print(clusterheads[p])

    return clusterheads


# Modified K-Means Algorithm
def kmeans(arr,vel,x,y,C):
    n = len(arr)
    m = len(C)
    linkr = [[0] * n] * n
    T = [[0] * n] * n
    visited=[False]*n
    # print(visited)
    for qq in range(m):
        visited[C[qq]]=True
    #Creating dictionary for cluster head - node pairs
    final={C[k]:[] for k in range(0,m)}

    stand=stat.stdev(vel)
    mean=stat.mean(vel)
    variance=stat.variance(vel)
    denm = 2 * variance
    constantVar = 4*R/(stand*2.505)
    t=smp.Symbol('t')
    f = 1/(t**2) * smp.exp(-(2*R/(t)-mean)/denm)  
    maxans = 0
    ind = -1  
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

    temp=C
    temp1=[]
    for key1 in range(m):
        if len(final[C[key1]])==0:
            visited[C[key1]]=False
            temp1.append(C[key1])
    for i in temp1:
        del final[i]
        C.remove(i)
    m = len(C)
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

    
    str1 = ""
    for ti in range(m):
        str1+= str(C[ti])
        str1+=" "
        for o in final[C[ti]]:
            str1+=str(o)
            str1+=" "
        str1+='\n'

    file = open("Input.txt",'w')
    file.write(str1)
    file.close()

arr = [0,1,2,3,4,5,6,7,8,9]
vel = [60,70,-70,65,-75,90,120,-60,95,110]
x = [7,3,1,2,2,4,5,5,6,8]
y = [1,1,1,0,1,1,1,0,0,1]

ch = cluster_head(arr,vel,x,y)
kmeans(arr,vel,x,y,ch)