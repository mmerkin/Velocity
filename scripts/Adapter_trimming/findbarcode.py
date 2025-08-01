import sys
import re

r1=sys.argv[1]
name=r1.split("/")[-1]
pattern="[A-Z|a-z]{2,4}-[0-9]{2}-[0-9]{4}-[0-9]{2,3}"
search= re.search(pattern,name)
name=search.group()
barcodes=[]
barcodefile=open("/home/florat/velocity/velocityadapters/velocity_individual-barcodes.txt", "r")
for line in barcodefile:
    search=re.search(name, line)
    if search:
        try:
                barcode=line.split()[1]
                barcodes.append(barcode)
        except:
                continue

if len(barcodes)==0:
    barcodefile = open("/home/florat/velocity/velocityadapters/originalname_velocity_indiv-barcode.txt","r")
    for line in barcodefile:
        search = re.search(name, line)
        if search:
            barcode = line.split()[1]
            barcodes.append(barcode)
if len(barcodes)==1:
    print(barcodes[0])
    exit()
elif len(barcodes)>1:
    exit(1)
else:
    exit()
