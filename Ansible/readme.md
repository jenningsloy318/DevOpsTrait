# Ansible

- some useful variables

  - `ansible_virtualization_role`: value can be guest or host, to determine if it is a vm
  - `ansible_os_family`: AIX,Alpine,Altlinux,Archlinux,Darwin,Debian,FreeBSD,Gentoo,HP-UX,Mandrake,RedHat,SGML,Slackware,Solaris,Suse,

  - `ansible_distribution`: Alpine,Altlinux,Amazon,Archlinux,CentOS,ClearLinux,Coreos,Debian,Gentoo,Mandriva,NA,OpenWrt,OracleLinux,RedHat,Slackware,SMGL,SUSE,SLES,VMwareESX,Ubuntu
  - `ansible_distribution_major_version`,`ansible_distribution_version`:
  - https://docs.ansible.com/ansible/2.6/user_guide/playbooks_conditionals.html#ansible-distribution

- directory structure

for a better management, we can use following structure

**we can place a `ansible.cfg` in any directory contains playbooks to define some specific ansible setting individually.**

```sh
.
├── ansible.cfg
├── environments/         # Parent directory for our environment-specific directories
│   ├──roles/
│   ├── dev/              # Contains all files specific to the dev environment
│   │   ├── group_vars/   # dev specific group_vars files
│   │   │   ├── all
│   │   │   ├── db
│   │   │   └── web
│   │   |── host_vars/         # Contains only the hosts in the prod environment
|   |   |    ├── 192.168.6.10
│   │   └── hosts         # Contains only the hosts in the dev environment
│   │
│   ├── prod/             # Contains all files specific to the prod environment
│   │   ├── group_vars/   # prod specific group_vars files
│   │   │   ├── all
│   │   │   ├── db
│   │   │   └── web
│   │   |── host_vars/         # Contains only the hosts in the prod environment
|   |   |    ├── 192.168.6.10
│   │   |── hosts
│   └── stage/            # Contains all files specific to the stage environment
│       ├── group_vars/   # stage specific group_vars files
│       │   ├── all
│       │   ├── db
│       │   └── web
│       |── host_vars/         # Contains only the hosts in the prod environment
|       |    ├── 192.168.6.10
│       └── hosts         # Contains only the hosts in the stage environment
│
├── playbook.yml
. . .
```

Example playbook: App.yml

```yaml
---
- hosts: app
  remote_user: "{{ remote_user }}"
  vars_files:
    - "{{ env }}/group_vars/certs.yml"
    - "{{ env }}/group_vars/credentials.yml"
    - "{{ env }}/group_vars/keys.yml"
    - "{{ env }}/group_vars/deploy_keys.yml"
  roles:
    - common
    - security
    - credentials
    - apache
    - php
    - hosts
    - ssl-keys
    - node
    - newrelic
  tasks:
    - name: Bring Apache Online
      service:
        name: apache2
        state: started
        enabled: yes
      sudo: yes
```

- programmer tips

  - for templating files, if the content contains `{{ some conteent}}` which is not the ansible varaible, and we need to keep it as it is, we need add  `{%raw%} {{ some conteent}} {%endraw%}` to enclose them.
  - shell module tips
    The Ansible shell module is a straightforward tool. With some conditionals and functions, it’s usefulness can be improved and tasks can be quite smart,`creates`, `find`, and `until` clause are useful. creates causes shell to run only if a file does not exist, find causes shell to run only once if certain output exists, and using until and find causes a command to run repeatedly waiting for specific output.
  - check the target IP in a network

    ```
     - name: configure DNS client
       copy:
          src: inb-resolv.conf
          dest: /etc/resolv.conf
       when:  ansible_default_ipv4.address | ipaddr('10.36.52.0/24') | ipaddr('bool')
    ```

Note for ansible-role-openstack
---

### Prequisites

you should use pip to upgrade `openstacksdk` and `shade` to the latest version
and also install ansible 2.6+

### Usage

- modify `clouds.yaml`, which defines the openstack connection credentials, you can rename default name `monsoon03cn1` to anything you like and set it to `os_cloud` in playbook `openstack.yaml`

- modify  the variables in `openstack.yaml`

- excute the playbook via

    ```sh
    ansible-playbook openstack.yaml
    ```

### Customization

if you need to add more commands excuted after instance started, you can modify template file `userdata.j2`. and it is generated via command `write-mime-multipart` to combine multiple parts into one cloud-init config

This file contains three sections,

- first section is cloud-init file, and you need to refer to the official cloud-init website
- following two sections are shell scripts, you can add shell commands in these two sections
