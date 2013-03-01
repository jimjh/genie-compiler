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

# request status code
enum LampCode {
  SUCCESS,
  FAILURE
}

# request status
struct LampStatus {
  1: LampCode     code,
  2: list<string> trace
}

service Lamp {
  string     ping()
  LampInfo   info()
  LampStatus create(1: string git_url,
                    2: string lesson_path,
                    3: string callback,
                    4: map<string, string> options)
  LampStatus remove(1: string lesson_path,
                    2: string callback)
}
