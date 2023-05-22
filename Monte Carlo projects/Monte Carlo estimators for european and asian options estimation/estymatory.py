import numpy as np
from math import exp, sqrt
from scipy.stats.distributions import chi2

r = 0.05
sigma = 0.25
S0 = 100
K = 100


def bm(n):
    cov_matrix = np.zeros((n,n))
    for r in range(n):
        for c in range(n):
            cov_matrix[r,c] = (min(r,c)+1)/n
    return np.random.multivariate_normal(np.zeros(n), cov_matrix)
	
def gbm_sum_cmc(n, anti=False):
    bms = bm(n)
    An = 0
    for t in range(1,n+1):
        An += S0*np.exp((r-sigma**2/2)*t/n+sigma*bms[t-1])
    return An/n
	
def CMC(n, R=1000, cv=False):
    Y=[]
    for j in range(R):
        An=gbm_sum_cmc(n)
        Y.append(np.exp(-r)*max(An-K,0))
    if cv:
        return Y
    return np.mean(Y)
	
	
def stratified_proportional(n=1, R=1000, m=10, optimal=False, Rs=None):
    Y_hat = 0
    p = 1/m
    Ri = int(R*p)
    sigmas_for_optimal = []

    # Cholesky decomposition Sigma=A*A^T
    A_matrix = np.zeros((n,n))
    for k in range(n):
        for j in range(n):
            if j<=k:
                A_matrix[k,j] = 1/np.sqrt(n)
            else:
                A_matrix[k,j] = 0

    for i in range(m):
        # draw brownian motion from m-th stratum
        if optimal and not Rs is None:
            Ri = int(Rs[i])
            if Ri==0:
                Ri=1
        dzeta = np.random.multivariate_normal(np.zeros(n), np.identity(n), Ri)
        X = dzeta.T/np.sqrt(np.sum(dzeta**2,axis=1))
        u = np.random.uniform(0,1,Ri)
        D = np.sqrt(chi2.ppf(u/m + i/m, df=n))
        Z = X*D
        bms = np.dot(A_matrix,Z).T

        # calculate m-th estimator
        An = np.sum(S0*np.exp(r - sigma**2/2 + sigma*bms), axis=1)
        Y = np.exp(-r)*np.maximum(An/n-K, 0)
        if optimal and Rs is None:
            sigmas_for_optimal.append(np.std(Y))
        Y_hat += np.mean(Y)

    if optimal and Rs is None:
        return sigmas_for_optimal
    return Y_hat/m
	
def stratified_optimal(n=1, R=1000, m=10):
    sigmas = stratified_proportional(n,R,m,optimal=True)
    Rs = sigmas/np.sum(sigmas)
    return stratified_proportional(n,R,m,True,R*Rs)
	
	
def gbm_sum_anti():
    bmplus = bm(1)
    bmminus = - bmplus
    An_plus = S0*np.exp((r-sigma**2/2)+sigma*bmplus)
    An_minus = S0*np.exp((r-sigma**2/2)+sigma*bmminus)
    return [An_plus, An_minus]

def antithetic(n=1, R=1000):
    R_sum=0
    for j in range(int(R/2)):
        An=gbm_sum_anti()
        R_sum += max(An[0]-K,0)
        R_sum += max(An[1]-K,0)
    Y_hat = np.exp(-r)*R_sum/R
    return Y_hat[0]
	

def CV(n=1, R=1000):
    X = []
    for _ in range(R):
        X.append(bm(1)[0]/R)
    Y = CMC(n, R, cv=True)
    Y_cmc = np.mean(Y)
    Y_cv = Y_cmc-np.cov(Y,X)[0,1]*np.mean(X)
    return Y_cv