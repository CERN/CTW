# How to compile on Raspbian Stretch

```
cmake . -DENABLE_GETTEXT=1 -DENABLE_FREETYPE=1 -DENABLE_LEVELDB=1 -DENABLE_SYSTEM_JSONCPP=TRUE
make -j 3
```

