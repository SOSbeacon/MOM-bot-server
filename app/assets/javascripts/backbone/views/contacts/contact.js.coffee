MsRobot.Views.Contacts ||= {}

class MsRobot.Views.Contacts.ListItem extends MsRobot.Views.Skel.ListItemView
  template: JST["backbone/templates/contacts/listitem"]

  events:
    "click #edit" : "editGroup",
    "click #delete": "deleteGroup"

  editGroup: =>
    view = new MsRobot.Views.Contacts.ContactForm({model: @model, collection: @collection})
    $('body').append(view.render().el)
    $("#modal-form-contact").modal("show")

  deleteGroup: =>
    proceed = confirm('Are you sure you want to delete?  This cannot be undone.')
    if proceed
      @model.url = =>
        "/contacts/#{@model.get('id')}.json?auth_token=#{@session.get('authentication_token')}"

      @model.destroy({
        success: =>
          @alert.hideAlert()
          @alert.showAlert("", "Delete contact successfully", "alert-success")
      })

class MsRobot.Views.Contacts.ListHeader extends MsRobot.Views.Skel.ListItemHeader
  template: JST["backbone/templates/contacts/header"]


class MsRobot.Views.Contacts.ListView extends MsRobot.Views.Skel.ListView
  template: JST["backbone/templates/contacts/listview"]
  itemView: MsRobot.Views.Contacts.ListItem
  headerView: MsRobot.Views.Contacts.ListHeader


class MsRobot.Views.Contacts.ContactForm extends Backbone.View
  template: JST["backbone/templates/contacts/form"]
  className: "modal"
  id: "modal-form-contact"

  initialize: (options) =>
    @session = new MsRobot.Models.Session()
    @collection = options.collection
    @alert = new MsRobot.Views.Common.AlertView()
    $("#modal-form-contact").remove()

  events:
    "click #submit" : "createContact"

  render: =>
    $(@el).html(@template(@model.toJSON()))
    return this

  renderGroupContact: =>
    groupContact = new MsRobot.Collections.GroupContactsCollection()
    groupContact.url = =>
      "/group_contacts.json?auth_token=#{@session.get('authentication_token')}"

    groupContact.fetch({
      async: false,
      success: (response) =>
        response.each((model, index) =>
          @$("#select_group").append(
            $("<option></option>")
            .attr('value', model.get('id'))
            .html(model.get('name'))
          )
        )
    })

    @$(".chosen-select").chosen()

    that = this
    if @model.get('group')
      @$("option").each ->
        if parseInt($(this).attr("value")) == parseInt(that.model.get("group").id)
          $(this).attr "selected", "selected"

      @$(".chosen-select").trigger("chosen:updated")

  createContact: =>
    if @$("#name").val().trim() == ""
      @alert.hideAlert()
      @alert.showAlert("", "Name can't be blank", "alert-danger", "contact-alert")
      return

    if @$("#phone").val().trim() == "" && @$("#email").val().trim() == ""
      @alert.hideAlert()
      @alert.showAlert("", "You need fill email or phone field", "alert-danger", "contact-alert")
      return

    if @$("#email").val().trim()
      if !validateEmail(@$("#email").val().trim())
        @alert.hideAlert()
        @alert.showAlert("", "Email invalid format", "alert-danger", "contact-alert")
        return this

    data = {
      email: @$("#email").val().trim(),
      phone: @$("#phone").val().trim(),
      name: @$("#name").val().trim()
    }

#    if $("#select_group").val()
#      data.group_id = $("#select_group").val()

    that = this
    console.log data

    if @model.get("id")
      @model.url = =>
        "/contacts/#{@model.get('id')}.json?auth_token=#{@session.get('authentication_token')}"
    else
      @model.url = =>
        "/contacts.json?auth_token=#{@session.get('authentication_token')}"

    @model.save(data,
      success: (response) =>
        that.collection.add(response)
        $("#modal-form-contact").modal("hide")
        that.alert.hideAlert()
        that.alert.showAlert("", "Save contact successfully", "alert-success")

      error: (jqXHR, textStatus, errorThrown) =>
        console.log textStatus
        if textStatus.status == 422
          @alert.showAlert("", JSON.parse(textStatus.responseText), "alert-danger", "contact-alert")
        else if textStatus.status == 400
          @alert.showAlert("", JSON.parse(textStatus.responseText), "alert-danger", "contact-alert")
    )



class MsRobot.Views.Contacts.ContactViewApp extends MsRobot.Views.Skel.CollectionView
  template: JST["backbone/templates/contacts/contact"]

  initialize: (options) =>
    @session = new MsRobot.Models.Session()
    @alert = new MsRobot.Views.Common.AlertView()
    @collection = new MsRobot.Collections.ContactsCollection()
    @model = new MsRobot.Models.Contact()
    @collection.url = =>
      "/contacts.json?group_id=#{@id}&auth_token=#{@session.get('authentication_token')}"

    @listView = new MsRobot.Views.Contacts.ListView({collection:@collection})

  events:
    "click #create-contact": "showContact"

  render: =>
    @renderGroupInfo()
    @$("#showcontent").html(@listView.render().el)
    @$(".chosen-select").chosen()
    return this

  renderGroupInfo: =>
    session = new MsRobot.Models.Session()
    @group = new MsRobot.Models.GroupContact()

    @group.url = =>
      "/group_contacts/#{@id}.json?auth_token=#{session.get('authentication_token')}"

    @group.fetch({async: false})

    $(@el).html(@template(@group.toJSON()))
    return this

  showContact: =>
    model = new MsRobot.Models.Contact()
    model.set({"group_id": @id, "user_id": @group.get("user").id})
    view = new MsRobot.Views.Contacts.ContactForm({model: model, collection: @collection})

    $(@el).append(view.render().el)
    $("#modal-form-contact").modal("show")
