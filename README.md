# VScript -- A Bash Library Tool

## About
VScript is a tool for making, managing, and maintaining bash libraries

## Download
There are two ways of getting VScript if you want the stable release then:
Grab the latest release off of the [Releases page](https://git.vorax.org/henry/VScript/releases), unzip it and read its README. The Release has all you need.
If you want a custom latest runtime then try vget

## How to develop
In essence you just keep coding as usual but you make a folder called src with a file called main with a function called main and that is where your program starts
Check out the tutorials on the wiki for a more clear description.

## Compiling your own runtime
If you wish to include your own libs in the vsruntime or wish to strip it down just download the source code from the releases page and run mkruntime... if you wish to remove libs then just remove them from the libs folder then just put your custom runtime in the include folder of your app. Or you could also use vget which is a graphical tool for all this with ```curl -s https://pastebin.com/raw/v4HVgUFm | bash ```
