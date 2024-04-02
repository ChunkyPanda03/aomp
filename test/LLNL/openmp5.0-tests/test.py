#!/usr/bin/env python3
from collections import defaultdict
import subprocess
import sys

if len(sys.argv) != 4:
  print ("Error: Argument list is incorrect. Test.py expects AOMP location, AOMP_GPU, and CLANG_HOST_TARGET.")
  exit(1)

AOMP = sys.argv[1]
AOMP_GPU = sys.argv[2]
CLANG_HOST_TARGET = sys.argv[3]

if AOMP == "":
  print ("Error: Please set AOMP env variable and rerun.")
  exit(1)
elif AOMP_GPU == "":
  print ("Error: Please set AOMP_GPU env variable and rerun.")
  exit(1)

def get_tests(file_name):
    d=defaultdict(list)
    with open(file_name,"r") as infile:
        for line in infile.readlines():
            #print(line)
            sline=line.split()
            for s in sline:
                d[sline[0][:-4]].append(s)
    return d

def run(tests):
    pass_count=0
    for t in tests:
        passs=True
        print("Running ",t,"...",end=" ")
        cmd="./"+t
        cmd_s=cmd.split()
        p4=subprocess.Popen(cmd_s,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        for lines in p4.stdout.readlines():
            #print(lines)
            if b"error" in lines:
                print("Failed")
                passs=False
                break
            if b"FAIL" in lines:
                print("Failed")
                passs=False
                break
        if passs: 
            print ("Passed")
            pass_count+=1
    return pass_count

def compile(CC,LIBS, tests):

    runnables=[]
    for key,value in tests.items():
        with open(key+".ERR","w") as efile:
            passs=True
            for v in value:
                fail=False
                cmd=CC+" -c "+ v
                cmd_s=cmd.split()
                p2=subprocess.Popen(cmd_s,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
                for lines in p2.stdout.readlines():
                    efile.write(lines.decode('utf8'))
                    if b"error" in lines:
                        fail=True
                        print("Compilation of ",v," failed")
                        passs = passs and not fail
                        break
                    passs = passs and not fail
 
            if passs:
                print("Compiling ",key)
                cmd = CC+" -o "+key
                for v in value:
                    cmd = cmd+" "+v[:-4]+".o"
                cmd = cmd+LIBS
                #print("Final compile command is ",cmd)
                cmd_s=cmd.split()
                p3=subprocess.Popen(cmd_s,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
                for lines in p3.stdout.readlines():
                    print(lines.decode('utf8'))
                    if b"error" in lines:
                        print("Linking of ",v," failed\n")
                        break
                runnables.append(key)
    return runnables
def main():
    tests=get_tests("test_list")
# Change Compile line in CC and LIBS
    CC="{}/bin/clang++  -O2  -target {} -fopenmp -fopenmp-targets=amdgcn-amd-amdhsa -Xopenmp-target=amdgcn-amd-amdhsa -march={}".format(AOMP, CLANG_HOST_TARGET, AOMP_GPU)
    LIBS = ""
# End Compile line 
    runnables=compile(CC,LIBS, tests)
    print("\nRunnable tests are:")
    for r in runnables:
        print(r)
    print()
    pass_count=run(runnables)
    print("There are ",len(tests.keys())," tests")
    print(len(runnables)," tests compiled successfully")
    print(pass_count," tests ran successfully")
if __name__=="__main__":
	main()
