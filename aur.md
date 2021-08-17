installing packages form AUR, archlinux user repository
-------------------------------------------------------

clone aur package, eg xstow  
`git clone https://aur.archlinux.org/xstow.git`  

View the contets of all provided files. For expample, to use the panger 
[[less]] to view `PKGBUILD`  
`less PKGBUILD`

Make the package. After manually confirming the contents of the, run 
makepgk as a normal user:  
`makepkg -si`

If installed we can use [[yay]] as another AUR Helper. 
