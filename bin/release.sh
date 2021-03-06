#!/bin/sh

usage (){
    echo "Usage:"
    echo "./release.sh -h -n <next_version>"
    echo "h:\thelp"
    echo "n:\tnext version of the project"
}


while getopts "c:n:h" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    n)
      nextVersion="$OPTARG-SNAPSHOT"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      exit 1
      ;;
  esac
done

if [ -z "$nextVersion" ]; then
    echo "option n is not specified."
    usage
    exit 1
fi

# setting git flow init with default branch names
git flow init -fd

if [ $? -ne 0 ]; then
        echo "ERROR with git flow init. Aborting"
        exit 1
fi

currentDevelopVersion=$(mvn help:evaluate -Dexpression=project.version | grep -v INFO | grep -v ERROR | grep -v DEBUG)
versionToBeReleased=$(cut -d'-' -f1 <<<"$currentDevelopVersion")
releaseBranch="release/${versionToBeReleased}"

git checkout -b $releaseBranch develop

# updating the pom files removing the -SNAPSHOT
sed -ri "0,/$currentDevelopVersion/s/$currentDevelopVersion/$versionToBeReleased/" pom.xml
sed -ri "0,/$currentDevelopVersion/s/$currentDevelopVersion/$versionToBeReleased/" modules/module_a/pom.xml
git add .
git commit -m "milestone: ${versionToBeReleased}"

git checkout master
git merge $releaseBranch -X theirs -m "merging $releaseBranch into master"
git push -u origin master

git checkout $releaseBranch
sed -ri "0,/$versionToBeReleased/s/$versionToBeReleased/$nextVersion/" pom.xml
sed -ri "0,/$versionToBeReleased/s/$versionToBeReleased/$nextVersion/" modules/module_a/pom.xml
git add .
git commit -m "added -SNAPSHOT version"

git checkout develop
git merge $releaseBranch -X theirs -m "merging $releaseBranch into develop"
git push -u origin develop

git branch -D $releaseBranch
