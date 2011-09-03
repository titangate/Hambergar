import os
import glob
from tempfile import mkstemp
from shutil import move
def it(path,repo):
	listing = os.listdir(path)
	for infile in listing:
		if os.path.isdir(path+infile+'/'):
			print path+infile+'/'
			it(path+infile+'/',repo)
		elif infile[-4:]=='.lua':
			repo.append(path+infile)

repo = []
it('./',repo)
def reformat(oldfile):
	old_file = open(oldfile)
	fh,abs_path=mkstemp()
	new_file=open(abs_path,'w')
	for line in old_file:
		if line.find('love.graphics.newImage')!=-1:
			try:
				label,path = line.split('=')
				path = path.replace('love.graphics.newImage(','').replace(')','').replace('\n','').replace(' ','')
				label = label.replace(' ','').replace('local','')
				if label.find('[')==-1:
					newline = 'requireImage('+path+",'"+label+"')\n"
					if raw_input(line+'\t'+newline+' do you accept this change?')!='n':
						line=newline
						print 'chanced accepted'
			except:pass
		new_file.write(line)
	new_file.close()
	os.close(fh)
	old_file.close()
	os.remove(oldfile)
	move(abs_path,oldfile)

for f in repo:
	reformat(f)