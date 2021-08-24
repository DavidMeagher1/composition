##event.nim
##Author: David J. Meagher (DavidMeagher1)
##Using an observer pattern this module implemnts simple event listeners and event handlers similar to javascript
##that can be attached to objects and allow them to communicate with each other

##Please make sure you have --multimethods:on when compiling with this module

import observer,tables,hashes

type
  ##The `Event` object should really just be inherited from, it allows you to pass "Events" around and have them actually contain some meaningful information 
  Event* = ref object of Message

  ##The `EventListener` object just handles executing callbacks when the handler notifies them
  EventCallback* = proc(event:Event)
  
  EventID* = Hash

  ##The `EmitMessage` object is only used when emitting and event, like is implied in the name
  ##this allows the listener to know which group of callbacks specifically to use in an easy way.
  EmitMessage* {.final.}= ref object of Message
    id*:EventID
    event*:Event

  EventListener* = ref object of Listener
    callbacks:Table[EventID,seq[EventCallback]]

  EventHandler* = ref object of Handler

##Creates a new EventHandler
proc newEventHandler*():EventHandler =
  result = new EventHandler
  procCall Handler(result).init

var GlobalEventHandler = newEventHandler()

##Creates a new EventListener
proc newEventListener*(handler:EventHandler = GlobalEventHandler):EventListener =
  result = new EventListener
  result.callbacks = initTable[EventID,seq[EventCallback]]()
  handler.add(result)

##This method gets called when the `EventHandler` notifies its listeners to update
method update*(eventListener:EventListener,message:Message ) =
  assert message of EmitMessage, "Message sent to `EventListener` update method must be of type `EmitMessage`"
  let emitMessage = EmitMessage(message)
  if eventListener.callbacks.hasKey(emitMessage.id):
    for callback in eventListener.callbacks[emitMessage.id]:
      callback(emitMessage.event)

##Adds a callback with a specific `EventID` to a `EventListener` 
proc addCallback*(eventListener:EventListener,eventID:EventID,callback:EventCallback) =
  if not eventListener.callbacks.contains(eventID):
    eventListener.callbacks[eventID] = newSeq[EventCallback]()
  eventListener.callbacks[eventID].add(callback)

proc getGlobalEventHandler*():EventHandler =
  return GlobalEventHandler

proc setGlobalEventHandler*(handler:EventHandler) =
  GlobalEventHandler = handler

export observer.add,observer.remove,observer.notify