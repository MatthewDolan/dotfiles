#!/usr/bin/env bash
set -euo pipefail

pages_dir="${1:-pages}"

rm -rf "${pages_dir}"
mkdir -p "${pages_dir}"
cp install.sh "${pages_dir}/"

# create a simple index
cat <<'HTML' > "${pages_dir}/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Dotfiles Installer</title>
</head>
<body>
<h1>Dotfiles Installer</h1>
<p>Download the installer script below.</p>
<a href="install.sh">install.sh</a>
</body>
</html>
HTML

