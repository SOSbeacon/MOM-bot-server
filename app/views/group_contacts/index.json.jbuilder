json.array!(@group_contacts) do |group_contact|
  json.extract! group_contact, :id, :name
  json.url group_contact_url(group_contact, format: :json)
end
