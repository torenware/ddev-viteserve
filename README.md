[![tests](https://github.com/torenware/ddev-viteserve/actions/workflows/tests.yml/badge.svg)](https://github.com/torenware/ddev-viteserve/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2023.svg)

# The ddev-viteserve add-on for DDEV
* [Introduction](#introduction)
* [Getting Started](#getting-started)
* [What does this add-on do and add?](#what-does-this-add-on-do-and-add)
* [Setting up Vite with this add-on](#setting-up-and-using-this-add-on)
  + [Basic usage](#basic-usage)
* [Configuration](#configuration)

## What is ViteJS

<div style="text-align: center; ">

![Vite Logo](/images/vite-logo.png#center)

</div>

[ViteJS](https://vitejs.dev/) is an open source javascript build and development tool. From their site:

> Vite (French word for "quick", pronounced /vit/, like "veet") is a build tool that aims to provide a faster and leaner development experience for modern web projects. It consists of two major parts:
>
> * A dev server that provides rich feature enhancements over native ES modules, for example extremely fast Hot Module Replacement (HMR).
>
> * A build command that bundles your code with Rollup, pre-configured to output highly optimized static assets for production.
>
> Vite is opinionated and comes with sensible defaults out of the box, but is also highly extensible via its Plugin API and JavaScript API with full typing support.

This add-on allows you to run [ViteJS](https://vitejs.dev/) through the DDEV web container.

## Getting Started

This add-on requires DDEV v1.19.3 or higher.

* Install the DDEV viteserve add-on:

```shell
ddev get torenware/ddev-viteserve
ddev restart
ddev vite-serve start
```

The new `ddev vite-serve` command runs the Vite development server from inside the web container. For this to matter, you'll
need to create your javascript project as a vite-enabled project, 
and integrate your web application to include the script and link tags Vite expects to enable live loading.

## What does this add-on do and add?

1. Checks to make sure the DDEV version is adequate.
2. Adds `.ddev/web-build/Dockerfile.ddev-viteserve`. This installs some packages to make Vite run in background, and to install any additional javascript package managers we currently support.
3. Adds a `.ddev/docker-compose.viteserve.yaml`, which exposes and routes the ports necessary, and loads some defaults for us.
4. Creates a .env file in the .ddev directory with good default settings. If you already use the .env file features, your settings will be preserved by the installer, and the Vite related settings appended.
4. Adds a `ddev vite-serve` shell command, which lets you easily start and stop when you need it.

### Basic usage

* First, you'll need to add your javascript code to a directory under the root of your project. As an example, you can use npm, yarn, 
or pnpm to create this directory, and use it to configure vite. To work with the default settings of this add-on, call your project "frontend"; this can be changed in `docker-compose-viteserve.yaml` .

```shell
# pnpm
pnpm create vite

#npm
npm create vite@latest

```

* Look in your javascript directory, and edit your Vite configuration. By default, in some configurations for Vite, there will be no configuration file. In that case, Vite will server HTTP on port 5173 by default, which are also this add-on's defaults.  For the add-on to work correctly, it must serve HTTP; we depend upon DDEV to handle HTTPS. If you're using a Vite 2 project (which defaults to 3000 instead) or have a conflict with other software you want to use, this is configurable; see below.
* [Add a vite integration](https://vitejs.dev/guide/backend-integration.html) to your PHP project, either by manually by adding the needed tags, or [by using a plugin](https://github.com/vitejs/awesome-vite#integrations-with-backends) such as:
  + [Craft Vite](https://github.com/nystudio107/craft-vite)
  + [Official Laravel Vite support](https://laravel.com/docs/9.x/vite)
  + [wordpress-vite-assets](https://github.com/idleberg/php-wordpress-vite-assets)
* Install ddev-viteserve, and start it up. Vite will serve your content in https using DDEV's generated certificates.
* If you need to shut vite down,  `ddev viteserve stop` does the thing you want.
* To get the Vite dev server to start up automatically, add this to your `config.yaml` file, and restart DDEV.

```yaml
hooks:
  post-start:
    - exec: .ddev/commands/web/vite-serve
```

## Configuration

Most configuration for using this add-on is the .ddev/.env file.  This gets installed when you install the addon, and by default, contains the following environment variables:

```sh
# start vite
VITE_PROJECT_DIR=frontend
VITE_PRIMARY_PORT=5173
VITE_SECONDARY_PORT=5273
VITE_JS_PACKAGE_MGR=yarn
# end vite
```

Viteserve can check what type of ddev project you specified when configuration your project, and may in some cases change these defaults. For example, Laravel projects tend to put its javascript code into the project root; in this case, we set `VITE_PROJECT_DIR=.` [See the FAQ](./FAQ.md) for more details.

If you delete the .env file, the add-on will still work, and will use the same values you see here as defaults. Unless you make changes to your Vite configuration, these settings will be fine.

The Vite `vite.config.js` file will be in the the javascript app directory ( `frontend` by default). Unless you are doing something unusual, you won't need to change much here. In particular: you should *not* use the `server.https` key, since DDEV and this add-on expect ViteJS to serve HTTP. The `ddev-viteserve` add-on needs to be consistent with what you set in the "environment" section of `docker-compose.viteserve.yaml` .

**Contributed and maintained by [Rob Thorne (torenware)](https://github.com/torenware)**
