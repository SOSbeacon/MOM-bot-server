class MsRobot.Models.GroupContact extends Backbone.Model
  paramRoot: 'group_contact'
  url: '/group_contacts.json'

  defaults:
    id: null
    name: null
    user: {
      id: null,
      email: null
    }
    contacts: []


class MsRobot.Collections.GroupContactsCollection extends Backbone.Collection
  model: MsRobot.Models.GroupContact
  url: '/group_contacts'
