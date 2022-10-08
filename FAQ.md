# Frequently Asked Questions About Viteserve (FAQ)

Some frequently asked questions about the ddev-viteserve add-on for DDEV

1. **What version of DDEV works with this add-on?** 1.19 and later will work.
2. **Do I have to use `pnpm` as my package manager?** No, we support `npm` and `yarn` as well. If `viteserve` cannot determine which 
2. **What version of Vite works with this add-on?** This add-on has been tested with both Vite 2.9 and Vite 3. The default port is set to 5173, which is the default port for Vite's development server in 3.x. You may want to set change the setting for `VITE_PRIMARY_PORT` to 3000 if you're using Vite 2, since the port the dev server changed from 3000 to 5173 when Vite 3 came out.
3. **Does this add-on work with Laravel's official Vite support?** It does, and the add-on has some special default behavior to support this.
  * It sets `VITE_PROJECT_DIR=.` in your .ddev/.env file, since the location of the master Vite setting file `vite.config.js` is in the top level of your project, and not in a sub-directory. 
  * The official Laravel plug-in requires some changes in order for hot-module-updating (HMR) to work correctly. If your `DDEV_HOSTNAME` setting is "my-laravel-app.ddev.site", your setting file would need to contain: 

```
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
        }),
    ],
    server: {
        hmr: {
            protocol: "wss",
            host: "my-laravel-app.ddev.site"
        }
    }

});

```
