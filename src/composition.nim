##composition.nim
##Author: David J. Meagher (DavidMeagher1)

##This module impliments a Component pattern and these have eventListeners, mostly to make intercommunication between Composites

import composition/event,hashes
#export Event
type
  MethodOverrideDefect = object of Defect
  Component* = ref object of RootObj
    parent:Composite
  Composite* {.final.}= ref object of Component
    fchildren:seq[Component]
  Node* = ref object of Component
    eventListener*:EventListener

template RaiseMethodOverriteDefect():untyped =
  raise newException(MethodOverrideDefect,"Method must be overwritten!")

method init*(component:Component) {.base,locks:"unknown".} = RaiseMethodOverriteDefect()
method add*(component:Component;newNode:Component) {.base.} = RaiseMethodOverriteDefect()
method del*(component:Component;oldNode:Component) {.base.} = RaiseMethodOverriteDefect()
method children*(component:Component):seq[Component] {.base.} = RaiseMethodOverriteDefect()
method register*(component:Component,id:string,someProc:proc(event:Event)) {.base,locks:"unknown".} = RaiseMethodOverriteDefect()
method emit*(component:Component,id:string,event:Event) {.base, locks:"unknown".}= RaiseMethodOverriteDefect()

method add*(composite:Composite,newNode:Component) =
  composite.fchildren.add newNode
  newNode.parent = composite

method del*(composite:Composite,oldNode:Component)=
  oldNode.parent = nil
  composite.fchildren.del(composite.fchildren.find(oldNode))

method children*(composite:Composite):seq[Component] =
  return composite.fchildren

method register*(composite:Composite,id:string,someProc:proc(event:Event)) =
  for child in composite.fchildren:
    child.register(id,someProc)

method emit*(composite:Composite,id:string,event:Event) =
  for child in composite.fchildren:
    child.emit(id,event)

method init*(node:Node) =
  node.eventListener = newEventListener()

method add*(node:Node,newNode:Component) =
  var newComposite = new Composite
  if node.parent == nil:
    raise newException(Defect,"Node must have a parent to be able to add a child")
  else:
    let oldParent = node.parent
    oldParent.del(node)
    newComposite.add(node)
    newComposite.add(newNode)
    oldParent.add(newComposite)


method register*(node:Node,id:string,someProc:proc(event:Event)) =
  node.eventListener.addCallback(id.hash,someProc)

method emit*(node:Node,id:string,event:Event) =
  node.eventListener.handler.notify(EmitMessage(id:id.hash,event:event))


proc newTree*(nodes:varargs[Component]):Composite =
  result = new Composite
  for node in nodes:
    result.add(node)