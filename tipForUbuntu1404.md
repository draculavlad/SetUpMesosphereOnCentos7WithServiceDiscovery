
## tip ##

for (issue)[https://github.com/mesosphere/marathon/issues/2357]:
```
The following packages have unmet dependencies:
marathon : Depends: java8-runtime-headless but it is not installable
```
```shell
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
sudo apt-get install oracle-java8-installer oracle-java8-set-default -y
```
