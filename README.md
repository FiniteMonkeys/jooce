# Jooce

> An Elixir client library for kRPC, an RPC server for KSP (Kerbal Space Program).

## Table of Contents

* [Install](#install)
* [Usage](#usage)
* [Examples](#examples)
* [Maintainers](#maintainers)
* [Contribute](#contribute)
* [License](#license)

## Install

For now, clone the repository.

    git clone https://github.com/FiniteMonkeys/jooce.git

## Usage

This isn't a fully-functioning library yet, so you can't actually use it in standalone programs.

## Examples

The `examples` directory contains a number of scripts that exercise the RPC client library
and craft files for the rockets that are used in those scripts.

### Prerequisites

* [Kerbal Space Program](https://kerbalspaceprogram.com/). Tested with 1.2.1.
* [KRPC](https://github.com/krpc/krpc). Tested with 0.3.6.

To make life easier, KRPC should be configured to auto-start the server and to auto-accept
new clients.

### `simple.exs`

This script launches `Jooce-1` into a suborbital trajectory. It's written in a mostly-procedural
style to illustrate the basics of Jooce and the KRPC interface.

### `sub_orbital.exs`

This script also launches `Jooce-1` into a suborbital trajectory, but is written more
Elixir-like with multiple processes.

## Maintainers

### Current

* [CraigCottingham](https://github.com/CraigCottingham)

## Contribute

## License
