#!/bin/bash

set -e
set -o pipefail

TOOLBOX_DOCKER_IMAGE=quay.io/ukhomeofficedigital/toolbox
TOOLBOX_DOCKER_TAG=${1}
TOOLBOX_USER=root
TOOLBOX_DIRECTORY="/var/lib/toolbox"
TOOLBOX_BIND="--bind=/var/run/docker.sock:/host/var/run/docker.sock --bind=/dev:/host/dev --bind=/proc:/host/proc --bind=/boot:/host/boot --bind=/lib/modules:/host/lib/modules --bind=/usr:/host/usr --bind=/home:/host/home"

toolboxrc="${HOME}"/.toolboxrc

if [ -f "${toolboxrc}" ]; then
	source "${toolboxrc}"
fi

machinename=$(echo "${USER}-${TOOLBOX_DOCKER_IMAGE}-${TOOLBOX_DOCKER_TAG}" | sed -r 's/[^a-zA-Z0-9_.-]/_/g')
machinepath="${TOOLBOX_DIRECTORY}/${machinename}"
osrelease="${machinepath}/etc/os-release"
if [ ! -f ${osrelease} ] || systemctl is-failed -q ${machinename} ; then
	sudo mkdir -p "${machinepath}"
	sudo chown ${USER}: "${machinepath}"

	docker pull "${TOOLBOX_DOCKER_IMAGE}:${TOOLBOX_DOCKER_TAG}"
	docker create --name=${machinename} "${TOOLBOX_DOCKER_IMAGE}:${TOOLBOX_DOCKER_TAG}" /bin/true
	docker export ${machinename} | sudo tar -x -C "${machinepath}" -f -
	docker rm ${machinename}
	sudo touch ${osrelease}
fi

sudo systemd-nspawn \
	--directory="${machinepath}" \
	--capability=all \
	--share-system \
        ${TOOLBOX_BIND} \
	--user="${TOOLBOX_USER}" "$@"
