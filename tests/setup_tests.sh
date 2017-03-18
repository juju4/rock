#!/bin/sh -xe

# This script starts docker and systemd (if el7)

# Version of CentOS/RHEL
el_version=$1

 # Run tests in Container

if [ "$el_version" = "7" ]; then
  if [ -z ${TRAVIS_TAG} ]; then
    # This not is a tag build, skip it.
    echo "Running standard Ansible tests"

    docker run --privileged -d -ti -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup -v `pwd`:/rock:rw  centos:centos${OS_VERSION}   /usr/sbin/init
    DOCKER_CONTAINER_ID=$(docker ps | grep centos | awk '{print $1}')
    docker logs $DOCKER_CONTAINER_ID
    docker exec -ti $DOCKER_CONTAINER_ID /bin/bash -c "bash -xe /rock/tests/test_inside_docker.sh ${OS_VERSION};
      echo -ne \"------\nEND ROCK NSM TESTS\n------\nSystemD Units:\n------\n\";
      systemctl --no-pager --all --full status;
      echo -ne \"------\nJournalD Logs:\n------\n\" ;
      journalctl --catalog --all --full --no-pager;"
    docker ps -a
    docker stop $DOCKER_CONTAINER_ID
    docker rm -v $DOCKER_CONTAINER_ID
  else
    # This is a tagged build, so we're gonna do a deploy of an ISO
    echo "Building tagged release ${TRAVIS_TAG}"
    echo "Pulling down build scripts."
    wget https://github.com/rocknsm/rock-createiso/archive/master.zip
    unzip -d ../ master.zip

    docker run --privileged -d -ti -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup -v `pwd`:/rock:rw -v $(readlink -f ../rock-createiso-master):/rock-createiso:rw centos:centos${OS_VERSION}   /usr/sbin/init
    DOCKER_CONTAINER_ID=$(docker ps | grep centos | awk '{print $1}')
    docker logs $DOCKER_CONTAINER_ID
    docker exec -ti $DOCKER_CONTAINER_ID /bin/bash -c "bash -xe /rock/tests/createiso_inside_docker.sh ${OS_VERSION};
      echo -ne \"------\nEND ROCK NSM TESTS\n------\nSystemD Units:\n------\n\";
      systemctl --no-pager --all --full status;
      echo -ne \"------\nJournalD Logs:\n------\n\" ;
      journalctl --catalog --all --full --no-pager;"
    docker ps -a
    docker stop $DOCKER_CONTAINER_ID
    docker rm -v $DOCKER_CONTAINER_ID

  fi
fi
