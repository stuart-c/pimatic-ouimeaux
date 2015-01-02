# Ouimeaux Plugin

# This is an plugin to integrate with Ouimeaux for the control of WiFi switches

module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  M = env.matcher

  io = require 'socket.io-client'

  class OuimeauxPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      url = config.url
      env.logger.debug "url = #{url}"

      @framework.on 'after init', (context) =>
        @socket = io.connect(url, {path: "/socket.io/1/"})

        @socket.on 'connect', ->
          @emit('join', null)

        @socket.on 'send:devicestate', (data) ->
          if data.type is "Switch"
            id = "ouimeaux-#{data.serialnumber}"
            plugin.handleDeviceInConfig(id, data)

      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("OuimeauxSwitch", {
        configDef: deviceConfigDef.OuimeauxSwitch,
        createCallback: (config) => return new OuimeauxSwitch(config)
      })

    handleDeviceInConfig: (id, deviceProbs) =>
      config = {
        id: id
        name: deviceProbs.name
        class: "OuimeauxSwitch"
        serialnumber: deviceProbs.serialnumber
        host: deviceProbs.host
        model: deviceProbs.model
        state: deviceProbs.state
      }

      actuator = @framework.deviceManager.getDeviceById id

      if actuator?
        unless actuator instanceof OuimeauxSwitch
          env.logger.error "expected #{id} to be an OuimeauxSwitch"
          return
      else
        actuator = @framework.deviceManager.addDeviceByConfig config

      actuator.updateFromOuimeaux deviceProbs

    sendState: (id, name, state) ->
      return new Promise( (resolve, reject) =>
        @socket.emit 'statechange', {
          name: name,
          state: state ? 0 : 1
        }
        resolve()
      )

  plugin = new OuimeauxPlugin()

  class OuimeauxSwitch extends env.devices.PowerSwitch

    constructor: (@config) ->
      assert @config.id?
      assert @config.name?
      assert @config.serialnumber?
      assert @config.host?
      assert @config.model?
      assert (if @config.lastState? then typeof @config.lastState is "boolean" else true)

      @id = config.id
      @name = config.name

      if config.lastState?
        @_state = config.lastState

      super()

    changeStateTo: (state) ->
      @_setState state
      plugin.sendState(@id, @name, state)

    updateFromOuimeaux: (probs) ->
      assert probs?

      if @name isnt probs.name
        @name = probs.name
        @config.name = probs.name
        plugin.framework.saveConfig()

      @_setState (if probs.state is 1 then on else off)

    _setState: (state) ->
      if state is @_state then return
      super state
      @config.lastState = state
      plugin.framework.saveConfig()

  return plugin
