#!/usr/bin/env python3
"""Configure Hermes Agent to use local LM Studio as the backend LLM."""

import os
import yaml

HERMES_CONFIG = os.path.expanduser("~/.hermes/config.yaml")

if not os.path.exists(HERMES_CONFIG):
    print("Hermes config not found — skipping.")
    exit(0)

with open(HERMES_CONFIG) as f:
    config = yaml.safe_load(f)

config["model"]["provider"]       = "lmstudio"
config["model"]["default"]        = "qwen3.5-9b-uncensored-hauhaucs-aggressive"
config["model"]["base_url"]       = "http://127.0.0.1:1234/v1"
config["model"]["context_length"] = 65536

with open(HERMES_CONFIG, "w") as f:
    yaml.dump(config, f, default_flow_style=False, allow_unicode=True, sort_keys=False)

print("Hermes config updated:")
print(f"  provider:       lmstudio")
print(f"  model:          qwen3.5-9b-uncensored-hauhaucs-aggressive")
print(f"  base_url:       http://127.0.0.1:1234/v1")
print(f"  context_length: 65536")
