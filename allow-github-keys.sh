#!/usr/bin/env bash
# This script configures SSH to allow public key authentication to any system
# user using esamattis' GitHub's public keys


set -euo pipefail

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Must run as root" >&2
    exit 1
  fi
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
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysCommand /usr/local/bin/ssh-github-keys %u
AuthorizedKeysCommandUser githubkeys
EOF
  chmod 0644 /etc/ssh/sshd_config.d/github.conf
  chown root:root /etc/ssh/sshd_config.d/github.conf

  cat > /usr/local/bin/ssh-github-keys <<'EOF'
#!/bin/sh
echo "$(date -Iseconds) githubkeys for $1" >> /tmp/githubkeys.log
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
    echo "ERROR: /usr/bin/curl not found. Install curl (e.g., apt/yum/dnf install curl)." >&2
    exit 1
  fi
}

main() {
  require_root
  check_curl_path
  ensure_githubkeys_user
  write_files
  validate_and_reload_sshd
  echo "Installed. sshd reloaded. Using https://github.com/esamattis.keys via user 'githubkeys'."
  echo "Ensure your sshd includes /etc/ssh/sshd_config.d/*.conf (default on modern distros)."
}

main "$@"
