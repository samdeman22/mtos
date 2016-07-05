--          MT TREE STRUCTURE API
local tree = {}
tree.__index = tree

--tree constructor, take an element to set for this node, optional list of children
function tree.create(element, ...)
  local t = {}
  setmetatable(t, tree)
  t.element = element
  t.children = {}
  --add all children in variadic argument, if any
  for _,v in pairs(arg) do
    t:add(v)
  end
  return t
end

--add a child tree to this node, child must have the same metatable as tree
function tree:add(child)
  if getmetatable(child) == tree then
    return table.insert(self.children, child)
  end
end

function tree:traverse(f)
  f(self)
  for _,v in pairs(self.children) do
    v:traverse(f)
  end
end

function tree:
