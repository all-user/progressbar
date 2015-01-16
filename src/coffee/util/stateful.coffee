Rx = require 'rx'

stateful =
  _state: null

  stream: null

  set : (prop, value) ->
    if typeof prop is 'object'
      this._changeState(prop, no)
    else if typeof prop is 'string'
      obj = {}
      obj[prop] = value
      this._changeState(obj, no)
    else
      throw new Error 'type error at arguments'

  get: (prop) ->
    if prop?
      this._state[prop]
    else
      o = {}
      o[prop] = value for prop, value of this._state
      o

  setOnlyUndefinedProp: (statusObj) ->
    this._changeState(statusObj, yes)

  _changeState : (statusObj, onlyUndefined) ->
    state = this._state
    changed = no
    for type, status of statusObj
      changeOwnProp = state.hasOwnProperty(type) and state[type] isnt status
      onlyUndefinedProp = not state.hasOwnProperty(type) and onlyUndefined
      if changeOwnProp or onlyUndefinedProp
        changed = yes
        state[type] = status
        newStatus = {}
        newStatus[type] = status
    this.stream.onNext state if changed

makeStateful = (o, initState) ->
  o.stateful ?= {}
  o.stateful._state = initState ? {}
  for own i, v of stateful
    o.stateful[i] = v if typeof v is 'function'
  o.stateful.stream = new Rx.Subject()

module.exports = makeStateful
