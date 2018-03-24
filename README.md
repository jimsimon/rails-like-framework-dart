# Rails-Like-Framework

A framework loosely based on the simplicity and ease of use of Ruby on
Rails, but without the performance cost.

## Current Features
* A simple DSL for mapping routes to controllers

### Planned Features
* An ActiveRecord library for easy and simple model definitions
* A console for easy researching and debugging
* Built-in process clustering
* Built-in hot reloading while in development mode
* Built-in server management tools
* Built-in feature flagging system
* Built-in sharding support
* Built-in authorization support

## Getting Started

Add this package as a dependency in your `pubspec.yaml` and run `pub get`

### Usage

RLF comes with a command line to help you out.  We'll start by running the init command:

Create a new project directory, then run the init command:
```
pub run rlf:cli init
```

Running this command will create the following directories and files for
your application:

| Directory/File | Purpose |
| -------------- | ------- |
| <project-root>/rlf.config.json | General RLF configuration file |
| <project-root>/routes.dart | Route definition file |

Each generated file contain RLF's default values for that given file.

### General Configuration Options
| Setting Key | Default Value | Purpose |
| ----------- | ------------- | ------- |

## Routing (Not implemented yet)
Routes are defined in `<project-root>/routes.dart` using a DSL designed for declaring routes.  See the API docs for more details on how to defined routes.

## CLI (Not implemented yet)
For a list of the available cli commands, simply execute the following command:
```
pub run rlf:cli --help
```
