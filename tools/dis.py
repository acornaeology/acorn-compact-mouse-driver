import sys
from py65.devices.mpu65c02 import MPU
from py65.disassembler import Disassembler
d=open(sys.argv[1],'rb').read(); base=0x8000
m=MPU(); m.memory[base:base+len(d)]=list(d)
dis=Disassembler(m)
start=int(sys.argv[2],16) if len(sys.argv)>2 else base
end=int(sys.argv[3],16) if len(sys.argv)>3 else base+len(d)
pc=start
while pc<end:
    n,txt=dis.instruction_at(pc)
    print('%04X  %-9s %s'%(pc,' '.join('%02X'%m.memory[pc+i] for i in range(n)),txt)); pc+=n
