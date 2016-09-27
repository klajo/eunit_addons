EUnit addons
============

[![Hex pm](https://img.shields.io/hexpm/v/eunit_addons.svg?style=flat)](https://hex.pm/packages/eunit_addons)

This application contains a set of addons which make it easier to work
with EUnit tests, especially tests which require some kind of
setup/cleanup before/after each test.

See the documentation for the `eunit_addons` module for more information.

To build the library:

    rebar3 compile

The documentation seen on github is generated using the [edown][1]
extension which generates documentation which is immediately readable
on github.

This generated documentation using regular edoc:

    rebar3 edoc

This generated documentation using edown:

    rebar3 as edown edoc

[1]: https://github.com/uwiger/edown
