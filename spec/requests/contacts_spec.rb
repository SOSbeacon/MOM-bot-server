require 'spec_helper'

describe "Contacts" do
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
    let(:contact)  { FactoryGirl.create(:contact, :user => user, :group_contact => group_contact) }

    context 'when there is no authentication token' do
      before do
        get "/contacts/#{contact.id}.json"
      end

      it 'should return 401' do
        expect(response.status).to equal(401)
      end
    end

    context 'when there is authentication token' do
      before do
        get "/contacts/#{contact.id}.json?auth_token=#{user.authentication_token}"
      end

      it 'should return 200' do
        expect(response.status).to equal(200)
      end

      it 'should return correct format' do
        format = %w[id name phone email user_id group]
        data = JSON.parse(response.body)

        format.each do |f|
          expect(data.key?(f)).to equal(true)
        end
      end
    end

    context 'when contact belong to group contact' do
      before do
        get "/contacts/#{contact.id}.json?auth_token=#{user.authentication_token}"
      end

      it 'should return group contact' do
        expect(JSON.parse(response.body)["group"]["id"]).to equal(group_contact.id)
      end
    end

    context 'when parent get list contact' do
      before do
        get "/contacts/#{contact.id}.json?auth_token=#{@parent.authentication_token}"
      end

      it 'should return 400' do
        expect(response.status).to equal(400)
      end
    end
  end

  describe '#create' do
    let(:group_contact)  { FactoryGirl.create(:group_contact, :user => @parent) }

    before :each do
      @attr = {
          name: 'new contact a',
          email: 'newemail@gamil.com',
          phone: '1234567899',
          group_id: group_contact.id,
          user_id: @parent.id
      }
    end

    context 'when there is no authentication token' do
      before do
        post "/contacts.json", {:contact => @attr}
      end

      it 'should return 401' do
        expect(response.status).to equal(401)
      end
    end

    context 'when there is authentication token' do
      before do
        post "/contacts.json", {:auth_token => user.authentication_token, :contact => @attr}
      end

      it 'should return 201' do
        expect(response.status).to equal(201)
      end

      it 'should return correct format' do
        format = %w[id name phone email user_id group_id]
        data = JSON.parse(response.body)

        format.each do |f|
          expect(data.key?(f)).to equal(true)
        end
      end

      it 'update db' do
        expect(Contact.count).to equal(1)
        expect(Contact.last.name).to eq(@attr[:name])
      end
    end

    context 'should return 422 if could not find id group contact' do
      before do
        post "/contacts.json", {:auth_token => user.authentication_token, :contact => @attr.merge(:group_id => 123)}
      end

      it 'should return 422' do
        expect(response.status).to equal(422)
      end
    end

    context 'when parent create contact' do
      before do
        post "/contacts.json", {:auth_token => @parent.authentication_token, :contact => @attr}
      end

      it 'should return 400' do
        expect(response.status).to equal(400)
      end
    end
  end

  describe '#update' do
    let(:group_contact)  { FactoryGirl.create(:group_contact, :user => @parent) }
    let(:group_contact1)  { FactoryGirl.create(:group_contact, :user => @parent) }
    let(:contact) { FactoryGirl.create(:contact, :user => @parent, :group_contact => group_contact) }

    before :each do
      @attr = {
        name: 'edit contact a',
        email: 'newemail@gamil.com',
        phone: '1234567899',
        group_id: '',
        user_id: @parent.id
      }
    end

    context 'when there is no authentication token' do
      before do
        put "/contacts/#{contact.id}.json", {:contact => @attr}
      end

      it 'should return 401' do
        expect(response.status).to equal(401)
      end
    end

    context 'when there is authentication token' do
      before do
        put "/contacts/#{contact.id}.json", {:auth_token => user.authentication_token, :contact => @attr.merge(:group_id => group_contact1.id)}
      end

      it 'should return 201' do
        expect(response.status).to equal(201)
        expect(JSON.parse(response.body)["group_id"]).to equal(group_contact1.id)
      end

      it 'should return correct format' do
        format = %w[id name phone email user_id group_id]
        data = JSON.parse(response.body)

        format.each do |f|
          expect(data.key?(f)).to equal(true)
        end
      end

      it 'update db' do
        expect(Contact.count).to equal(1)
        expect(Contact.last.name).to eq(@attr[:name])
      end
    end

    context 'should return 422 if could not find id group contact' do
      before do
        put "/contacts/#{contact.id}.json", {:auth_token => user.authentication_token, :contact => @attr.merge(:group_id => 1223)}
      end

      it 'should return 422' do
        expect(response.status).to equal(422)
      end
    end

    context 'when other user edit' do
      let(:user_other) {FactoryGirl.create(:user)}

      before do
        put "/contacts/#{contact.id}.json", {:auth_token => user_other.authentication_token, :contact => @attr}
      end

      it 'should return 400' do
        expect(response.status).to equal(400)
      end
    end

    context 'when parent edit contact' do
      before do
        put "/contacts/#{contact.id}.json", {:auth_token => @parent.authentication_token, :contact => @attr}
      end

      it 'should return 400' do
        expect(response.status).to equal(400)
      end
    end
  end

  describe '#delete' do
    let(:contact)  { FactoryGirl.create(:contact, :user => user) }

    context 'when there is no authentication token' do
      before do
        delete "/contacts/#{contact.id}.json"
      end

      it 'should return 401' do
        expect(response.status).to equal(401)
      end
    end

    context 'when there is authentication token' do
      before do
        delete "/contacts/#{contact.id}.json", {:auth_token => user.authentication_token}
      end

      it 'should return 204' do
        expect(response.status).to equal(204)
      end

      it 'update db' do
        expect(Contact.count).to equal(0)
      end
    end

    context 'when other user delete' do
      let(:user_other) {FactoryGirl.create(:user)}

      before do
        delete "/contacts/#{contact.id}.json", {:auth_token => user_other.authentication_token}
      end

      it 'should return 400' do
        expect(response.status).to equal(400)
      end
    end

    context 'when parent delete contact' do
      before do
        delete "/contacts/#{contact.id}.json", {:auth_token => @parent.authentication_token}
      end

      it 'should return 400' do
        expect(response.status).to equal(400)
      end
    end
  end
end
