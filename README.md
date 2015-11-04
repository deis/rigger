# rigger

[![Build Status](https://travis-ci.org/deis/rigger.svg?branch=master)](https://travis-ci.org/deis/rigger)

`rigger` is your interface to deploying Deis on a variety of cloud providers and is **currently only for development and Deis cluster trial purposes.**

### Quickstart

* Get `rigger`:

  ```
  git clone https://github.com/deis/rigger.git

  cd rigger
  ```

* Configure Deis deployment. The following command will ask you critical questions required to provision a Deis cluster on a certain cloud provider you choose:

  ```
  ./rigger configure
  ```

* Create infrastructure + deploy Deis

  ```
  ./rigger provision
  ```

### Demo

[![asciicast](https://asciinema.org/a/29033.png)](https://asciinema.org/a/29033)

### Design

- https://github.com/deis/deis/issues/4345

### Why the name?

A rigger (in construction) is a person who specializes in the lifting and moving of extremely
large or heavy objects. They understand the ins and outs of static and dynamic
loads and their expertise is of paramount importance to ensure that the
components of a project are delivered safely and expediently into the exact
positions. Consider the complexities involved for a rigger when [replacing a 38
ton thruster on the DCV Balder](https://www.youtube.com/watch?v=Bti0Z5a7GmE).
Therefore, naming this tool "rigger" makes sense: it's your highly experienced
aide in lifting your Deis platform into position.
