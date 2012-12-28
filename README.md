# genie-worker
The worker is called upon to compile lessons from their source files into a
web-publishable format.

## Configuration
<dl>
  <dt>ROOT</dt>
  <dd>default output directory, should probably be on a networked file system like EBS</dd>
</dl>

## Workflow
All of these operations begin with obtaining a lock (at
`{ROOT}/locks/{LESSON_PATH}`) and end with releasing the lock.

### Clone a Git Repository
Clones the git repository at the given URL to the output directory.

```sh
$> lamp clone [--branch=BRANCH] [--] GIT_URL LESSON_PATH
```

`BRANCH` defaults to `master`, and the repository is cloned to
`{ROOT}/source/{LESSON_PATH}`. Upon cloning, the worker performs a basic
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
