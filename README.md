#1. build
```
docker-compose build
```

使用代理加速(需要自行配置代理)
```
docker-compose build --build-arg http\_proxy=http://172.20.0.1:7777 --build-arg https\_proxy=http://172.20.0.1:7777
```

#2. start
```
docker-compose up
```

#3. install
```
./install.sh
```

#4. run
```
pwnbox
```