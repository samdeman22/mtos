local std = {}

std.ports = {
  ["NET"] = 0,
  ["DNS"] = 1
}

std.sigs = {
  ["SEEK"] = 1,
  ["DFLT"] = 2
}

--write any other standard constants in the std table

--initialize any global FLAGs
_G["FLAG"] = {}


return std