# genie-compiler

The compiler is a service that shares a filesystem with the web server. It
compiles lessons from their source files into a web-publishable format.

## Configuration
Configuration options are available in `lib/lamp/config.rb`.

## Usage

To get a list of all commands and their options, use

```sh
$ lamp help
```

To start the service, on an OS-selected port, use

```sh
$ lamp server
```

To start the client, use

```sh
$ lamp client --port=PORT COMMAND
```

If command is not provided, a pry console will be launched. For example,

```
$ bin/lamp client --port=12345
[1] pry(#<Tangle::Client>)> info
=> <LampInfo uptime: ..., threads: ...>
```

## Workflow
All of these operations begin with obtaining a lock
(at `{ROOT}/locks/{LESSON_PATH}`) and end with releasing the lock.

### Clone a Git Repository
Clones the git repository at the given URL to the output directory.

```sh
$> lamp clone [--branch=BRANCH] [--] GIT_URL LESSON_PATH
```

`BRANCH` defaults to `master`, and the repository is cloned to
`{ROOT}/source/{LESSON_PATH}`. Upon cloning, the compiler performs a basic
validation on the repository. The validation rules are:

- contains a valid `manifest.json`
- contains a valid `index.md`

If the validation fails, the program deletes the directory, and terminates with
an error code.

### Compile Lesson
Generates compressed HTML files from the lesson source at `LESSON_PATH`.

```sh
$> lamp compile LESSON_PATH
```

The output directory is `{ROOT}/compiled/{LESSON_PATH}`.  Files and directories
at static paths (defined in `manifest.json`) are copied to the output
directory.

### Create Lesson
Creates a lesson from the git repository at the given URL.

```sh
$> lamp create [--branch=BRANCH] [--] GIT_URL LESSON_PATH
```

Does a `clone` followed by `compile`. In addition, the
`{ROOT}/source/{LESSON_PATH}` directory is deleted after it's done.

### Delete Lesson
Removes the `{ROOT}/source/{LESSON_PATH}` and `{ROOT}/compiled/{LESSON_PATH}`
directories.

```sh
$> lamp rm LESSON_PATH
```

## Output
For lesson `jimjh/floating-point`, the output directory contains the following:

```
root/                                drwxr-xr-x
  |- compiled/                       drwxr-xr-x
    |- jimjh/                        drwxr-xr-x
      |- floating-point/             drwxr-xr-x
        |- manifest.json              rw-r--r--
        |- index.inc                  rw-r--r--
        |- images/                   drwxr-xr-x
        |- ...
  |- lock/                           drwx------
    |- jimjh/                        drwx------
      |- floating-point/             drwx------
        |- lamp.lock                  rw-------
  |- source/                         drwx------
    |- jimjh/                        drwx------
      |- floating-point/             drwx------
        |- manifest.json
        |- index.md
        |- images/
        |- ...
  |- solution/                       drwxr-x---
    |- jimjh/                        drwxr-x---
      |- floating-point/             drwxr-x---
        |- 0.sol                      rw-r-----
        |- 1.sol                      rw-r-----
        |- ...
```

The `*.inc` files in `compiled/:user/:lesson` are considered to be sanitized
and safe for embedding on a HTML page. The `manifest.json` file is copied
directly from the user, and may contain malicious strings. The other files in
the static files are considered dangerous and may only be served as
attachments or images.
