# Deis Conductor

## Purpose

Deis currently is a beast to build, provision, and test. Problems (beefs, if you will) include:

- long documentation describing how to get a Deis cluster up on a provider
  - Deis Conductor provides a Quick Start route for absolute newbies that asks questions and then does everything required to have a working cluster as well as leaves droppings that can be used again to service that cluster
- expected difficulties between v1 vs v2 behavior and processes of setting up
- if you want to test a cluster, you don't want to think about how to set one up, you just want to push an app to it
- releases are tricky to orchestrate

## Usage

To prepare to setup a Deis environment, run:

    ./rerun deis:configure

Which will walk you through a short set of questions to define what sort of Deis environment you'd like to set up.

Then your options open up. You can have Rerun Conductor:

- do the provisioning of machines + Deis for you:


        ./rerun deis:provision --provider [aws, azure, gce, vagrant]

- test an existing cluster:

        ./rerun deis:test --type [smoke, full]

- run an upgrade from a version to another version of Deis

        ./rerun deis:upgrade --from <version>
                             --to <version
                             --provider [aws, azure, gce, vagrant]
                             --upgrade-style [graceful, inplace]

- just download clients so you can muck with an existing cluster outside of Rerun Conductor

        ./rerun deis:setup-clients
        eval $(./rerun deis:shellinit)

        # now just use deis and deisctl as you normally would...
        deisctl journal builder
        deis login ...

