MsRobot.Views.UserChildren ||= {}

class MsRobot.Views.UserChildren.NewView extends Backbone.View
  template: JST["backbone/templates/user_children/new"]

  events:
    "submit #new-user_child": "save"

  constructor: (options) ->
    super(options)
    @model = new @collection.model()

    @model.bind("change:errors", () =>
      this.render()
    )

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")

    @collection.create(@model.toJSON(),
      success: (user_child) =>
        @model = user_child
        window.location.hash = "/#{@model.id}"

      error: (user_child, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
