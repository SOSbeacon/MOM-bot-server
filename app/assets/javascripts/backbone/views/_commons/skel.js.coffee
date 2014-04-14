MsRobot.Views.Skel ||= {}

class MsRobot.Views.Skel.CollectionView extends Backbone.View
  id: "MsRobotapp"

  events:
    "click .destroy" : "destroy"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    $(@el).html(@template( ))
    @$("#showcontent").html(@listView.render().el)
    return this

  close: =>
    this.remove()
    this.unbind()


class MsRobot.Views.Skel.ListView extends Backbone.View
  className: "listview"
  itemView: null
  headerView: null

  initialize: (options) =>
    @session = new MsRobot.Models.Session()
    @collection = options.collection
    @collection.bind('add', @addOne, this)
    @collection.bind('reset', @reset, this)
    @collection.bind('all', @show, this)

  render: =>
    @$el.html(@template())
    @$(".loading").show()

    if @headerView
      @$("table.table").prepend(new @headerView().render().el)

    @collection.fetch({
      async: false,
      success: =>
        @$(".loading").hide()
    })
    console.log @collection
    return this

  addOne: (object) =>
    if @itemView
      view = new @itemView({model: object, collection:@collection})
      @$("#table-content").append(view.render().el)

  addAll: =>
    @collection.each(@addOne)

  reset: =>
    @$("#table-content tbody").html('')
#    if @headerView
#      @$("table.table").prepend(new @headerView().render().el)
    @addAll()


class MsRobot.Views.Skel.ListItemHeader extends Backbone.View
  tagName: "thead"

  render: () =>
    $(@el).html(@template())
    return this


class MsRobot.Views.Skel.ListItemView extends Backbone.View
  tagName: "tr"

  initialize: =>
    @session = new MsRobot.Models.Session()
    @model.bind('change', @render, this)
    @model.bind('destroy', @remove, this)
    @alert = new MsRobot.Views.Common.AlertView()

  events:
    "click #remove" : "delete"

  render: () =>
    $(@el).html(@template(@model.toJSON()))
    return this

  delete: =>
    proceed = confirm('Are you sure you want to delete?  This cannot be undone.')
    if proceed
      @model.destroy()
