##composition.nim
##Author: David J. Meagher (DavidMeagher1)

##This module impliments a Component pattern and these have eventListeners, mostly to make intercommunication between Composites

import composition/event,hashes
export Event
type
  MethodOverrideDefect = object of Defect
  Component* = ref object of RootObj
  Composite* {.final.}= ref object of Component
    fchildren:seq[Component]
  Node* = ref object of Component
    eventListener:EventListener

var GlobalHandler = newEventHandler()

template RaiseMethodOverriteDefect():untyped =
  raise newException(MethodOverrideDefect,"Method must be overwritten!")

method init*(component:Component) {.base.} = RaiseMethodOverriteDefect()
method add*(component:Component;newNode:Component):Composite {.base.} = RaiseMethodOverriteDefect()
method del*(component:Component;oldNode:Component):Composite {.base.} = RaiseMethodOverriteDefect()
method children*(component:Component):seq[Component] {.base.} = RaiseMethodOverriteDefect()
method register*(component:Component,id:string,someProc:proc(event:Event)) {.base,locks:"unknown".} = RaiseMethodOverriteDefect()
proc emit*(component:Component,id:string,event:Event) =
  GlobalHandler.notify(EmitMessage(id:id.hash,event:event))

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

method add*(node:Node,newNode:Component):Composite =
  result = new Composite
  result.add(node)
  result.add(newNode)

method init*(node:Node):void=
  node.eventListener = newEventListener(GlobalHandler)
  GlobalHandler.add(node.eventListener)

method register*(node:Node,id:string,someProc:proc(event:Event)) =
  node.eventListener.addCallback(id.hash,someProc)
