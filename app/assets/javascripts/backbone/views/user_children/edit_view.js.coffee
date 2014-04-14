MsRobot.Views.UserChildren ||= {}

class MsRobot.Views.UserChildren.EditView extends Backbone.View
  template : JST["backbone/templates/user_children/edit"]

  events :
    "submit #edit-user_child" : "update"

  update : (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success : (user_child) =>
        @model = user_child
        window.location.hash = "/#{@model.id}"
    )

  render : ->
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
