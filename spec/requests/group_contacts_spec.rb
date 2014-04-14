require 'spec_helper'

describe "GroupContacts" do
  let(:user) { FactoryGirl.create(:user) }

  before :each do
    @parent = User.create!({
       first_name: "ngon",
       last_name: "ngon",
       creator_id: user.id,
       email: "paren1t@gmail.com",
       password: "12345678",
       password_confirmation: "12345678",
       confirmed_at: Time.now,
       type_user: 'parent'
    })
  end

  describe '#show' do
    let(:group_contact)  { FactoryGirl.create(:group_contact, :user => @parent) }

    context 'when there is no authentication token' do
      before do
        get "/group_contacts/#{group_contact.id}.json"
      end

      it 'should return 401' do
        expect(response.status).to equal(401)
      end
    end

    context 'when there is authentication token' do
      before do
        get "/group_contacts/#{group_contact.id}.json?auth_token=#{user.authentication_token}"
      end

      it 'should return 200' do
        expect(response.status).to equal(200)
      end

      it 'should return correct format' do
        format = %w[id name user updated_at created_at contacts]
        data = JSON.parse(response.body)

        format.each do |f|
          expect(data.key?(f)).to equal(true)
        end
      end
    end
  end

  describe '#create' do
    let(:contact1) { FactoryGirl.create(:contact, :user => user) }
    let(:contact2) { FactoryGirl.create(:contact, :user => user) }
    let(:contact3) { FactoryGirl.create(:contact, :user => user) }

    before :each do
      @attr = {
        name: 'new group contact name',
        contacts_id: [contact1.id, contact2.id, contact3.id],
        user_id: @parent.id
      }
    end

    context 'when there is no authentication token' do
      before do
        post "/group_contacts.json", {:group_contact => @attr}
      end

      it 'should return 401' do
        expect(response.status).to equal(401)
      end
    end

    context 'when there is authentication token' do
      before do
        post "/group_contacts.json", {:auth_token => user.authentication_token, :group_contact => @attr}
      end

      it 'should return 201' do
        expect(response.status).to equal(201)
      end

      it 'should return correct format' do
        format = %w[id name user_id updated_at created_at]
        data = JSON.parse(response.body)

        format.each do |f|
          expect(data.key?(f)).to equal(true)
        end
      end

      it 'should update db' do
        expect(GroupContact.last.name).to eq(@attr[:name])
        expect(JSON.parse(response.body)['contacts'].count).to equal(3)
      end
    end

    context 'when parent create' do
      before do
        post "/group_contacts.json", {:auth_token => @parent.authentication_token, :group_contact => @attr}
      end

      it 'should return 400' do
        expect(response.status).to equal(400)
      end
    end
  end

  describe '#update' do
    let(:group_contact)  { FactoryGirl.create(:group_contact, :user => @parent) }
    let(:contact) { FactoryGirl.create(:contact, :user => user, :group_contact => group_contact) }
    let(:contact1) { FactoryGirl.create(:contact, :user => user) }
    let(:contact2) { FactoryGirl.create(:contact, :user => user) }

    before :each do
      @attr = {
        name: 'edit group contact name',
        contacts_id: [contact.id]
      }
    end

    context 'when there is no authentication token' do
      before do
        put "/group_contacts/#{group_contact.id}.json", {:group_contact => @attr}
      end

      it 'should return 401' do
        expect(response.status).to equal(401)
      end
    end

    context 'when there is authentication token' do
      before do
        put "/group_contacts/#{group_contact.id}.json", {:auth_token => user.authentication_token, :group_contact => @attr.merge(:contacts_id => [contact1.id, contact2.id])}
      end

      it 'should return 201' do
        expect(response.status).to equal(201)
      end

      it 'should return correct format' do
        format = %w[id name user updated_at created_at]
        data = JSON.parse(response.body)

        format.each do |f|
          expect(data.key?(f)).to equal(true)
        end
      end

      it 'should update db' do
        expect(GroupContact.where(:id => group_contact.id).last.name).to eq(@attr[:name])
        expect(Contact.where(:group_id => group_contact.id).count).to equal(2)
      end
    end

    context 'should return 400 if could not find id contact' do
      before do
        put "/group_contacts/#{group_contact.id}.json", {:auth_token => user.authentication_token, :group_contact => @attr.merge(:contacts_id => ['1','2'])}
      end

      it 'should return 400' do
        expect(response.status).to equal(400)
      end
    end

    context 'when other user edit' do
      let(:user_other) {FactoryGirl.create(:user)}

      before do
        put "/group_contacts/#{group_contact.id}.json", {:auth_token => user_other.authentication_token, :group_contact => @attr}
      end

      it 'should return 400' do
        expect(response.status).to equal(400)
      end
    end
  end

  describe '#delete' do
    let(:group_contact)  { FactoryGirl.create(:group_contact, :user => @parent) }
    let(:contact) { FactoryGirl.create(:contact, :user => user, :group_contact => group_contact) }

    context 'when there is no authentication token' do
      before do
        delete "/group_contacts/#{group_contact.id}.json"
      end

      it 'should return 401' do
        expect(response.status).to equal(401)
      end
    end

    context 'when there is authentication token' do
      before do
        delete "/group_contacts/#{group_contact.id}.json", {:auth_token => user.authentication_token}
      end

      it 'should return 204' do
        expect(response.status).to equal(204)
      end

      it 'should update db' do
        expect(GroupContact.count).to equal(0)
        expect(Contact.where(:group_id => group_contact.id).count).to equal(0)
      end
    end

    context 'when other user delete' do
      let(:user_other) {FactoryGirl.create(:user)}

      before do
        delete "/group_contacts/#{group_contact.id}.json", {:auth_token => user_other.authentication_token}
      end

      it 'should return 400' do
        expect(response.status).to equal(400)
      end
    end
  end
end

