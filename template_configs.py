#!/usr/bin/env python3

import json
from pathlib import Path
from jinja2 import Environment, FileSystemLoader
from pydantic import BaseModel


class User(BaseModel):
    hostname: str
    ip: str


class ConfigFile(BaseModel):
    zerotier_network: str
    zerotier_public_key: str
    zerotier_private_key: str
    hostname_base: str
    users: list[User]


class App:
    def __init__(self):
        with open("/etc/app/config.json") as f:
            json_data = json.load(f)
            self.config = ConfigFile(**json_data)

    def template_zerotier(self):
        Path("/var/lib/zerotier-one").mkdir(parents=True, exist_ok=True)
        with open("/var/lib/zerotier-one/identity.secret", "w") as text_file:
            text_file.write(self.config.zerotier_private_key)
        with open("/var/lib/zerotier-one/identity.public", "w") as text_file:
            text_file.write(self.config.zerotier_public_key)
        Path("/var/lib/zerotier-one/networks.d").mkdir(parents=True, exist_ok=True)
        Path(
            f"/var/lib/zerotier-one/networks.d/{self.config.zerotier_network}.conf"
        ).touch()

    def template_nginx(self):
        environment = Environment(loader=FileSystemLoader("/usr/bin/app/templates"))
        template = environment.get_template("nginx.conf.j2")
        context = {
            "users": self.config.users,
            "hostname_base": self.config.hostname_base,
        }
        content = template.render(context)
        with open("/etc/nginx/nginx.conf", "w") as text_file:
            text_file.write(content)

    def run(self):
        self.template_zerotier()
        self.template_nginx()


if __name__ == "__main__":
    app = App()
    app.run()
