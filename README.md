# travisci missing docs
This repo attempts to document travis-ci.com's quirks to supplement the existing documentation available online.

## travisci job build trigger documentation
### without merge_mode
https://travis-ci.com/juancarlostong/travisci-docs/builds/110776085
```yaml
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
```yaml
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
```yaml
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
```yaml
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
```yaml
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

## artifact uploader documentation
we're trying to flatten the directory structure where files are generated and upload them all into the the root folder of a bucket

### atttempt #1 .travis.yml
```yaml
addons:
  artifacts: true

script:
  - echo "s $var1 $var2 $var3 $var4" > generated_file_for_uploading.txt
```

result:
```
artifacts version v0.7.9-3-geef78ca revision=eef78ca2da49a8783a32d4293c24b7025b52b097
$ export ARTIFACTS_PATHS="$(git ls-files -o | tr \"\\n\" \":\")"
$ artifacts upload
INFO: uploading with settings
  bucket: [secure]
  cache_control: private
  permissions: private
INFO: uploading: /home/travis/build/juancarlostong/travisci-docs/generated_file_for_uploading.txt (size: 9B)
  download_url: https://s3.amazonaws.com/[secure]/juancarlostong/travisci-docs/17/17.1/generated_file_for_uploading.txt
Done uploading artifacts
```

### attempt #2
`download_url: https://s3.amazonaws.com/[secure]/juancarlostong/travisci-docs/17/17.1/generated_file_for_uploading.txt`
we want to get rid of "juancarlostong/travisci-docs/17/17.1/"

.travis.yml
```yaml
addons:
  artifacts: true
    target_paths:
      - /

script:
  - echo "s $var1 $var2 $var3 $var4" > generated_file_for_uploading.txt
```

result (good):
```
Uploading Artifacts
artifacts.setup
artifacts version v0.7.9-3-geef78ca revision=eef78ca2da49a8783a32d4293c24b7025b52b097
$ export ARTIFACTS_PATHS="$(git ls-files -o | tr \"\\n\" \":\")"
$ artifacts upload
INFO: uploading with settings
  bucket: [secure]
  cache_control: private
  permissions: private
INFO: uploading: /home/travis/build/juancarlostong/travisci-docs/generated_file_for_uploading.txt (size: 9B)
  download_url: https://s3.amazonaws.com/[secure]/generated_file_for_uploading.txt
Done uploading artifacts
Done. Your build exited with 0.
```

### attempt #3
can we still upload to the bucket's root even if our source file is in some folder structure?

.travis.yml
```
addons:
  artifacts:
    target_paths:
      - /
    paths:
      - /tmp/upload

script:
  - mkdir -p /tmp/upload
  - echo "s $var1 $var2 $var3 $var4" > /tmp/upload/generated_file_for_uploading.txt
  - echo "s $var1 $var2 $var3 $var4" > dont_want_to_upload_this.txt
```

result (bad):

no we cant. it'll append "/tmp/upload/" to the destination. at least it didn't upload the random `dont_want_to_upload_this.txt file`
```
Uploading Artifacts
artifacts.setup
artifacts version v0.7.9-3-geef78ca revision=eef78ca2da49a8783a32d4293c24b7025b52b097
$ export ARTIFACTS_PATHS="/tmp/upload"
$ artifacts upload
INFO: uploading with settings
  bucket: [secure]
  cache_control: private
  permissions: private
INFO: uploading: /tmp/upload/generated_file_for_uploading.txt (size: 9B)
  download_url: https://s3.amazonaws.com/[secure]/tmp/upload/generated_file_for_uploading.txt
Done uploading artifacts
```
