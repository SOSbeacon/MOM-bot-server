MsRobot.Views.UserChildren ||= {}

class MsRobot.Views.UserChildren.ShowView extends Backbone.View
  template: JST["backbone/templates/user_children/show"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
