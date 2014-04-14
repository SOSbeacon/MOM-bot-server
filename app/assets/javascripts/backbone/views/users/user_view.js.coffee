MsRobot.Views.Users ||= {}

class MsRobot.Views.Users.UserViewApp extends Backbone.View
  template: JST["backbone/templates/users/user"]

  initialize: (options) =>
    @model = options

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this

  close: =>
    this.remove()
    this.unbind()
