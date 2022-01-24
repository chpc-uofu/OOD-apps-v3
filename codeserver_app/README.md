# Batch Connect - Code Server

An improved file viewer / editor for OnDemand that launches a
Code Server within an cluster batch job or Frisco nodes. Code Server leverages VSCode as its
editor.

## Prerequisites

This Batch Connect app requires the following software be installed on the
**compute nodes** that the batch job is intended to run on (**NOT** the
OnDemand node):

- [Lmod] 6.0.1+ or any other `module purge` and `module load <modules>` based
  CLI used to load appropriate environments within the batch job before
  launching Code server.
- [Code Server] 2.x+ available from Github: https://github.com/cdr/code-server/releases

[Code Server]: https://coder.com/
[Lmod]: https://www.tacc.utexas.edu/research-development/tacc-projects/lmod
[VS Code]: https://code.visualstudio.com/

## Install

git clone and modify to your needs.

## Known Issues

- In-app installation of extensions does not work
- The authentication provided by code-server is unencrypted

