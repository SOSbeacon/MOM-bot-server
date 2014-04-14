MsRobot.Views.UserChildren ||= {}

class MsRobot.Views.UserChildren.UserChildView extends Backbone.View
  template: JST["backbone/templates/user_children/user_child"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
