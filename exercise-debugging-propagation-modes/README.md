## Debugging a mount propagation issue

### Preparation steps

Prepare the `scratch` tmpfs with some files:
```
mkdir -p /mnt/scratch/{A,B}
```

Start a privileged Docker container with the `scratch` volume shared, using the 'rshared' propagation mode:
```
sudo docker run -ti --rm --privileged -v /mnt/scratch:/mnt/scratch:rshared ubuntu
```

In the container, add some new mounts in the `scratch` volume:
```
mount --bind /mnt/scratch/A /mnt/scratch/B
```

On the host, check that the bind mount has been propagated from the container to the host:
```
mount | grep /mnt/scratch
```

### Debugging

The mount propagation didn't happen as expected. What's happening? Investigate and fix the issue.
