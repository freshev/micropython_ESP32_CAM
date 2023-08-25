import uos
import ubinascii
try:
    uos.stat('main.py')
except:
    f=open('main.py', 'w')
    f.write(ubinascii.a2b_base64('aW1wb3J0IGNhbWVyYQpmcm9tIG1hY2hpbmUgaW1wb3J0IEkyQywgUGluCgpjYW1lcmEuaW5pdCgwLCBmb3JtYXQgPSBjYW1lcmEuSlBFRykKZmxhc2ggPSBQaW4oNCwgUGluLk9VVCwgMCkKCnVwbGluayA9IEkyQyhzY2wgPSAxMiwgc2RhID0gMTMsIG1vZGUgPSBJMkMuU0xBVkUpCnVwbGluay5jYWxsYmFjayhsYW1iZGEgcmVzOnByaW50KHJlcy5nZXRjYmRhdGEoKSkpCnByaW50KHVwbGluaykK'))
    f.close()
