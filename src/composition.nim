##composition.nim
##Author: David J. Meagher (DavidMeagher1)

##This module impliments a Component pattern and these have eventListeners, mostly to make intercommunication between Composites

import composition/event,hashes,tables
#export Event
type
  MethodOverrideDefect = object of Defect
  Component* = ref object of RootObj
  Composite* {.final.}= ref object of Component
    fchildren:seq[Component]
  Node* = ref object of Component
    eventListener*:EventListener

template RaiseMethodOverriteDefect():untyped =
  raise newException(MethodOverrideDefect,"Method must be overwritten!")

method init*(component:Component) {.base.} = RaiseMethodOverriteDefect()
method add*(component:Component;newNode:Component):Composite {.base.} = RaiseMethodOverriteDefect()
method del*(component:Component;oldNode:Component):Composite {.base.} = RaiseMethodOverriteDefect()
method children*(component:Component):seq[Component] {.base.} = RaiseMethodOverriteDefect()
method register*(component:Component,id:string,someProc:proc(event:Event)) {.base,locks:"unknown".} = RaiseMethodOverriteDefect()
method emit*(component:Component,id:string,event:Event) {.base, locks:"unknown".}= RaiseMethodOverriteDefect()

method add*(composite:Composite,newNode:Component):Composite {.discardable.}=
  composite.fchildren.add newNode
  return composite

method del*(composite:Composite,oldNode:Component):Composite {.discardable.}=
  composite.fchildren.del(composite.fchildren.find(oldNode))
  return composite

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

method add*(node:Node,newNode:Component):Composite =
  result = new Composite
  result.add(node)
  result.add(newNode)
  

method register*(node:Node,id:string,someProc:proc(event:Event)) =
  node.eventListener.addCallback(id.hash,someProc)

method emit*(node:Node,id:string,event:Event) =
  node.eventListener.handler.notify(EmitMessage(id:id.hash,event:event))
