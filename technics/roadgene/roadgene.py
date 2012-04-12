import random
def pres(c):
	if c==0:return ' '
	elif c>1:return 'm'
	else: return '+'
grid = [[j%2+i%2 for i in xrange(64)] for j in xrange(64)]
def printgrid(grid):
	for j,v in enumerate(grid):
		print reduce(lambda a,b:a+str(b),v,'')
		#print reduce(lambda a,b:a+pres(b),v,'')

n = 300
while n>0:
	a,b=random.randrange(32)*2+1,random.randrange(32)*2+1
	if grid[a][b] != 0:
		if a>0:grid[a-1][b]=0
		if a<63:grid[a+1][b]=0
		if b>0:grid[a][b-1]=0
		if b<63:grid[a][b+1]=0
		grid[a][b]=0
		n-=1
for b in xrange(64):
	for a in xrange(64):
		if grid[a][b] == 2:
			n=''
			if a>0 and grid[a-1][b]>0:n+='l'
			if a<63 and grid[a+1][b]>0:n+='r'
			if b>0 and grid[a][b-1]>0:n+='t'
			if b<63 and grid[a][b+1]>0:n+='b'
			grid[a][b]=n
		elif grid[a][b] == 1:
			if b%2==0:
				grid[a][b]='tb'
			else:
				grid[a][b]='lr'
print grid