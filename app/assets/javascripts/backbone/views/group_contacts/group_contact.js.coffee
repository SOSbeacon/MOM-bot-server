MsRobot.Views.GroupContacts ||= {}

class MsRobot.Views.GroupContacts.ListItem extends MsRobot.Views.Skel.ListItemView
  template: JST["backbone/templates/group_contacts/listitem"]

  events:
    "click #edit" : "editGroup",
    "click #delete": "deleteGroup"
    "click #list_contact": "listContact"

  editGroup: =>
    view = new MsRobot.Views.GroupContacts.GroupContactForm({model: @model, collection: @collection})
    $('body').append(view.render().el)
    $("#modal-form-group").modal("show")

  deleteGroup: =>
    proceed = confirm('Are you sure you want to delete?  This cannot be undone.')
    if proceed
      @model.url = =>
        "/group_contacts/#{@model.get('id')}.json?auth_token=#{@session.get('authentication_token')}"

      @model.destroy({
        success: =>
          @alert.hideAlert()
          @alert.showAlert("", "Delete group successfully", "alert-success")
      })

  listContact: () =>
    Backbone.history.navigate("/group_contacts/#{@model.get('id')}", true)


class MsRobot.Views.GroupContacts.ListHeader extends MsRobot.Views.Skel.ListItemHeader
  template: JST["backbone/templates/group_contacts/header"]


class MsRobot.Views.GroupContacts.ListView extends MsRobot.Views.Skel.ListView
  template: JST["backbone/templates/group_contacts/listview"]
  itemView: MsRobot.Views.GroupContacts.ListItem
  headerView: MsRobot.Views.GroupContacts.ListHeader


class MsRobot.Views.GroupContacts.GroupContactForm extends Backbone.View
  template: JST["backbone/templates/group_contacts/form"]
  className: "modal"
  id: "modal-form-group"

  initialize: (options) =>
    @session = new MsRobot.Models.Session()
    @collection = options.collection
    @alert = new MsRobot.Views.Common.AlertView()
    $("#modal-form-group").remove()

  events:
    "click #submit" : "createGroupContact"

  render: =>
    $(@el).html(@template(@model.toJSON()))
    return this

  renderContact: =>
    that = this
    if @model.get('contacts')
      contacts = @model.get('contacts')
      _.each contacts, (contact) ->
        that.$("#select_contact").append("
          <option value='#{contact.id}'>#{contact.name}</option>
        ")

    contact = new MsRobot.Collections.ContactsCollection()
    contact.url = =>
      "/contacts.json?auth_token=#{@session.get('authentication_token')}&except=1"

    contact.fetch({
      cache: false,
      async: false,
      success: (response) =>
        response.each((model, index) =>
          @$("#select_contact").append("
            <option value='#{model.id}'>#{model.get('name')}</option>
          ")
        )
    })

    @$(".chosen-select").chosen()
    @$("#chosen-multiple-style").on "click", (e) ->
      target = $(e.target).find("input[type=radio]")
      which = parseInt(target.val())
      if which is 2
        @$("#select_contact").addClass "tag-input-style"
      else
        @$("#select_contact").removeClass "tag-input-style"

    arrValues = @model.get("contacts")

    @$("option").each ->
      if containsObject($(this).attr("value"), arrValues)
        $(this).attr "selected", "selected"

    @$(".chosen-select").trigger("chosen:updated")

  createGroupContact: =>
    if @$("#name").val().trim() == ""
      @alert.hideAlert()
      @alert.showAlert("", "Name can't be blank", "alert-danger", "group-alert")
      return

    data = {
      name: @$("#name").val().trim()
      contacts_id: @$("#select_contact").val() || new Array()
      user_id: $.cookie('user_id')
    }

    if @model.get("id")
      @model.url = =>
        "/group_contacts/#{@model.get('id')}.json?auth_token=#{@session.get('authentication_token')}"
    else
      @model.url = =>
        "/group_contacts.json?auth_token=#{@session.get('authentication_token')}"

    that = this
    @model.save(data,
      success: (response) =>
        that.collection.add(response)
        $("#modal-form-group").modal("hide")
        that.alert.hideAlert()
        that.alert.showAlert("", "Save group successfully", "alert-success")

      error: (jqXHR, textStatus, errorThrown) =>
        if textStatus.status == 422
          @alert.showAlert("", JSON.parse(textStatus.responseText), "alert-danger", "group-alert")
        else if textStatus.status == 400
          @alert.showAlert("", JSON.parse(textStatus.responseText), "alert-danger", "group-alert")
    )


class MsRobot.Views.GroupContacts.GroupContactViewApp extends MsRobot.Views.Skel.CollectionView
  template: JST["backbone/templates/group_contacts/group_contact"]

  initialize: =>
    @session = new MsRobot.Models.Session()
    @alert = new MsRobot.Views.Common.AlertView()
    @collection = new MsRobot.Collections.GroupContactsCollection()

  events:
    "click #create-parent" : "showGroupContact"
    "change #choose-parent select" : "renderGroup"

  render: =>
    $(@el).html(@template( ))
    @renderParent()

    return this

  renderParent: =>
    listParent = new MsRobot.Collections.UsersCollection()
    listParent.url = =>
      "/users/list_parent.json?auth_token=#{@session.get('authentication_token')}"

    listParent.fetch({
      cache: false,
      async: false,
    })

    if listParent.length > 0
      listParent.each((model, index) =>
        @$("#choose-parent select").append(
          $("<option></option>").attr("value", model.get('id')).html(model.get('first_name') + ' ' + model.get('last_name'))
        )
      )

      if $.cookie('user_id')
        @$("#choose-parent option").each ->
          if parseInt($(this).attr("value")) == parseInt($.cookie('user_id'))
            $(this).attr 'selected', 'selected'

      @$(".chosen-select").chosen()
      @renderGroup()
    else
      $(@el).html("<h1 class='blue parrent-not-found'>You need to create parent first.</h1>")

  renderGroup: =>
    user_id = @$("#choose-parent select").val()
    $.cookie('user_id', user_id)

    @collection.url = =>
      "/group_contacts.json?user_id=#{user_id}&auth_token=#{@session.get('authentication_token')}"

    @listView = new MsRobot.Views.GroupContacts.ListView({collection:@collection})
    @$("#showcontent").html(@listView.render().el)

  showGroupContact: =>
    model = new MsRobot.Models.GroupContact()
    model.set("user", {id: $.cookie('user_id'), email: @$("#choose-parent option:selected").text()})
    view = new MsRobot.Views.GroupContacts.GroupContactForm({model: model, collection: @collection})

    $(@el).append(view.render().el)
    $("#modal-form-group").modal("show")


