# Docker Toolbox


## Summary

This is a simple toolbox of tools for use within docker including sysdig.



## Usage

To build this container or run it in your local environment use the Makefile by running:

```
make build
```

or to run it do:

```
make shell
```


To run this container on a CoreOS node then you need to mount specific paths into the container and run it under priviledged mode to allow Sysdig to work correctly. This can be done with the following command:

```
docker run -it --rm -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v /boot:/host/boot:ro -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro --privileged --name NAME quay.io/ukhomeofficedigital/toolbox
```
