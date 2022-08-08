<?php

/**
 * Test bed.
 *
 */

function checkViteDevServerPort($port = 5173): bool
{
    $connection = @fsockopen('localhost', $port);
    if (is_resource($connection)) {
        fclose($connection);
        return true;
    }
    return false;
}

?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" href="/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Vite App</title>
  </head>
  <body>
    <h1>Test Vite Server</h1>

    <?php if (!empty($_ENV['VITE_PROJECT_DIR'])): ?>
      <h2>Vite Project Found: <?php echo $_ENV['VITE_PROJECT_DIR'] ?></h2>
      <?php if (checkViteDevServerPort($_ENV['VITE_PRIMARY_PORT'])): ?>
        <p>Vite appears to be listening...</p>
      <?php else: ?>
        <p>Vite does not appear to be listening. Is vite-serve enabled?</p>
      <?php endif?>
    <?php else: ?>
      <h2>No Vite project found. Is vite-serve installed?</h2>
    <?php endif?>

    <div id="app"></div>
    <script type="module" src="https://<?php echo $_SERVER['DDEV_HOSTNAME'] ?>:<?php echo $_ENV['VITE_PRIMARY_PORT'] ?>/src/main.js"></script>
  </body>
</html>
