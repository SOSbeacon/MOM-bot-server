class MsRobot.Models.Session extends Backbone.Model

  defaults:
    user_id: null
    authentication_token: null
    type_user: null

  initialize: =>
    @load()

  authenticated: ->
    Boolean(@get("authentication_token"))

  save: (auth_hash)->
    createCookie('user_id', auth_hash.user_id, 30)
    createCookie('authentication_token', auth_hash.authentication_token, 30)
    createCookie('type_user', auth_hash.type_user, 30)

  load: =>
    @set
      user_id: readCookie('user_id')
      authentication_token: readCookie('authentication_token')
      user_type: readCookie('type_user')

  remove: =>
    eraseCookie('user_id')
    eraseCookie('authentication_token')
    eraseCookie('type_user')