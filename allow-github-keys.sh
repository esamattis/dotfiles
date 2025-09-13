#!/usr/bin/env bash
# Simplified installer for Debian/Ubuntu/Alma/Fedora with systemd.
# - Installs /etc/ssh/sshd_config.d/github.conf
# - Installs /usr/local/bin/ssh-github-keys
# - Creates least-privileged system user "githubkeys"
# Assumes sshd loads /etc/ssh/sshd_config.d/*.conf (no changes to sshd_config).
set -euo pipefail

require_root() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "Must run as root (try: sudo bash)" >&2
    exit 1
  fi
}

ensure_dirs() {
  install -d -m 0755 /etc/ssh/sshd_config.d
  install -d -m 0755 /usr/local/bin
}

resolve_nologin_shell() {
  for s in /usr/sbin/nologin /sbin/nologin /usr/bin/nologin; do
    [ -x "$s" ] && echo "$s" && return 0
  done
  echo /bin/false
}

ensure_githubkeys_user() {
  if ! id -u githubkeys >/dev/null 2>&1; then
    local nologin_shell
    nologin_shell="$(resolve_nologin_shell)"
    useradd --system --no-create-home \
      --home-dir /nonexistent \
      --shell "$nologin_shell" \
      --user-group \
      githubkeys
    passwd -l githubkeys >/dev/null 2>&1 || true
  fi
}

write_files() {
  cat > /etc/ssh/sshd_config.d/github.conf <<'EOF'
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
AuthorizedKeysCommand /usr/local/bin/ssh-github-keys %u
AuthorizedKeysCommandUser githubkeys
EOF
  chmod 0644 /etc/ssh/sshd_config.d/github.conf
  chown root:root /etc/ssh/sshd_config.d/github.conf

  cat > /usr/local/bin/ssh-github-keys <<'EOF'
#!/bin/sh
exec /usr/bin/curl -fsSL --connect-timeout 2 --max-time 5 "https://github.com/esamattis.keys"
EOF
  chmod 0755 /usr/local/bin/ssh-github-keys
  chown root:root /usr/local/bin/ssh-github-keys
}

validate_and_reload_sshd() {
  local sshd_bin
  sshd_bin="$(command -v sshd || echo /usr/sbin/sshd)"
  "$sshd_bin" -t
  systemctl reload sshd 2>/dev/null || systemctl reload ssh
}

check_curl_path() {
  if [ ! -x /usr/bin/curl ]; then
    echo "WARNING: /usr/bin/curl not found. Install curl (e.g., apt/yum/dnf install curl)." >&2
  }
}

main() {
  require_root
  ensure_dirs
  ensure_githubkeys_user
  write_files
  validate_and_reload_sshd
  check_curl_path
  echo "Installed. sshd reloaded. Using https://github.com/esamattis.keys via user 'githubkeys'."
  echo "Ensure your sshd includes /etc/ssh/sshd_config.d/*.conf (default on modern distros)."
}

main "$@"
