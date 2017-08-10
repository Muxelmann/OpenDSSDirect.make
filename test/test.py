import platform
import ctypes

OS = platform.uname().system
if 'Linux' in OS:
	DLL = ctypes.CDLL
	OS = 'linux'
	klusolve = None
	opendssdirect = 'libopendssdirect.so'
elif 'Darwin' in OS:
	DLL = ctypes.CDLL
	OS = 'darwin'
	klusolve = 'libklusolve.dylib'
	opendssdirect = 'libopendssdirect.dylib'
else:
	DLL = ctypes.WinDLL
	OS = 'windows'
	klusolve = 'KLUSolve.dll'
	opendssdirect = 'OpenDSSDirect.dll'

CPU = platform.uname().machine
if 'x86_64' in CPU:
	CPU = 'x86_64'
elif 'x86' in CPU:
	CPU = 'x86'
elif 'arm' in CPU:
	CPU = CPU
else:
	CPU = None

if CPU is None:
	raise TypeError('Unsupported CPU {}'.format(platform.uname().machine))

if klusolve is not None:
	DLL('../_lib/{}-{}/{}'.format(CPU, OS, klusolve))

dss = DLL('../_lib/{}-{}/{}'.format(CPU, OS, opendssdirect))

print('{} -> Start({})'.format(dss, dss.DSSI(ctypes.c_int32(3), ctypes.c_int32(0)) == 1))
