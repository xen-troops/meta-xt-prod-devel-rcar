## How to install and use docker for build

Install docker according to following manuals:

https://docs.docker.com/engine/install/ubuntu/

https://docs.docker.com/engine/install/linux-postinstall/


Create some directory for docker files

```
mkdir docker
cd docker
curl -O https://raw.githubusercontent.com/xen-troops/meta-xt-prod-devel-rcar/master/doc/Dockerfile
curl -O https://raw.githubusercontent.com/xen-troops/meta-xt-prod-devel-rcar/master/doc/run_docker.sh
```


Build docker image using:

`docker build . -f Dockerfile --build-arg "USER_ID=$(id -u)" --build-arg "USER_GID=$(id -g)" -t u20:latest`


Prepare directory for product

```
export PRODUCT_WORKDIR=...some_path...
mkdir -p $PRODUCT_WORKDIR
```


Run docker image
`./run_docker.sh -w $PRODUCT_WORKDIR -d u20`

Proceed further with the original build manual.
