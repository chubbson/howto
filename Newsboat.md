console based [[rss]] reader for arch. 

## Installation

`sudo pacman -S newsboat`

add feed to url file like
`echo 'https://karl-voit.at/feeds/lazyblorg-all.atom_1.0.links-and-content.xml' > ~/.newsboat/urls`
or 
`echo 'https://blog.fefe.de/rss.xml' >> ~/.newsboat/urls`

#### use 
run `newsboat` select loaded feed etc..

#### define config 

```
 echo 'browser "# set visible lines"' >> ~/.newsboat/config 
 echo 'browser "show-read-feeds no"' >> ~/.newsboat/config
 echo '#set default browser' > ~/.newsboat/config
 echo 'browser "xdg-open %u"' >> ~/.newsboat/config      
 echo '' >> ~/.newsboat/config           
 echo '# set visible lines' >> ~/.newsboat/config 
 echo 'show-read-feeds no' >> ~/.newsboat/config  
```