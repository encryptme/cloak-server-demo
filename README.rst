cloak-server-demo
=================

This projects demonstrates the steps necessary to set up a private Cloak team
endpoint. It takes the form of a pair of Ansible playbooks that can be thought
of as executable documentation. Running these against a clean install of Ubuntu
16.04 will produce a minimal but functional Cloak endpoint to examine. It is
expected that administrators will use this project as a guide to implementing
their own deployment automation for producing production-ready Cloak endpoints.


Setting up
----------

To start, you'll need to have a team registered at https://www.getcloak.com/,
with a private network and a target defined. The Cloak website has more
information about this and the rest of this documentation assumes that you're
already familiar with the general concepts. Every server is registered to a
particular target, so you'll need the target ID to proceed.

You'll also need a clean Ubuntu 16.04 machine ready to go. Any cheap consumer
VPS is fine for our purposes. The machine obviously needs to be reachable via
the FQDN that you used to register the target.

Finally, you'll need `ansible`_ available in your shell. This demo was
originally developed with ansible 2.2.1.0. As always, we recommend installing it
into a Python virtualenv.

Once you have all the pieces in place, the first step is to tell us where your
server is. Create a file named ``hosts`` in the ``ansible`` directory. This is
an ansible `inventory`_, which in our case can just be a single line that looks
something like this:

    cloak.example.com   ansible_ssh_user=ubuntu

Of course, you should substitute the FQDN or IP of your server and set any ssh
parameters needed to talk to it.


.. _ansible: https://www.ansible.com/
.. _inventory: http://docs.ansible.com/ansible/intro_inventory.html


Registration
------------

Deploying a demo server is a two-step process, starting with registration. This
will install the `cloak-server`_ command-line interface to our API and register
the server with your team. In order to do this, you will be prompted for your
Cloak email address and password and the identifier of the target this server
belongs to (which you get through your team dashboard). It may also prompt for a
base URL, but this is for testing against sandboxes; just accept the default for
production teams.

    ansible-playbook ansible/register.yaml

This playbook should only be run once.

One thing the registration step does is create a system user named ``cloak``.
For this demo, this is where we install the CLI and manage all of the
certificates and related info.

At the end of ``register.yaml``, the server should be registered and a
certificate request should be pending. All server certificates need to be
manually approved on the team dashboard.


.. _cloak-server: https://github.com/bbits/cloak-server


Configuration
-------------

The second step is to install the VPN services and configure the system.

    ansible-playbook ansible/deploy.yaml

This is idempotent and can be run multiple times.

The first thing ``deploy.yaml`` does is download the server certificate and
associated information. If you have not yet approved the certificate request, it
will block, so you should go do that now.

The rest of ``deploy.yaml`` is a relatively routine matter of installing
packages and rendering configuration files. It also installs some cron jobs to
periodically check for updated certificates and CRLs. They playbooks are well
documented, so you can refer to them directly for the details.


Caveats
-------

This demo produces a *mostly* functional Cloak team endpoint. One important
exception is that Cloak for iOS relies on the iOS system anchor certificates, so
it will only connect to a server that uses an entity certificate in the public
internet PKI. The easiest way to make that happen is probably to get a free
certificate from `letsencrypt`_ and add it (along with the related anchor, etc.)
to the appropriate folders in ``/etc/ipsec.d/``. This step is not currently
automated.


.. _letsencrypt: https://letsencrypt.org/
