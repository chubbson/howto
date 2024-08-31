Creating new repo, an link it to a github repository
----------------------------------------------------

`mkdir new-repo` create new folder.  
`cd new-repo`  
`git init`  
`nano somefiles` create some files and make changes  
`git add .` adding all file changes for commit  
`git commit -m 'init repo with somefiles'`  

Go on github create a new repository named `new-repo`

`git remote add origin git@github.com:chubbson/new-repo` link local 
repo to github repo. over ssh  
'git push -u origin master'

Rebase on forked Repo
-----------------------

```bash
$ cd PROJECT_NAME
$ git remote add upstream https://github.com/ORIGINAL_OWNER/ORIGINAL_REPOSITORY.git
$ git fetch upstream

# then: (like "git pull" which is fetch + merge)
$ git merge upstream/master master

# or, better, replay your local work on top of the fetched branch
# like a "git pull --rebase"
$ git rebase upstream/master
```

https://stackoverflow.com/questions/3903817/pull-new-updates-from-original-github-repository-into-forked-github-repository
 
