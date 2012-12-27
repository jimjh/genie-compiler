# genie-worker
The worker is called upon to compile lessons from their source files into a
web-publishable format.

## Configuration
<dl>
  <dt>ROOT</dt>
  <dd>default output directory, should probably be on a networked file system like EBS</dd>
  <dt>GITIGNORE</dt>
  <dd>Global gitignore; should ignore `.genie-cache`</dd>
</dl>

## Workflow
All of these operations begin with obtaining a lock on the directory at `LESSON_PATH` and end with releasing the lock.

### Clone a Git Repository
Clones the git repository at the given URL to the output directory.

```sh
$> lamp clone [--user=USER] [--branch=BRANCH] [--] GIT_URL [LESSON_PATH]
```

`BRANCH` defaults to `master`. If `LESSON_PATH` is not present, then `USER`
must be given and the repository will be cloned to `{ROOT}/{USER}`. Upon
cloning, the worker performs a basic validation on the repository. The
validation rules are:

- does not contain a `.genie-cache` directory
- does not have a `@@genie@@` branch
- contains a valid `manifest.json`
- contains a valid `index.md`

If the validation fails, the program deletes the directory, and terminates with
an error code. Otherwise, the worker creates a new `@@genie@@` branch and
deletes the original branch. Next, it adds and commits a marker file to
indicate that the directory is a valid lesson directory.

Finally, the worker executes `git prune` and `git gc --aggressive` to clean
things up and reduce the size of the repository.

### Compile Lesson
Generates compressed HTML files from the lesson source at `LESSON_PATH`.

```sh
$> lamp compile LESSON_PATH [OUTPUT_DIR]
```

`OUTPUT_DIR` defaults to `{LESSON_PATH}/.genie-cache`. Files and directories at static paths (defined in `manifest.json`)
are copied to the output directory.

### Create Lesson
Creates a lesson from the git repository at the given URL.

```sh
$> lamp create --user=USER [--branch=BRANCH] GIT_URL
```

Does a `clone` followed by `compile`. In addition, the source files are removed, leaving only the `.genie-cache`
directory and the marker file. Finally, the worker commits all of its changes and exits.

### Update Lesson
Updates the git repository and recompiles the lesson.

```sh
$> lamp update [--branch=BRANCH] LESSON_PATH
```

`LESSON_PATH` should be the output directory of a previous `clone` or `update` action. This will fail if the given
directory does not contain the marker files. The worker deletes the `@@genie@@` branch, then checks out the given
branch. It then validates the repository, creates the marker files, and recompiles the lesson.

### Delete Lesson
Removes the given lesson. `LESSON_PATH` should be the output directory of a previous `clone` or `update` action. This
will fail if the given directory does not contain the marker files.

```sh
$> lamp rm LESSON_PATH
```
