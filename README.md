# shorter
Shorter is an offline news reader for Ubuntu Touch

Shorter was forked from Shorts reboot, which in turn was forked from Shorts

# Development

So you want to hack on Shorter? Awesome! Do the following:


 * Install build tools
```
sudo apt install git build-essential
```
 * Install [clickable](https://docs.ubports.com/en/latest/appdev/clickable/setup.html)
 * Connect your Ubuntu Touch device with an USB cable
 * Retrieve the source code
```
git clone https://github.com/doniks/shorter
```
 * Build and test
```
cd shorter 
clickable --sdk 16.04
```

This should retrieve the source code, build it, install the package on the device and run the application. 

I'm happy to receive your contribution, just get in touch on github!
doniks


