include:
  - dr.repo

# turn off iptables
{% for svc in [ "iptables", "ip6tables"] %}
disable-{{svc}}:
  service:
    - dead
    - name: {{svc}}
    - enable: false
{% endfor %}

#
# Setup AWS credentials and tools
# 
/home/{{pillar.__stackdio__.username}}/.s3cfg:
  file:
    - managed
    - makedirs: true
    - source: salt://dr/home/s3cfg
    - template: jinja
    - user: {{pillar.__stackdio__.username}}
    - group: {{pillar.__stackdio__.username}}
    - mode: 755

/home/{{pillar.__stackdio__.username}}/.aws/config:
  file:
    - managed
    - makedirs: true
    - source: salt://dr/home/aws_config
    - template: jinja
    - user: {{pillar.__stackdio__.username}}
    - group: {{pillar.__stackdio__.username}}
    - mode: 755
    - makedirs: true

# listing packages alphabetically for some sanity
base_packages:
  pkg:
    - installed
    - pkgs: 
      - createrepo
      - fish
      - ntp
      - python-pip
      - s3cmd
      - screen
      - sysstat
      - tmux
      - unzip
      - zsh

aws-cli:
  pip.installed:
    - name: awscli==1.4.4
    - require:
      - pkg: base_packages

#
# Some default files
#
/home/{{pillar.__stackdio__.username}}/.vimrc:
  file:
    - managed
    - makedirs: true
    - source: salt://dr/home/vimrc
    - user: {{pillar.__stackdio__.username}}
    - group: {{pillar.__stackdio__.username}}
    - mode: 755

/home/{{pillar.__stackdio__.username}}/.bashrc:
  file:
    - append
    - template: jinja
    - mode: 755
    - sources: 
      - salt://dr/home/bashrc

/home/{{pillar.__stackdio__.username}}/.ssh/authorized_keys:
  file:
    - append 
    - template: jinja
    - mode: 755
    - makedirs: true
    - sources: 
      - salt://dr/home/authorized_keys

# 
# Set a variety of system configuration and permissions
#
/mnt:
  file:
    - directory 
    - mode: 777

/mnt1:
  file:
    - directory 
    - mode: 777
    
/mnt2:
  file:
    - directory 
    - mode: 777
    
/mnt3:
  file:
    - directory 
    - mode: 777

/mnt4:
  file:
    - directory 
    - mode: 777

fix_tty:
  cmd:
    - run
    - name: "sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers"
    - user: root

/etc/sysctl.conf:
  file:
    - append
    - template: jinja
    - sources:
      - salt://dr/etc/sysctl.conf

set_swappiness:
  cmd:
    - run
    - name: sysctl -n vm.swappiness=0
    - user: root

/etc/pam.d/su:
  file:
    - append
    - template: jinja
    - sources:
      - salt://dr/etc/pam.d/su

/etc/security/limits.conf:
  file:
    - append
    - template: jinja
    - sources:
      - salt://dr/etc/security/limits.conf

# actually turn on ntp
ntpd-svc:
  service:
    - running
    - name: ntpd
    - require:
      - pkg: base_packages

