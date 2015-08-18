# Deis Conductor

## Purpose

Deis currently is a beast to build, provision, and test. Problems (beefs, if you will) include:

- long documentation describing how to get a Deis cluster up on a provider
  - Deis Conductor provides a Quick Start route for absolute newbies that asks questions and then does everything required to have a working cluster as well as leaves droppings that can be used again to service that cluster
- expected difficulties between v1 vs v2 behavior and processes of setting up
- if you want to test a cluster, you don't want to think about how to set one up, you just want to push an app to it
- releases are tricky to orchestrate

## Usage

./rerun deis:provision --provider [aws, azure, gce]

./rerun deis:test [--type [apps, limits, auth]]

./rerun deis:release

