### Równanie fali na odcinku

library(ggplot2)
library(plotly)
library(pracma)

t<-0
T<-10
dt<-0.01
dx<-0.01
u0<-rep(0,1/dx)
u0<-sin(linspace(0,2,2/dx)*pi)
c=1
C=c*dt/dx
k<-length(u0)
#u1<-u0+dt*linspace(0,2,2/dx)
u1<-u0
u1[2:(k-1)]<-u1[2:(k-1)]-(C^2)*(u0[1:(k-2)]+u0[3:k]-2*u0[2:(k-1)])/2
u<-rbind(u0,u1)
i<-2



while(t<T-dt){
  #un[1]<-0
  #un[length(un)]<-un[length(un)-1]+dx
  un<--u[i-1,]+2*u[i,]
  un[2:(k-1)]<-un[2:(k-1)]+(C^2)*(u[i,1:(k-2)]+u[i,3:k]-2*u[i,2:(k-1)])
  un[1]<-0
  un[length(un)]<-0 #un[length(un)-1]+dx
  u<-rbind(u,un)
  t<-t+dt
  i<-i+1
}
u0
plot(u[1,],type='l',ylim=c(-1,1))
u[1,]

for (i in 1:20){
plot(u[i*50,],type='l',ylim=c(-1,1))}

plot(u[1,],type='l',ylim=c(-1,1),xaxt='n',xlab='x',ylab='u(x,t)')
axis(1, at = seq(0, 200, 50), labels = c(0,0.5,1,1.5,2))
plot(u[30,],type='l',ylim=c(-1,1),xaxt='n',xlab='x',ylab='u(x,t)')
axis(1, at = seq(0, 200, 50), labels = c(0,0.5,1,1.5,2))
plot(u[50,],type='l',ylim=c(-1,1),xaxt='n',xlab='x',ylab='u(x,t)')
axis(1, at = seq(0, 200, 50), labels = c(0,0.5,1,1.5,2))
plot(u[80,],type='l',ylim=c(-1,1),xaxt='n',xlab='x',ylab='u(x,t)')
axis(1, at = seq(0, 200, 50), labels = c(0,0.5,1,1.5,2))

### Równanie fali na kwadracie

library(animation)
library(ggplot2)
library(plotly)
library(pracma)

dx<-0.04
u0<-matrix(0,50,50)
for (i in 25:0){
  v<-sin(linspace(0,2,2/dx)*pi)*(1-i/25)
  u0[25-i,]<-v
  u0[25+i,]<-v
}
plot_ly(z=u0,type='surface')

dt<-0.1
C<-1
T<-10
t<-0
i<-2
u <- array(0,dim=c(50,50,T/dt))
u[,,1]<-u0
u1<-u0
u1[2:(k-1),2:(k-1)]<-u1[2:(k-1),2:(k-1)]-(C^2)*(u0[1:(k-2),1:(k-2)]+u0[3:k,3:k]-2*u0[2:(k-1),2:(k-1)])/2
u[,,2]<-u1

while(t<T-3*dt){
  k<-50
  un<--u[,,i-1]+2*u[,,i]
  un[2:(k-1),2:(k-1)]<-un[2:(k-1),2:(k-1)]+(C^2)*(u[,,i][1:(k-2),1:(k-2)]+u[,,i][3:k,3:k]-2*u[,,i][2:(k-1),2:(k-1)])
  un[1,]<-0
  un[,1]<-0
  un[,k]<-0
  un[k,]<-0
  u[,,i+1]<-un
  t<-t+dt
  i<-i+1
}

plot_ly(z=u[,,1],type='surface')
plot_ly(z=u[,,2],type='surface')
plot_ly(z=u[,,3],type='surface')
plot_ly(z=u[,,4],type='surface')
plot_ly(z=u[,,5],type='surface')
plot_ly(z=u[,,6],type='surface')
plot_ly(z=u[,,7],type='surface')
plot_ly(z=u[,,8],type='surface')
plot_ly(z=u[,,9],type='surface')
plot_ly(z=u[,,10],type='surface')

Y<-as.data.frame.table(u)
p<-plot_ly(Y, x =~Var1, y=~Var2, z = ~Freq, frame =~Var3, type = 'heatmap')
p

## inny kszta³t

library(mnormt)
x     <- seq(-5, 5, 0.25) 
y     <- seq(-5, 5, 0.25)
mu    <- c(0, 0)
sigma <- matrix(c(1, 0, 0, 1), nrow = 2)
f     <- function(x, y) dmnorm(cbind(x, y), mu, sigma)
z     <- outer(x, y, f)

plot_ly(z=z,type='surface')

u0<-z
dt<-0.1
C<-1
T<-10
t<-0
i<-2
k<-41
u <- array(0,dim=c(k,k,T/dt))
u[,,1]<-u0
u1<-u0
u1[2:(k-1),2:(k-1)]<-u1[2:(k-1),2:(k-1)]-(C^2)*(u0[1:(k-2),1:(k-2)]+u0[3:k,3:k]-2*u0[2:(k-1),2:(k-1)])/2
u[,,2]<-u1

while(t<T-3*dt){
  un<--u[,,i-1]+2*u[,,i]
  un[2:(k-1),2:(k-1)]<-un[2:(k-1),2:(k-1)]+(C^2)*(u[,,i][1:(k-2),1:(k-2)]+u[,,i][3:k,3:k]-2*u[,,i][2:(k-1),2:(k-1)])
  un[1,]<-0
  un[,1]<-0
  un[,k]<-0
  un[k,]<-0
  u[,,i+1]<-un
  t<-t+dt
  i<-i+1
}

Y<-as.data.frame.table(u)
p<-plot_ly(Y, x =~Var1, y=~Var2, z = ~Freq, frame =~Var3, type = 'heatmap')
p











## inny kszta³t

k<-100
x<-(0:(k-1))/(k-1)
y<-(0:(k-1))/(k-1)
dx<-1/length(x)
dy<-1/length(y)
u0<-(sin(pi*x)%*%sin(pi*t(y)))

dt<-0.1
c<-0.01
cx<-c*dt/dx
cy<-c*dt/dy
T<-100
t<-0
i<-2
u <- array(0,dim=c(k,k,T/dt))
u[,,1]<-u0
u1<-u0
u1[2:(k-1),2:(k-1)]<-u0[2:(k-1),2:(k-1)]+0.5*(cx^2)*(u0[3:k,2:(k-1)]-2*u0[2:(k-1),2:(k-1)]+u0[1:(k-2),2:(k-1)])+0.5*(cy^2)*(u0[2:(k-1),3:k]-2*u0[2:(k-1),2:(k-1)]+u0[2:(k-1),1:(k-2)])
u[,,2]<-u1

while(t<T-3*dt){
  un<--u[,,i-1]+2*u[,,i]
  un[2:(k-1),2:(k-1)]<-un[2:(k-1),2:(k-1)]+(cx^2)*(u[,,i][1:(k-2),2:(k-1)]+u[,,i][3:k,2:(k-1)]-2*u[,,i][2:(k-1),2:(k-1)])+(cy^2)*(u[,,i][2:(k-1),1:(k-2)]+u[,,i][2:(k-1),3:k]-2*u[,,i][2:(k-1),2:(k-1)])
  un[1,]<-0
  un[,1]<-0
  un[,k]<-0
  un[k,]<-0
  u[,,i+1]<-un
  t<-t+dt
  i<-i+1
}
p<-plot_ly(z=u[,,1],type='surface')
p<-layout(p, scene = list(zaxis = list(range = c(-1,1))))
p
p<-plot_ly(z=u[,,300],type='surface')
p<-layout(p, scene = list(zaxis = list(range = c(-1,1))))
p
p<-plot_ly(z=u[,,500],type='surface')
p<-layout(p, scene = list(zaxis = list(range = c(-1,1))))
p
p<-plot_ly(z=u[,,800],type='surface')
p<-layout(p, scene = list(zaxis = list(range = c(-1,1))))
p



c(1,2)+c(3,2)
# prêdkoœæ pocz¹tkowa

T<-10
dt<-0.01
dx<-0.01
x<-linspace(0,2*pi,2*pi/dx)
u<-c()
for (l in 1:(T/dt)){
  t<-dt*l
  sum<-rep(0,length(x))
  for (n in 1:100){
    A<-f1(n)/pi
    B<-0
    step<-sin(n*x/2)*(A*cos(n*t/2)+B*sin(n*t/2))
    sum<-sum+step
  }
  u<-rbind(u,sum)
}
u[1,]



plot(u[1,],type='l',ylim=c(-20,20))
for (i in 1:20){
  plot(u[i*50,],type='l',ylim=c(-20,20))}

saveGIF({
  for (i in 1:50){
    plot(u[i*20,],type='l',ylim=c(-5,5))}
}, interval = 0.1, ani.width = 550, ani.height = 350)




## SZEREGI
library(ggplot2)
library(plotly)
library(pracma)
library(animation)

f1<-function(n){
  return(-8*(n*pi*sin(n*pi)+2*cos(n*pi)-2)/(n^3))
}
f2<-function(n){
  4*(2*sin(n*pi/2)-sin(n*pi))/(n^2)
}

T<-20
dt<-0.01
dx<-0.01
x<-linspace(0,2*pi,2*pi/dx)
u1<-rbind(c(),c())
u2<-rbind(c(),c())
for (l in 1:(T/dt)){
  t<-dt*l
  sum1<-rep(0,length(x))
  sum2<-rep(0,length(x))
  for (n in 1:1){
    A<-f2(n)/pi
    B<-2*f2(n)/(n*pi)
    step<-sin(n*x/2)*(A*cos(n*t/2)+B*sin(n*t/2))
    sum1<-sum1+step
  }
  u1<-rbind(u1,sum1)
  for (n in 1:100){
    A<-f2(n)/pi
    B<-2*f2(n)/(n*pi)
    step<-sin(n*x/2)*(A*cos(n*t/2)+B*sin(n*t/2))
    sum2<-sum2+step
  }
  u2<-rbind(u2,sum2)
}

plot(u1[1,],type='l',col='blue',ylim=c(-6,6))
lines(u2[1,],type='l',col='red')
plot(u1[50,],type='l',col='blue',ylim=c(-6,6))
lines(u2[100,],type='l',col='red')
plot(u1[1000,],type='l',ylim=c(-6,6),col='blue')
lines(u2[1000,],type='l',col='red')



p<-plot_ly(z=u,type='surface')
p<-layout(p, scene = list(zaxis = list(range = c(-22,22))))
p


T<-20
dt<-0.01
dx<-0.01
x<-linspace(0,2*pi,2*pi/dx)
uz<-rbind(c(),c())
for (l in 1:(T/dt)){
  t<-dt*l
  sum<-rep(0,length(x))
  for (n in 1:150){
    A<-f2(n)/pi
    B<-2*f2(n)/(n*pi)
    step<-sin(n*x/2)*(A*cos(n*t/2)+B*sin(n*t/2))
    sum<-sum+step
  }
  uz<-rbind(uz,sum)
}


k<-100
plot(u[k,],type='l',ylim=c(0,5),col="red")
lines(uz[k,],type='l',col="blue")
lines(ua[k,],type='l',col="orange")
lines(ub[k,],type='l',col="yellow")
lines(uc[k,],type='l',col="green")
lines(ud[k,],type='l',col="blue")
lines(ue[k,],type='l',col="violet")
lines(uf[k,],type='l')
legend(1,5,cex=1,legend=c("ró¿nice skoñczone","n=100","n=50","n=20","n=10","n=5","n=1"),col=c("red","orange","yellow","green","blue","violet","black"),lty=rep(1,7))




dim(u)
plot(u[1,],main="fi = 0, psi = x(2pi-x), t=0",type='l',ylim=c(-20,20))
grid()
plot(u[100,],main="fi = 0, psi = x(2pi-x), t=100",type='l',ylim=c(-20,20))
grid()
for (i in 1:9){
  plot(u[i*333,],main=paste("fi = 0, psi = x(2pi-x), psi = x(2pi-x), t=",i*300),type='l',ylim=c(-20,20))
  grid()}


plot(u[1300,],main="fi=psi = pi-|pi-x|, t=0",type='l',ylim=c(-20,20))
grid()
plot(u[100,],main="fi=psi = pi-|pi-x|, t=100",type='l',ylim=c(-5,5))
grid()
plot(u[350,],main="fi=psi = pi-|pi-x|, t=350",type='l',ylim=c(-5,5))
grid()
plot(u[700,],main="fi=psi = pi-|pi-x|, t=700",type='l',ylim=c(-5,5))
grid()
plot(u[1100,],main="fi=psi = pi-|pi-x|, t=1100",type='l',ylim=c(-5,5))
grid()
plot(u[1250,],main="fi=psi = pi-|pi-x|, t=1250",type='l',ylim=c(-5,5))
grid()
plot(u[1500,],main="fi=psi = pi-|pi-x|, t=1500",type='l',ylim=c(-5,5))
grid()
plot(u[1800,],main="fi=psi = pi-|pi-x|, t=1800",type='l',ylim=c(-5,5))
grid()
plot(u[2300,],main="fi=psi = pi-|pi-x|, t=2300",type='l',ylim=c(-))
grid()


























