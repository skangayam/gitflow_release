#!/usr/bin/env bash

usage() {
  echo "usage: " `basename ${0}` "old-version new-version"
  exit 1
}

if [[ $# -ne 2 ]] ; then
  usage
else
    oldVersion=$1
    newVersion=$2
    git checkout -b release/${newVersion} develop
    sed -i '' "s/${oldVersion}-SNAPSHOT/${newVersion}/g" pom.xml
    sed -i '' "s/${oldVersion}-SNAPSHOT/${newVersion}/g" modules/module_a/pom.xml
    git add .
    git commit -m "updated version to ${newVersion}"


    git checkout master
    git merge release/${newVersion} -X theirs -m "merging release/${newVersion} into master"
    git push -u origin master

    git checkout release/${newVersion}
    sed -i '' "s/${newVersion}/${newVersion}-SNAPSHOT/g" pom.xml
    sed -i '' "s/${newVersion}/${newVersion}-SNAPSHOT/g" modules/module_a/pom.xml
    git add .
    git commit -m "added -SNAPSHOT to version"

    git checkout develop
    git merge release/${newVersion} -X theirs -m "merging release/${newVersion} into develop"
    git push -u origin develop

    git branch -D release/${newVersion}
fi
