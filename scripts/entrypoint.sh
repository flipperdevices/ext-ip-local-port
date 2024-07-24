#!/bin/bash

set -euo pipefail;  # bash unofficial strict mode

# template configs
python3 /usr/bin/app/template_configs.py

# run supervisor
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf;
