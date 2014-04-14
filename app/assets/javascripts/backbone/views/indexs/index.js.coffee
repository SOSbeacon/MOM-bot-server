MsRobot.Views.Index ||= {}

class MsRobot.Views.Index.IndexViewApp extends Backbone.View
  template: JST["backbone/templates/indexs/index"]
  className: "main-container"
  id: "main-container"

  render: ->
    $(@el).html(@template())
    return this

  close: =>
    this.remove()
    this.unbind()
