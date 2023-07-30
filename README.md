This repository contains build artifacts of HAproxy that are provided with no
support and no expectation of stability. The recommended way of using the
repository is to build and test your own packages. Latest Work-in-Progress
builds can be found under release label "WiP RPM Build".

# RPM Specs for HAproxy on EL9/EL8/EL7 with syslog logging to separate output files

## Contributing

When you like to see a specific feature added RPM build process, or support
other RPM based Operating Systems please create a Pull Request if you have the
knowledge to develop this yourself, I will verify the build process with these
changes and merge in upstream when finished. If you don't have the knowledge
feel free to create an Issue with the "enhancement" label added. There should be
no expectation of when/if this will be added but will allow for tracking what
features are of public interest.

Perform the following steps on a build box as a regular user.

## Checkout this repository

```bash
git clone https://github.com/rdeavila/rpm-haproxy.git 
cd ./rpm-haproxy
```

## Build using docker or podman

```bash
./compile.sh                   # the default
USE_PROMETHEUS=0 ./compile.sh  # with Prometheus Module support (default '1')
RELEASE=1 ./compile.sh         # with a custom release iteration, e.g. '2' (default '1')
USE_PODMAN=1 ./compile.sh      # build using podman instead docker (default '1')
EXTRA_CFLAGS=-O0 ./compile.sh  # custom CFLAGS, e.g. '-O0' to disable optimization for debug
COMPILE_FOR_EL9=1 ./compile.sh # build el9 package (default '1')
COMPILE_FOR_EL8=1 ./compile.sh # build el8 package (default '1')
COMPILE_FOR_EL7=1 ./compile.sh # build el7 package (default '1')
```

Resulting RPMs will be in `./RPMS/` When updating any of the files that are
included in the build phase, ensure that you also bump the release number, like
so:

```bash
RELEASE=3 ./compile.sh
```

## Credits

Based on the Red Hat 6.4 RPM spec for haproxy 1.4 combined with work done by
- [@DBezemer](https://github.com/DBezemer)
- [@nmilford](https://www.github.com/nmilford)
- [@resmo](https://www.github.com/resmo) 
- [@kevholmes](https://www.github.com/kevholmes)
- Update to 1.8 contributed by [@khdevel](https://github.com/khdevel)
- Amazon Linux support contributed by [@thedoc31](https://github.com/thedoc31)
  and [@jazzl0ver](https://github.com/jazzl0ver)
- Version detect snippet by [@hiddenstream](https://github.com/hiddenstream)
- Conditional Lua build support by [@Davasny](https://github.com/Davasny)
- Conditional Prometheus support by [@mfilz](https://github.com/mfilz)
- Debug Building and Dynamic Release version support by
  [@bugfood](https://github.com/bugfood)
- Macrofication of SUDO option by [@kenstir](https://github.com/kenstir)
- Amazon Linux 2023 support by [@izzyleung](https://github.com/izzyleung)

Additional logging inspired by
https://www.percona.com/blog/2014/10/03/haproxy-give-me-some-logs-on-centos-6-5/
