local std = {}

std.ports = {
  ["NET"] = 0,
  ["DNS"] = 1
}

std.sigs = {
  ["SEEK"] = 1,
  ["DFLT"] = 2
}

--frequent base26 conversion to base10
std.me = 316
std.ex = 127
std.mt = 331

std.net.server.timeout = 20
std.net.rap.server.timeout = 30
--write any other standard constants in the std table

--initialize any global FLAGs
_G["FLAG"] = {}


return std
