VagrantFile and install script for rapid setup of development enviroment.

This version is intended for older projects and code running on php5 and mysql5.
All newer projects should use latest versions of included technologies.

This was created for personal usage and released later.

### What is this repository for? ###

* Quick Setup of Development Enviroment

### Requirements ###
* Virtualbox `apt install virtualbox`
* Vagrant `apt install vagrant`
* Vagrant VBGuest Addon - `vagrant plugin install vagrant-vbguest`

### How do I get set up? ###

* Create Directory /home/{USER}/Projects/
* Create Directory /home/{USER}/vagrant/
* Clone Repository into /home/{USER}/vagrant/vagrant-legacy
* CD Into  /home/{USER}/vagrant/vagrant-legacy
* Run `vagrant up`
