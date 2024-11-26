#!/usr/bin/env bash

set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash

# Explicit make the mount point for bind-mount
# Otherwise using none ubuntu host will fail creating vm
mkdir -p $chroot/warden-cpi-dev

# Auditd cannot capture events within a container
sed -i 's/^local_events = yes$/local_events = no/g' $chroot/etc/audit/auditd.conf

# As containers have less to startup, some services are restarted very quickly and can hit the systemd
# restart limit of 5 restarts in 5 seconds
sed -i 's/^#DefaultStartLimitBurst=5$/DefaultStartLimitBurst=500/g' $chroot/etc/systemd/system.conf

cat > $chroot/var/vcap/bosh/bin/restart_networking <<EOF
#!/bin/bash

echo "skip network restart: network is already preconfigured"
EOF
chmod +x $chroot/var/vcap/bosh/bin/restart_networking

# Configure go agent specifically for warden
cat > $chroot/var/vcap/bosh/agent.json <<JSON
{
  "Platform": {
    "Linux": {
      "UseDefaultTmpDir": true,
      "UsePreformattedPersistentDisk": true,
      "BindMountPersistentDisk": true,
      "SkipDiskSetup": true,
      "ServiceManager": "systemd"
    }
  },
  "Infrastructure": {
    "Settings": {
      "Sources": [
        {
          "Type": "File",
          "SettingsPath": "/var/vcap/bosh/warden-cpi-agent-env.json"
        }
      ]
    }
  }
}
JSON
