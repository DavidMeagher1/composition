##composite.nim
##Author: David J. Meagher (DavidMeagher1)

##This module impliments a Composite pattern and these have eventListeners, mostly to make intercommunication between Composites

import composition/event,hashes
export Event
type
  CompositeObj = object of RootObj
    fchildren:seq[Composite]
    eventListener:EventListener
  Composite* = ref object of CompositeObj

var CompositeEventHandler = newEventHandler()

proc `=destroy`(compositeObj:var CompositeObj) =
  if not compositeObj.fchildren.len == 0:
    compositeObj.fchildren.setLen(0)


method init*(composite:Composite):void {.base.} =
  composite.fchildren = newSeq[Composite]()
  composite.eventListener = newEventListener(CompositeEventHandler)
  CompositeEventHandler.add(composite.eventListener)

method add*(composite:Composite,newComposite:Composite):void {.base.} =
  composite.fchildren.add(newComposite)
method del*(composite:Composite;accessor:int):void {.base.} =
  composite.fchildren.del(accessor)
method get*(composite:Composite,accessor:int):Composite {.base.} =
  return composite.fchildren[accessor]
method getChildren*(composite:Composite):seq[Composite] {.base.} =
  return composite.fchildren
method getComposites*(composite:Composite):seq[Composite] {.base.} =
  for child in composite.fchildren:
    result.add child
    result = result & child.getComposites

iterator children*(composite:Composite):Composite =
  for child in composite.fchildren:
    yield child

iterator composites*(composite:Composite):Composite =
  for child in composite.fchildren:
    yield child
    for grandChild in child.fchildren:
      yield grandChild

#Event procs

proc register*(composite:Composite,id:string,callback:proc(event:Event)) =
 composite.eventListener.addCallback(id.hash(),callback)

proc emit*(composite:Composite,id:string,event:Event) =
  let emitMessage = new EmitMessage
  emitMessage.id = id.hash()
  emitMessage.event = event
  composite.eventListener.handler.notify(emitMessage)