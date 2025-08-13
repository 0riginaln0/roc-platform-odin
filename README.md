
I'm trying to do hello world odin platform for the Roc

Atm I have 1-to-1 translation of the C host. Likely some type conversions have errors. Also idk how to build everything else and glue it together.


```terminal
cd odin-platform
odin build . -build-mode:shared
```

```terminal
$ roc roc_loves_odin.roc 
LinkingStrategy was set to Surgical (default), but I tried to find the surgical host at any of these paths Either the generic host files or the surgical host files must exist. File status: Generic host (odin-platform/host.rh): missing, Generic metadata (odin-platform/metadata_host.rm): missing, Surgical host (odin-platform/linux-x64.rh): missing, Surgical metadata (odin-platform/metadata_linux-x64.rm): missing but it does not exist.



roc --build-host --suppress-build-host-warning roc_loves_odin.roc
🔨 Building host ...
An internal compiler expectation was broken.
This is definitely a compiler bug.
Please file an issue here: <https://github.com/roc-lang/roc/issues/new/choose>
failed to open file "odin-platform/dynhost": No such file or directory (os error 2)
Location: crates/linker/src/lib.rs:463:29
```


# Platform switching

To run, `cd` into this directory and run this in your terminal:

```bash
roc --build-host --suppress-build-host-warning roc_loves_c.roc
```

## About these examples

They use a very simple [platform](https://www.roc-lang.org/platforms) which does nothing more than printing the string you give it.

If you want to start building your own platforms, these are some very simple example platforms to use as starting points.
