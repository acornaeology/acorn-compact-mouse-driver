"""dasmos driver for PMFS 136, the Master Compact pointer and mouse driver."""
import os
from pathlib import Path

import dasmos
from dasmos import Align
from dasmos.expr import sym, lo, hi

_script_dirpath = Path(__file__).resolve().parent
_version_dirpath = _script_dirpath.parent
_rom_filepath = os.environ.get('FANTASM_ROM', str(_version_dirpath / 'rom' / 'pmfs-136.rom'))
_output_dirpath = Path(os.environ.get('FANTASM_OUTPUT_DIR', str(_version_dirpath / 'output')))

d = dasmos.Disassembler.create(cpu='65c02')
d.load(_rom_filepath, 0x8000)
d.use_environment('acorn_mos')
d.use_environment('acorn_master_hardware')
d.use_environment('acorn_sideways_rom', rom_title='PMFS 136')

ir = d.disassemble()
_output_dirpath.mkdir(parents=True, exist_ok=True)
(_output_dirpath / 'pmfs-136.asm').write_text(str(ir.render('beebasm')), encoding='utf-8')
(_output_dirpath / 'pmfs-136.json').write_text(str(ir.render('json')), encoding='utf-8')
