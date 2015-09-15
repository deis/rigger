Design Document: Provisioning Deis
==================================

Provisioning Deis is currently an adventure; usually a treacherous adventure.
We've fielded many provisioning related problems on our #deis irc channel, many
of which amounted to small missteps in the [manual process](http://docs.deis.io/en/latest/installing_deis/install-platform/).

We as the Deis maintainers have been frustrated with the provisioning process
during our normal development workflows and especially during release testing
time. See: #4318 (thanks @krancour for starting this public discussion!) and #2882.
We've been dreaming of a future where provisioning and deploying Deis to
any cloud provider is a trivial and an elegant experience.

Design Goals
------------

* Make the provisioning process less painful, more seamless, and faster for all
  users
* Provide a way to manage and update long-living Deis clusters
* Allow anyone to run our full suite of tests on any cluster
* Create a common user experience for provisioning Deis regardless of what
  provider is used
* Avoid implementing yet another desired state infrastructure tool (Terraform)
* Construct a buffer between users and the details of Deis' installation process
  and internal architecture
* Bridge the gap between basic and advanced deployments of Deis
* Enable users to service multiple Deis clusters simultaneously

Proposal: `rigger`
----------------

In order to achieve our dream of a more elegant Deis provisioning process for us
as maintainers and everyone as users, we'd like to build a new tool specific to
Deis called: `rigger`.

Why the name?

A rigger is a person who specializes in the lifting and moving of extremely
large or heavy objects. They understand the ins and outs of static and dynamic
loads and their expertise is of paramount importance to ensure that the
components of a project are delivered safely and expediently into the exact
positions. Consider the complexities involved for a rigger when [replacing a 38
ton thruster on the DCV Balder](https://www.youtube.com/watch?v=Bti0Z5a7GmE).
Therefore, naming this tool "rigger" makes sense: it's your highly experienced
aide in lifting your Deis platform into position.

`rigger` is your interface to deploying Deis on a variety of cloud providers.
`rigger` will:

* ask questions from the user up front instead of requiring full attention
  during the whole provisioning processes
* abstract the details of cloud providers and Deis provisioning quirks by
  default but allow you to coordinate details if you have specific demands
* show you how it created the infrastructure (an audit log and package of
  important components of the provisioning process will be provided to users)
* be held within a separate git repository from the core Deis project.
  * this will enable us to release updates to the provisioning process outside
    of the core Deis release cycle. Our plan is to keep a [strict interface
    ](#cloud-provider-interface) between `rigger` and the cloud providers
    already written in Deis' contrib directory. If we do have a need to break
    this interface, we can build in the smarts about which interface `rigger`
    should use per version of Deis.

So what will this look like for you?

For a **contributor**, hacking on Deis becomes:

    rigger configure # asked a set of questions

[![asciicast](https://asciinema.org/a/25605.png)](https://asciinema.org/a/25605)

    rigger checkout # checks out Deis repo <hack on Deis>
    rigger provision # provisions Deis cluster from checked out repository
    ...

[![asciicast](https://asciinema.org/a/25611.png)](https://asciinema.org/a/25611)

For a **tester**, testing Deis becomes:

    rigger configure # asked a set of questions (including what version you'd like to test)
    rigger provision
    rigger test # can choose what type of test to run or run manual tests at this point

[![asciicast](https://asciinema.org/a/25613.png)](https://asciinema.org/a/25613)

For an **operator**, provisioning Deis becomes:

    rigger configure
    rigger provision
    rigger test
    rigger save

    <time passes>

    rigger configure --file <package that was saved>
    rigger upgrade --to <version>

    <time passes>

    rigger configure --file <package that was saved>
    rigger provision # could be modifications to change infrastructure below Deis

`rigger`'s user interface
----------------

### `rigger configure`

##### Inputs

The command will ask the absolute minimum amount of questions needed to
provision a Deis cluster. Such as:

1. What version of Deis? [latest Deis release]
2. [What cloud provider would you like to use? [Digital Ocean]](http://deis.io/code-for-credit-digitalocean/)
3. What type of cluster are you looking to create? [development]
4. What are your cloud provider credentials? [suggestion]

##### Operation

If no file is passed in, `rigger` will:

  - ask necessary questions to fill in a complete `rigger` config file
  - consider the file to be the "current" environment (used for future `rigger`
    commands)

If a file is passed in, `rigger` will:

  - validate the file
  - ask any questions to fill in missing information in the file
  - consider the file to be the "current" environment (used for future `rigger`
    commands)

##### Outputs

a configuration file

This file is used as the source of truth for any future `rigger` operation. It
could also be sourced into a shell environment to allow more advanced users
to easily dive into the inner workings of a Deis cluster (config file could
hold DEIS_VERSION, PROVIDER, GOPATH, DEIS_ROOT, DEIS_TEST_DOMAIN)

    export DEISCTL_UNITS="/Users/username/.rerun-deis/490572dde4/units"
    export DEIS_ROOT="/Users/username/go/src/github.com/deis/deis"
    export DEIS_TEST_AUTH_KEY="/Users/username/.ssh/deis-test"
    export DEIS_TEST_DOMAIN="deis.xyz"
    export DEIS_TEST_ID="490572dde4"
    export DEIS_TEST_ROOT="/Users/username/.rerun-deis/490572dde4"
    export DEIS_TEST_SSH_KEY="/Users/username/.ssh/deis-test"
    export DEIS_VARS_FILE="/Users/username/.rerun-deis/490572dde4/vars"
    export DEV_REGISTRY="registry.hub.docker.com"
    export GOPATH="/Users/username/go"
    export IMAGE_PREFIX="username/"
    export ORIGINAL_PATH="/Users/username/.rbenv/bin:/Users/username/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    export PATH="/Users/username/go/bin:/Users/username/.rbenv/bin:/Users/username/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    export PROVIDER="aws"
    export DEIS_VERSION="1.9.1"

### `rigger checkout`

##### Inputs

##### Operation

Ability to clone, just update, or leave the target alone

##### Outputs

DEIS_ROOT contains the version of Deis that you'd like to use (determined in the
configure stage)

********************************************************************************

### `rigger provision`

##### Inputs 

##### Operation

Use config file contents to:

  - load provider logic from deis.git (see expected provider interface)
  - create a cluster of machines via cloud provider
  - install and start Deis

Could also use this on an existing cluster to increase/decrease/configure
infrastructure

##### Outputs

1. a working Deis cluster!
2. configuration file updates...

The cluster provisioning process will produce information necessary to interact
with the Deis cluster in future operations, such as DEISCTL_TUNNEL:

    export DEISCTL_TUNNEL="ec2-54-201-171-20.us-west-2.compute.amazonaws.com"
    export DEISCTL_UNITS="/Users/username/.rerun-deis/490572dde4/units"
    export DEIS_PROFILE="test-490572dde4"
    export DEIS_ROOT="/Users/username/go/src/github.com/deis/deis"
    export DEIS_TEST_AUTH_KEY="/Users/username/.ssh/deis-test"
    export DEIS_TEST_DOMAIN="test-490572dde4.deis.xyz"
    export DEIS_TEST_ID="490572dde4"
    export DEIS_TEST_ROOT="/Users/username/.rerun-deis/490572dde4"
    export DEIS_TEST_SSH_KEY="/Users/username/.ssh/deis-test"
    export DEIS_VARS_FILE="/Users/username/.rerun-deis/490572dde4/vars"
    export DEV_REGISTRY="registry.hub.docker.com"
    export ELB_DNS_NAME="deis-test-DeisWebE-1WG53EPRDVT11-1617219712.us-west-2.elb.amazonaws.com"
    export ELB_NAME="deis-test-DeisWebE-1WG53EPRDVT11"
    export GOPATH="/Users/username/go"
    export IMAGE_PREFIX="sgoings/"
    export ORIGINAL_PATH="/Users/username/.rbenv/shims:/Users/username/.rbenv/bin:/Users/username/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    export PATH="/Users/username/.rerun-deis/490572dde4/bin:/Users/username/go/bin:/Users/username/.rbenv/shims:/Users/username/.rbenv/bin:/Users/username/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    export PROVIDER="aws"
    export STACK_NAME="deis-test-490572dde4"
    export STACK_TAG="test-490572dde4"
    export DEIS_VERSION="1.9.1"```

********************************************************************************

### `rigger test`

##### Inputs

type of test to run

  - full
  - smoke
  - specific component
  - app deploy + test (deploy some apps that we can keep an eye on during the
    upgrade process)
  - app test (make sure previously deployed apps are responding correctly)
  - app test + destroy (make sure previously deployed apps are responding
    correctly, and then remove them)

##### Outputs

Summary of tests run and their results

********************************************************************************

### `rigger destroy`

##### Inputs

##### Outputs

completely destroyed cluster that was referred to in the configuration file

********************************************************************************

### `rigger setup-clients`

##### Inputs

##### Outputs

deisctl and deis clients (including appropriate units files) installed in a
directory available to the user which could be added to the user's PATH

********************************************************************************

### `rigger save`

##### Inputs

##### Outputs

package containing all relevant configuration, manipulation, and information of
what's been done to a certain environment... such as:

  - audit log
  - Terraform state files
  - complete userdata files
  - parameters passed into various scripts
  - `rigger` config file
  - deis test results

********************************************************************************

### `rigger upgrade`

##### Inputs

    --to <version>

    supply the version that you want to upgrade your Deis cluster to

    --upgrade-style [graceful, inplace]

    graceful: (no application downtime) use the new (as of 1.9.0) Deis upgrade
    logic

    inplace: (more downtime) use the documented way of tearing down the whole
    cluster and reinstalling Deis

##### Operation

Verification that the upgrade is worth it (an upgrade from 1.9.0 -> 1.9.0
doesn't make sense)

##### Outputs

Your old cluster, but with the version of Deis you specified!

<a name="cloud-provider-interface">`rigger`'s interface for cloud providers</a>
----------------

Below are our requirements for building a set of scripts that `rigger` expects
to exist. Each operation (installation of deps, creating a cluster) will just
call the appropriate shell script. How you implement the logic of creating a
cluster is left up to the developer (as long as the dependencies are installed
via the *Install Dependencies* script)!

##### Install Dependencies

    contrib/<provider_name>/install.sh

##### Create Cluster

    contrib/<provider_name>/create.sh

##### Check Cluster

    contrib/<provider_name>/check.sh

##### Destroy Cluster

    contrib/<provider_name>/destroy.sh

Future Ideas
============

- make a web service on top of `rigger` that people could use to provision a Deis
  cluster
