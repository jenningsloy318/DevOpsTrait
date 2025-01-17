# Basis

- [How To Set Password Policies In Linux](https://www.ostechnix.com/how-to-set-password-policies-in-linux/)

- create encrypt password aka hash which can be used in  /etc/shadow
  - use perl

    ```sh
    export salt=$(openssl rand 1000 | strings | grep -io [0-9A-Za-z\.\/] |  head -n 16 | tr -d '\n' )
    export password=password
    echo $(perl -e 'print crypt("$ENV{'password'}","\$6\$"."$ENV{'salt'}"."\$")'
    ```

    or

    ```sh
    perl -e 'print crypt("password","\$6\$saltsalt\$") . "\n"'
    ```

    - use python

    ```sh
    python -c 'import crypt; print crypt.crypt("password", "$6$saltsalt$")'
    ```

    or ptyon 3.3+

    ```sh
    python -c 'import crypt; print(crypt.crypt('password', crypt.mksalt(crypt.METHOD_SHA512)))'
    ```

- repo repos https://developer.aliyun.com/mirror
  - kubernetes.repo

    ```conf
    [kubernetes]
    name=Kubernetes
    baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
    ```

  - https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
  - http://mirrors.aliyun.com/repo/epel-7.repo
  - http://mirrors.aliyun.com/repo/epel-8.repo

- minikube
  - install docker engine
  - start cluster with minikube

    ```sh
    minikube start  --vm-driver=none --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers
    ```

    reference:
    1. <https://unix.stackexchange.com/questions/158400/etc-shadow-how-to-generate-6-s-encrypted-password>
    2. <https://www.linuxquestions.org/questions/linux-security-4/command-to-create-encrypted-password-265368/>

- rpm spec to build packages
  - install `rpmdevtools`, ans use `spectool -g -R vim.spec` to download the tarball file
  - use `dnf builddep vim.spec` to install the dependencies
  - check which package depends on specific one, `dnf repoquery --whatrequires glib2`, will list all packages that dependon `glib2`
  - for condition of the `Source0`

        ```conf
        # Conditional for release and snapshot builds. Uncomment for release-builds.
        %global rel_build 1

        # for downloading the tarball use 'spectool -g -R mate-terminal.spec'

        # Source for release-builds.
        %{?rel_build:Source0:     http://pub.mate-desktop.org/releases/%{branch}/%{name}-%{version}.tar.xz}
        # Source for snapshot-builds.
        %{!?rel_build:Source0:    http://git.mate-desktop.org/%{name}/snapshot/%{name}-%{commit}.tar.xz#/%{git_tar}}

        ```

- enable docker to access external
  - add  interface docker0 to the zone

    ```sh
    firewall-cmd --permanent --zone=public --add-interface=docker0
    ```

  - enable masquerade

    ```sh
    firewall-cmd --zone=public --add-masquerade --permanent
    ```

- Create rescue image from current kernal

   make sure `dracut_rescue_image="yes"` in /usr/lib/dracut/dracut.conf.d/02-rescue.conf

   ```sh
    rm -f /boot/vmlinuz-0-rescue-* /boot/initramfs-0-rescue-*.img
    /usr/lib/kernel/install.d/51-dracut-rescue.install add $(uname -r) "" /lib/modules/$(uname -r)/vmlinuz
    ```

- crawl the whole website

```shell
wget --random-wait -r -p -e robots=off -U mozilla Website_URL ​​​

-nv 或 --no-verbose: less verbose；
--accept-regex: you can filter the url with regex expression
```

- arxiv paper reading

   as papers in arxiv.org is pdf, not friendly for reading, we can replace the `x` with `5` in the url to get html version, for example
   `https://arxiv.org/abs/2110.07602` to `https://ar5iv.org/abs/2110.07602`

   replace `v` with `w` will get `AI Chat pdf`
    `https://arxiw.org/abs/2110.07602`
