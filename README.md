# travisci missing docs
This repo attempts to document travis-ci.com's quirks to supplement the existing documentation available online.

## travisci job build trigger documentation
### without merge_mode
https://travis-ci.com/juancarlostong/travisci-docs/builds/110776085
```
env:
  global:
    var4=4
after_success:
  - echo "af $var4 $var3 $var2 $var1"
```

result (good):
```
Setting environment variables from .travis.yml
$ export var4=4
$ bash -c 'echo $BASH_VERSION'
4.3.11(1)-release
0.00s$ echo "s $var1 $var2 $var3 $var4"
s    4
The command "echo "s $var1 $var2 $var3 $var4"" exited with 0.
after_success
0.00s$ echo "af $var4 $var3 $var2 $var1"
af 4
```

### with merge_mode: deep_merge
https://travis-ci.com/juancarlostong/travisci-docs/builds/110777879
```
merge_mode: deep_merge
env:
  global:
    var4=4
after_success:
  - echo "af $var4 $var3 $var2 $var1"
```

result (bad):
```
Setting environment variables from .travis.yml
$ export var4=4
$ bash -c 'echo $BASH_VERSION'
4.3.11(1)-release
0.00s$ echo "s $var1 $var2 $var3 $var4"
s    4
The command "echo "s $var1 $var2 $var3 $var4"" exited with 0.
after_success
0.00s$ echo "af $var4 $var3 $var2 $var1"
af 4
Done. Your build exited with 0.
```

### with merge_mode: deep_merge dont use = sign
https://travis-ci.com/juancarlostong/travisci-docs/builds/110778344
```
merge_mode: deep_merge
env:
  global:
    var4: 4
after_success:
  - echo "af $var4 $var3 $var2 $var1"
```

result (good):
```
Setting environment variables from .travis.yml
$ export var1=1
$ export var2=2
$ export var3=3
$ export var4=4
$ bash -c 'echo $BASH_VERSION'
4.3.11(1)-release
0.00s$ echo "s $var1 $var2 $var3 $var4"
s 1 2 3 4
The command "echo "s $var1 $var2 $var3 $var4"" exited with 0.
after_success
0.00s$ echo "af $var4 $var3 $var2 $var1"
af 4 3 2 1
```


### with merge_mode: deep_merge with changes to after_success
now that we got deep_merge working, let's see if we can deep merge after_success steps
ie. can we run both `echo "af $var1 $var2 $var3 $var4"` in .travis.yml as well as `echo "af $var4 $var3 $var2 $var1"` that comes from the build trigger payload?

https://travis-ci.com/juancarlostong/travisci-docs/builds/110779451
```
merge_mode: deep_merge
env:
  global:
    var4: 4
after_success:
  echo "af $var4 $var3 $var2 $var1"
```

result (bad):

made no difference from prev run
```
Setting environment variables from .travis.yml
$ export var1=1
$ export var2=2
$ export var3=3
$ export var4=4
$ bash -c 'echo $BASH_VERSION'
4.3.11(1)-release
0.00s$ echo "s $var1 $var2 $var3 $var4"
s 1 2 3 4
The command "echo "s $var1 $var2 $var3 $var4"" exited with 0.
after_success
0.00s$ echo "af $var4 $var3 $var2 $var1"
af 4 3 2 1
```

### with merge_mode: deep_merge with changes to script
maybe it only works for script section?
ie. can we run both `echo "af $var1 $var2 $var3 $var4"` in .travis.yml as well as `echo "af $var4 $var3 $var2 $var1"` that comes from the build trigger payload?

https://travis-ci.com/juancarlostong/travisci-docs/builds/110780013
```
merge_mode: deep_merge
env:
  global:
    var4: 4
script:
  echo "s $var4 $var3 $var2 $var1"
```

results (bad):

it looks like we deep_merge only applies to variables and not to sections like script or after_success.
```
Setting environment variables from .travis.yml
$ export var1=1
$ export var2=2
$ export var3=3
$ export var4=4
$ bash -c 'echo $BASH_VERSION'
4.3.11(1)-release
0.00s$ echo "s $var4 $var3 $var2 $var1"
s 4 3 2 1
The command "echo "s $var4 $var3 $var2 $var1"" exited with 0.
after_success
0.00s$ echo "af $var1 $var2 $var3 $var4"
af 1 2 3 4
```
