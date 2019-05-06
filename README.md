# travis

## travisci job build trigger documentation
### without merge_mode
```
env:
  global:
    var4=4
after_success:
  - echo "af $var4 $var3 $var2 $var1"
```

result:
```
etting environment variables from .travis.yml
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
```
merge_mode: deep_merge
env:
  global:
    var4=4
after_success:
  - echo "af $var4 $var3 $var2 $var1"
```
