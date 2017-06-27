# shorter
Shorter is a news reader for Ubuntu Touch (ubports.com)

Shorter was forked from Shorts reboot, which in turn was a fork of Shorts

# hacking

So you want to hack on Shorter? Awesome! Do the following:

Connect your Ubuntu Touch device with an USB cable and then on the console execute

```
git clone https://github.com/doniks/shorter
cd shorter 
clickable
```

This should retrieve the source code, build it, install it on the device and run the application. 

It seems that the application log file gets removed immediately when the application terminiates. So, to debug the application, I do the following:
Open a terminal session on the device and execute 
```
while ! tail -n 100 -f ~/.cache/upstart/application-click-*shorter*.log  ; do sleep 0.1 ; done
```

I'm happy to receive your contribution, just get in touch on github!

Doniks


