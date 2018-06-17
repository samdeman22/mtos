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
std["net"] = {
  ["rap"] = {
    ["me"] = 316,
    ["up"] = 535,
    ["mt"] = 331
  }
}

--write any other standard constants in the std table

--initialize any global FLAGs
_G["FLAG"] = {}


return std
