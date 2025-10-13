[code_of_conduct]: ./CODE_OF_CONDUCT.md
[fork]: https://docs.github.com/en/github/getting-started-with-github/fork-a-repo
[clone]: https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository
[push]: https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/merging-an-upstream-repository-into-your-fork
[pull]: https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/allowing-changes-to-a-pull-request-branch-created-from-a-fork

# Contributing

This document is a set of guidelines for contributing to this repository.

- [Contributing](#contributing)
  - [Getting started](#getting-started)
  - [How to become a contributor](#how-to-become-a-contributor)
  - [How to contribute](#how-to-contribute)
  - [Code of Conduct](#code-of-conduct)

## Getting started

Please note that this project is released with a Contributor [Code of Conduct][code_of_conduct]. By participating in this project you agree to abide by its terms.

All contributions, however small are valued!

If you have an idea to share in the form of Proof of concept, Starterkit or Guideline become a contributor and collaborate with us.

## How to become a contributor

Before starting you send us an email to this account so we can add you to our contributors list.

📧 <dustincatap@gmail.com>

## How to contribute

1. [**Fork the repository**][fork] to your personal Github. Forking is basically an easy way to make a duplicate of the repository to your own account.
2. [**Clone**][clone] the project to your own machine.

    ```sh
    # Clone your fork of the repo into the current directory
    git clone https://github.com/<your-username>/<repo-name>
    # Navigate to the newly cloned directory
    cd <repo-name>
    # Assign the original repo to a remote called "upstream"
    git remote add upstream https://github.com/<upsteam-owner>/<repo-name>
    ```

3. If you cloned a while ago, get the **latest changes** from upstream.

    ```sh
    git checkout <dev-branch>
    git pull upstream <dev-branch>
    ```

4. Create a new **topic branch** (off the main project development branch) to contain your feature, change, or fix.

    ```sh
    git checkout -b <topic-branch-name>
    ```

5. **Commit** changes to your own branch.

    ```sh
    git commit -m 'Add some feature'
    ```

6. **Locally merge** (or rebase) the upstream development branch into your topic branch.

    ```sh
    git pull [--rebase] upstream <dev-branch>
    ```

7. [**Push**][push] your topic branch up to your fork.

    ```sh
    git push origin <topic-branch-name>
    ```

8. Open a [**Pull Request**][pull] with a clear title and description so that we can review your changes.

Thanks for your interest in contributing to this repository.

## Code of Conduct

This project follows a [Code of Conduct][code_of_conduct] in order to ensure an open and welcoming environment.
