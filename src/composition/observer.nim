##observer.nim
##Author: David J. Meagher (DavidMeagher1)
##This module just implements a very bare bones observer pattern that has been tweeked to pass around messages


#import asyncfutures

type
  #eventSubject
  Message* {.inheritable.} = ref object

  Handler* {.inheritable.}= ref object
    listeners*:seq[Listener]
  
  Listener* {.inheritable.} = ref object
    handler*:Handler
  


#Listener methods
method init*(listener:Listener) {.base.} = raise newException(Defect,"Method must be overwritten!")

method update*(listener:Listener,message:Message) {.base,locks:"unknown".} =
  raise newException(Defect,"Method must be overwritten!")

#Handler methods

method init*(handler:Handler) {.base.} =
  handler.listeners = newSeq[Listener]()

method notify*(handler:Handler,message:Message) {.base,gcsafe.} =
  for listener in handler.listeners:
    listener.update(message)

method remove*(handler:Handler,listener:Listener) {.base.} =
  assert handler.listeners.contains(listener)
  listener.handler = nil
  handler.listeners.del(handler.listeners.find(listener))

method add*(handler:Handler,listener:Listener) {.base.} =
  if listener.handler != nil:
    listener.handler.remove(listener)
  listener.handler = handler
  handler.listeners.add(listener)



