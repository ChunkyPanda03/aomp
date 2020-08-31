# Using AOMP in Devito

<b>This installation method assumes python3 and python3-pip are installed.</b>

<b>Clone and install Devito.</b>
```
git clone https://github.com/devitocodes/devito.git
cd devito
git checkout v4.2.3
pip3 install -r requirements.txt
pip3 install -e .
cd benchmarks/user/
```

<b>Set up environment.</b>
If AOMP was installed via debian or rpm:
```
export AOMP=/usr/lib/aomp 
```
Otherwise:
```
export AOMP=/path/to/aomp 
```
```
export DEVITO_PLATFORM=amdgpuX DEVITO_ARCH=aomp DEVITO_LANGUAGE=openmp
export PATH=$AOMP/bin:$PATH
```
<b>Fix aompcc issue seen with AOMP 11.7-1 and older AOMP versions, may require sudo. This will be fixed in 11.8-0.</b>
```
sed -i "s/readlink \"\$cdir/readlink -f \"\$cdir/g" $AOMP/bin/aompcc
```
<b>Run acoustic benchmark with 256 grid size:</b>
```
LD_LIBRARY_PATH=$AOMP/lib python3 benchmark.py bench -P acoustic -bm O2 -d 256 256 256 -so 2 --tn 50 --autotune off
```

<b>Available benchmarks:</b>
acoustic
acoustic_sa
tti
elastic
viscoelastic

<b>Note: The tti benchmark exposes a bug with AOMP, which we are currently working on.</b>
To prevent future compilation issues it is recommended to remove the devito-jitcache before recompiling benchmarks that previously had compilation failures to avoid using a stale cached state.
```
rm -rf /tmp/devito-jitcache-uid<your-id-here>
```
