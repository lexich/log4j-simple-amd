define [], ->
  "use strict"
  ctx = {}
  ((ctx) ->
    execute= (message, level, name) ->
      msg = "(" + name + ") - " + message
      if level is Log::LEVEL.INFO
        console.info "INFO: " + msg
      else if level is Log::LEVEL.WARN
        console.warn "WARN: " + msg
      else if level is Log::LEVEL.ERROR
        console.error "ERROR: " + msg
      else console.debug "DEBUG: " + msg  if level is Log::LEVEL.DEBUG        
    
    instance = undefined    

    class Log
      LEVEL:
        INFO: 1 << 0
        DEBUG: 1 << 1
        WARN: 1 << 2
        ERROR: 1 << 3

      _initConfig:false

      constructor:->
        if instance is undefined
          instance = this
          @options = {}
        return instance
      
      ###
      @param options
      name -
      level - {value} default LOG.LEVEL.ERROR
      ###
      initConfig: (options,@_execute=execute) ->
        @_initConfig = true

        for key of options
          @options[key] = @options[key] or {}
          current = @options[key]
          param = options[key]
          if param.level
            current.level = param.level
            current.logger.setLevel param.level  if current.logger

      getLogger: (name) ->
        getLevel = =>
          @options[name] = @options[name] or {}
          option = @options[name]
          def = @LEVEL.ERROR | @LEVEL.WARN
          level = (if option then option.level or def else def)

        mprocessor = new MessageProcesor(
          name, 
          getLevel, 
          (=> @_initConfig), 
          (=> @_execute)
        )
        mprocessor:: = {}
        mprocessor.constructor = ->        
        mprocessor

    class MessageProcesor
      _firstMsg:false

      constructor: (@name, @_level, @initialized=(->true), @_execute=(->execute)) ->      
        if @initialized()
          @setLevel @_level()        

      msg: (msg, level) ->        
        if @_firstMsg is false and @initialized()
          @setLevel @_level() 
        @_firstMsg = true
        isLevel = @level & level
        @execute msg, level, @name  unless isLevel is 0      

      setLevel: (level) -> 
        @level = level
        @execute = @_execute()

      info: (msg) -> @msg msg, Log::LEVEL.INFO

      debug:(msg) -> @msg msg, Log::LEVEL.DEBUG

      warn: (msg) -> @msg msg, Log::LEVEL.WARN

      error:(msg) -> @msg msg, Log::LEVEL.ERROR

    ctx.Log = new Log()
  ) ctx
  ctx.Log