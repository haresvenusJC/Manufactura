#!/usr/bin/env python3
"""Regenera version.json (lo lee cargador.js). Correrlo en cada commit que cambie algo en js/."""
import json, os, time
base = os.path.dirname(os.path.abspath(__file__))
modulos = sorted(f for f in os.listdir(os.path.join(base, 'js')) if f.endswith('.js'))
with open(os.path.join(base, 'version.json'), 'w') as fh:
    json.dump({'v': time.strftime('%Y%m%d%H%M%S', time.gmtime()), 'modulos': modulos}, fh, indent=1)
    fh.write('\n')
print('version.json:', len(modulos), 'modulos')
