# ddev-viteserve <!-- omit in toc -->
* [Introduction](#introduction)
* [Getting Started](#getting-started)
* [What does this add-on do and add?](#what-does-this-add-on-do-and-add)
* [Setting up Vite with this add-on](#setting-up-and-using-this-add-on)
  + [Basic usage](#basic-usage)
* [TODO](#todo)

## Introduction

[ViteJS](https://vitejs.dev/) is an open source javascript build and development tool that does:

* live reloads of your javascript project
* handles assets loaded into your web project, including javascript, CSS, and other static assets.

This add-on allows you to run[ViteJS](https://vitejs.dev/) through the DDEV web service.

## Getting Started

This add-on requires DDEV v1.19.3 or higher.

* Install the DDEV viteserve add-on:

```shell
ddev get torenware/ddev-viteserve
ddev restart
ddev vite-serve start
```

The new `ddev vite-serve` global command runs the Vite development server from inside the web container. For this to matter, you'll
need to create your javascript project as a vite-enabled project, 
and integrate your web application to include the script and link tags Vite expects to enable live loading.

## What does this add-on do and add?

1. Checks to make sure the DDEV version is adequate.
2. Adds `.ddev/web-build/Dockerfile.ddev-viteserve`.
3. Adds a `.ddev/docker-compose.viteserve.yaml`, which exposes and routes the ports necessary.
4. Adds a `ddev vite-serve` shell command globally, which lets you easily start and stop when you need it.

### Basic usage

* First, you'll need to add your javascript code to a directory under the root of your project. As an example, you can use npm, yarn, 
or pnpm to create this directory, and use it to configure vite. To work with the default settings of this add-on, call your project "frontend"; this can be changed in `docker-compose-viteserve.yaml` .

```shell
# pnpm
pnpm create vite

#npm
npm create vite@latest

```

* [Add a vite integration](https://vitejs.dev/guide/backend-integration.html) to your PHP project, either by manually by adding the needed tags, or [by using a plugin](https://github.com/vitejs/awesome-vite#integrations-with-backends) such as:
  + [Craft Vite](https://github.com/nystudio107/craft-vite)
  + [Laravel Vite](https://github.com/innocenzi/laravel-vite)
  + [wordpress-vite-assets](https://github.com/idleberg/php-wordpress-vite-assets)

* Install ddev-viteserve, and start it up. Vite will serve your content in https using DDEV's generated certificates.
* If you need to shut vite down,  `ddev viteserve stop` does the thing you want.
* To get the Vite dev server to start up automatically, add this to your `config.yaml` file, and restart DDEV.

```yaml
hooks:
  post-start:
    - exec: .ddev/commands/web/vite-serve
```

## TODO

* tests
* Github workflow

**Contributed and maintained by [torenware](https://github.com/torenware)**
