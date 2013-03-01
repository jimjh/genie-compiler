#!/usr/local/bin/thrift --gen rb --out gen

# Lamp Service
# This file defines the RPC interface. Use `./lamp.thrift` to compile it and
# generate the ruby files.
# Jim Lim <jiunnhal@cmu.edu>

namespace rb Lamp

# server information
struct Info {
  1: double           uptime,     # in seconds
  2: map<string, i32> threads     # { 'total' => xx, 'running' => xx }
}

exception RPCError {
}

service RPC {
  string ping()
  Info   info()
  void create(1: string git_url,
              2: string lesson_path,
              3: string callback,
              4: map<string, string> options) throws (1:RPCError e)
  void remove(1: string lesson_path,
              2: string callback)
}
