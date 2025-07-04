# Laravel git hooks
Git hooks to improve laravel development and deployment process


## Set up pre-commit hook for mix
In order to optimize asset for production automnatically, pre-commit hook can be useful.
This pre-commit hook will look for any file change in resource directory and run `yarn production`.

To set up this hook, enter command bellow in terminal

```sh
curl -fsSL https://raw.githubusercontent.com/HazzazBinFaiz/laravel-git-hooks/main/pre-commit > .git/hooks/pre-commit
```

## Set up post-receive hook for server side
In order to update package and optimize laravel app, post-receive hook can be useful.
This post-receive hook will look for any change in file named composer and install new packages
and it will optimize laravel app by running php artisan optimize.

To set up shared hook, enter command bellow in terminal

**Warning: Use with your own risk**

```sh
curl -fsSL https://raw.githubusercontent.com/HazzazBinFaiz/laravel-git-hooks/main/post-receive-shared > .git/hooks/post-receive
```

To set up this hook, enter command bellow in terminal

```sh
curl -fsSL https://raw.githubusercontent.com/HazzazBinFaiz/laravel-git-hooks/main/post-receive > .git/hooks/post-receive
```

# NEW : Set UP fresh VPS with deployment hook [here](vps.md)


## Initial setup (not hook)
This is not a hook setup, just a helpful script to setup laravel app

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/HazzazBinFaiz/laravel-git-hooks/main/initial_setup.sh)"
```

### Customize php for setup 

```sh
export PHP=/usr/local/bin/other-php && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/HazzazBinFaiz/laravel-git-hooks/main/initial_setup.sh)"
```

### Customize composer for setup 

```sh
export COMPOSER_BIN=/usr/local/bin/composer && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/HazzazBinFaiz/laravel-git-hooks/main/initial_setup.sh)"
```
