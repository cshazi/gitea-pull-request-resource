# Gitea Pull Request Concourse Resource

A concourse resource to check for new pull requests on Gitea and update the pull request status.

## Source Configuration

```yaml
resource_types:
- name: pull-request
  type: docker-image
  source:
    repository: spatialbuzz/gitea-pull-request-resource

resources:
- name: repo-mr
  type: pull-request
  source:
    uri: https://my.gitea.host/myname/myproject.git
    private_token: XXX
    username: my_username
    password: xxx
```

* `uri`: The location of the repository (required)
* `private_token`: Your Gitea user's private token (required, can be found in your profile settings)
* `private_key`: The private SSH key for SSH auth when pulling

  Example:

  ```yaml
  private_key: |
    -----BEGIN RSA PRIVATE KEY-----
    MIIEowIBAAKCAQEAtCS10/f7W7lkQaSgD/mVeaSOvSF9ql4hf/zfMwfVGgHWjj+W
    <Lots more text>
    DWiJL+OFeg9kawcUL6hQ8JeXPhlImG6RTUffma9+iGQyyBMCGd1l
    -----END RSA PRIVATE KEY-----
  ```

* `username`: The username for HTTP(S) auth when pulling
* `password`: The password for HTTP(S) auth when pulling
* `no_ssl`: Set to `true` if the Gitea API should be used over HTTP instead of HTTPS
* `skip_ssl_verification`: Optional. Connect to Gitea insecurely - i.e. skip SSL validation. Defaults to false if not provided.

> Please note that you have to provide either `private_key` or `username` and `password`.

## Behavior

### `check`: Check for new pull requests

Checks if there are new pull requests or pull requests with new commits.

### `in`: Clone pull request source branch

`git clone`s the source branch of the respective pull request.

### `out`: Update a pull request's pull status

Updates the pull request's `status` which displays nicely in the Gitea UI and allows to only pull changes if they pass the test.

#### Parameters

* `repository`: The path of the repository of the pull request's source branch (required)
* `status`: The new status of the pull request (required, can be either `pending`, `pending`, `error`, `failed`, or `warning`)
* `build_label`: The label of the build in Gitea (optional, defaults to `"Concourse"`)
* `description`: The description to pass to Gitea (optional)

## Example

```yaml
jobs:
- name: test-pull-request
  plan:
  - get: repo
    resource: repo-mr
    trigger: true
  - put: repo-mr
    params:
      repository: repo
      status: running
  - task: run-tests
    file: repo/ci/tasks/run-tests.yml
  on_failure:
    put: repo-mr
    params:
      repository: repo
      status: failed
  on_success:
    put: repo-mr
    params:
      repository: repo
      status: success
```
