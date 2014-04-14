class MsRobot.Models.Contact extends Backbone.Model
  paramRoot: 'contact'
  url: '/contacts.json'

  defaults:
    id: null
    email: null
    phone: null
    group_id: null
    user_id: null
    group: null

#  validate: (attrs) =>
#    errors = [];
#
#    if (!attrs.phone)
#      errors.push({name: 'phone', message: 'Pleate fill phone field'})
#
#    if (!attrs.name)
#      errors.push({name: 'name', message: 'Pleate fill name field'})
#
#    if errors.length > 0
#      return errors
#    else
#      return true


class MsRobot.Collections.ContactsCollection extends Backbone.Collection
  model: MsRobot.Models.Contact
  url: '/contacts'
