#Nice to know consle commands 

>> /dev/null 2>&1
-----------------

By using this command you are telling your program not to shout while 
executing.

Part1: `>>` output redirection  
This is used to redirect the program output and append the output at 
the end of the file. 

Part2: `/dev/null` special file  
accepts and discard all input; produces no output (alays return an 
end-of-file indication on a read

Part3: `2>&1` file descritpor
Whenever you execute a program, operating system always opens thre 
files `STDIN`, `STDOUT` and `STDERR` as we know whenever a file is 
openet, operating system (from kernel) returns a non-negative integer 
as *File Descriptor*. The file descriptor for these files are 0, 1, 2 
respectivly. 

So `2>&1` simply says redirect 2:`STDERR` to 1:`STDOUT`  
0 stads for `STDIN`  

[Stackoverflow](stackoverflow.com/questions/10508843/what-is-dev-null21)

define functions
----------------

```bash
is_executable() {
  type "$1" > /dev/null 2>&1
}
```

if then else
------------

```bash
if is_executable "git"; then
  echo git is available
else
  echo No git, available on system 
fi
```




