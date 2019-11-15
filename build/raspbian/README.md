# How to compile on Raspbian Stretch

```
apt-get install build-essential cmake git libirrlicht-dev libbz2-dev libgettextpo-dev libfreetype6-dev libjpeg8-dev libxxf86vm-dev libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev libhiredis-dev libcurl3-dev
cmake . -DENABLE_GETTEXT=1 -DENABLE_FREETYPE=1 -DENABLE_LEVELDB=1 -DENABLE_SYSTEM_JSONCPP=TRUE
make -j 3
```

