#!/usr/local/bin/thrift --gen rb --out gen

# Lamp Service
# This file defines the RPC interface. Use `./lamp.thrift` to compile it and
# generate the ruby files.
# Jim Lim <jiunnhal@cmu.edu>

# server information
struct LampInfo {
  1: double           uptime,     # in seconds
  2: map<string, i32> threads     # { 'total' => xx, 'running' => xx }
}

service Lamp {
  string    ping()
  LampInfo  info()
}
