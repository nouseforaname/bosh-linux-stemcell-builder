#!/usr/bin/env bash

set -e

base_dir="$(readlink -nf "$(dirname "$0")"/../..)"
# shellcheck source=../../lib/prelude_apply.bash
source "$base_dir/lib/prelude_apply.bash"
source "$base_dir/lib/prelude_bosh.bash"

install_logrotate_conf() {
  # The logrotate.conf supplied by the default image is about to be stomped.
  # Make sure it hasn't changed. If it has changed, the contents of the new file should
  # evaluated to see if the replacement file should be updated.
  echo "67281fca7e9b7e494498ec52a313bb23cf3d1f7e  $chroot/etc/logrotate.conf" | sha1sum -c
  cp "$assets_dir/ubuntu-logrotate.conf" "$chroot/etc/logrotate.conf"
}

install_setup_logrotate_script() {
  # shellcheck disable=SC2154
  cp "${assets_dir}/setup-logrotate.sh" "$chroot/$bosh_dir/bin/setup-logrotate.sh"
  chmod 700 "$chroot/$bosh_dir/bin/setup-logrotate.sh"
}

seed_default_logrotate_cronjob() {
  # shellcheck disable=SC2154
  run_in_chroot "$chroot" "firstMinute=0 $bosh_dir/bin/setup-logrotate.sh" # seed it with a default value
  chmod 0600 "$chroot/etc/cron.d/logrotate"
}

install_logrotate_cron_script() {
  mv "$chroot/etc/cron.daily/logrotate" "$chroot/usr/bin/logrotate-cron"
  sed -i -e 's/^\s*\(\/usr\/sbin\/logrotate\)\b/nice -n 19 ionice -c3 \1/' "$chroot/usr/bin/logrotate-cron"
}

install_default_su_directive() {
  cp -f "$assets_dir/default_su_directive" "$chroot/etc/logrotate.d/default_su_directive"
}

install_logrotate_conf
install_setup_logrotate_script
seed_default_logrotate_cronjob
install_logrotate_cron_script
install_default_su_directive
