hyperquest = require 'hyperquest'
concat = require 'concat'

class AMA
  constructor: (username, password, @apiURL = "https://api.caribetrack.com/v1") ->
    @username = username
    @password = password
    @token = null

    @assets =
      hash: []
      data: null
      changed: true

    @groups = 
      hash: []
      data: null
      changed: true


  getAssets: (callback, endpoint = "/assets/") ->
    reqURL = @apiURL + endpoint
    self = @

    reqOptions = 
      headers:
        token: self.token

    unless self.assets.changed
      callback self.assets.data
    else
      req = hyperquest.get reqURL, reqOptions

      req.pipe concat((body) ->
        response = body.toString()

        if response == "Invalid Token" or response == "Token Expired"
          @login.apply self, [ -> self.getAssets(callback) ]
        else
          data = JSON.parse response
          self.assets.data = data
          self.assets.changed = false

          callback self.assets.data
      )

  getAssetsPosition: (callback, endpoint = "/assetsPosition") ->
    reqURL = @apiURL + endpoint
    self = @

    reqOptions =
      headers:
        token: self.token
    
    req = hyperquest.get reqURL, reqOptions

    req.pipe concat((body) ->
      response = body.toString()

      if response == "Invalid Token" or response == "Token Expired"
        @login.apply self, [ -> self.getAssetsPosition(callback) ]
      else
        data = JSON.parse
        callback data
    )


  getGroups: (callback, endpoint = "/groups") ->
    reqURL = @apiURL + endpoint
    self = @

    reqOptions =
      headers:
        token: self.token

    unless self.groups.changed
      callback self.groups.data
    else
      req = hyperquest.get reqURL, reqOptions

      req.pipe concat((body) ->
        response = body.toString()
        
        if response == "Invalid Token" or response == "Token Expired"
          @login.apply self, [ -> self.getGroups(callback) ]
        else
          data = JSON.parse response

          self.groups.data = data
          self.groups.changed = false

          callback self.groups.data
      )

  testToken = (callback, endpoint = "/testToken") ->
    reqURL = @apiURL + endpoint
    self = @

    reqOptions =
      headers:
        token: self.token

    req = hyperquest.get reqURL, reqOptions

    req.pipe concat((body) ->
      response = body.toString()

      if response == "Invalid Token" or response == "Token Expired"
        @login.apply self, [ -> self.testToken(callback) ]
      else
        data = JSON.parse response
        callback data
    )

  login: (callback, endpoint = "/login") ->
    reqURL = @apiURL + endpoint

    reqOptions =
      headers:
        username: @username
        password: @password

    req = hyperquest.get reqURL, reqOptions

    req.pipe concat((body) ->
      data = JSON.parse body.toString()

      @token = data.token

      if @assets.hash == data.assetsHash
        @assets.changed = false
      else
        @assets.hash = data.assetsHash
        @assets.changed = true

      if @groups.hash == data.groupsHash
        @groups.change = false
      else
        @groups.hash = data.groupsHash
        @groups.changed = true

      callback()
    )

module.exports = AMA
