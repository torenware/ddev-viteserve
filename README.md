[![tests](https://github.com/drud/ddev-addon-template/actions/workflows/tests.yml/badge.svg)](https://github.com/drud/ddev-addon-template/actions/workflows/tests.yml)

![project is maintained](https://img.shields.io/maintenance/yes/2022.svg)

## The ddev-viteserve add-on for DDEV

* [Introduction](#introduction)
* [Getting Started](#getting-started)
* [What does this add-on do and add?](#what-does-this-add-on-do-and-add)
* [Setting up Vite with this add-on](#setting-up-and-using-this-add-on)
  + [Basic usage](#basic-usage)
* [TODO](#todo)

## What is ViteJS

<div style="text-align: center; ">

![Vite Logo](/images/vite-logo.png)

</div>

[ViteJS](https://vitejs.dev/) is an open source javascript build and development tool. From their site:

> Vite (French word for "quick", pronounced /vit/, like "veet") is a build tool that aims to provide a faster and leaner development experience for modern web projects. It consists of two major parts:
>
> * A dev server that provides rich feature enhancements over native ES modules, for example extremely fast Hot Module Replacement (HMR).
>
> * A build command that bundles your code with Rollup, pre-configured to output highly optimized static assets for production.
>
> Vite is opinionated and comes with sensible defaults out of the box, but is also highly extensible via its Plugin API and JavaScript API with full typing support.

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
