require 'spec_helper'

describe EmergencyController do
  include SmsSpec::Helpers
  include SmsSpec::Matchers

  let(:user) { FactoryGirl.create(:user)  }
  let(:user1) { FactoryGirl.create(:user)  }

  before :each do
    @parent = User.create!({
       first_name: "first",
       last_name: "last",
       creator_id: user.id,
       email: "paren1t@gmail.com",
       password: "12345678",
       password_confirmation: "12345678",
       confirmed_at: Time.now,
       type_user: 'parent'
     })

    @message = {
      lat: "12312312",
      lng: "12312312"
    }

    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  let(:group_contact1)  { FactoryGirl.create(:group_contact, :user => @parent) }
  let(:group_contact2)  { FactoryGirl.create(:group_contact, :user => @parent) }

  describe '#emergency' do

    before :each do
      @contact1 = Contact.create!({
        name: "contact1",
        email: "contact1@gmail.com",
        phone: "84973796061",
        group_id: group_contact1.id,
        user_id: @parent.id
      })

      @contact2 = Contact.create!({
        name: "contact2",
        email: "contact2@gmail.com",
        phone: "84973796062",
        group_id: group_contact1.id,
        user_id: @parent.id
      })

      @contact3 = Contact.create!({
        name: "contact3",
        email: "contact3@gmail.com",
        group_id: group_contact2.id,
        user_id: @parent.id
      })

      @contact4 = Contact.create!({
        name: "contact4",
        email: "lhlong142@gmail.com",
        phone: "84973796064",
        group_id: group_contact2.id,
        user_id: @parent.id
      })

      ResqueSpec.reset!
    end

    describe 'Parent request emergency with right params' do
      before :each do
        post "/emergency.json?auth_token=#{@parent.authentication_token}", {:message => @message}
      end

      it 'should create new message' do
        message = Message.last
        expect(message.user_id).to equal(@parent.id)
        expect(Message.count).to equal(1)
      end

      it 'should return 201' do
        expect(response.status).to equal(201)
      end

      it 'should return correct format' do
        format = %w[id lat lng text photo_url audio_url]
        data = JSON.parse(response.body)

        format.each do |f|
          expect(data.key?(f)).to equal(true)
        end
      end

      it 'should update message id to group'do
        message = Message.last
        groups = GroupContact.where(:user_id => @parent.id)
        groups.each do |group|
          expect(group.message_id).to equal(message.id)
        end
      end

      context 'When sent broadcast email' do
        it 'should add user and email to email queue' do
          SentEmail.should have_queue_size_of(4)
        end

        it 'should have queue' do
          SentEmail.should have_queued(@parent.id, @contact1.email, 1)
          SentEmail.should have_queued(@parent.id, @contact2.email, 1)
          SentEmail.should have_queued(@parent.id, @contact3.email, 1)
          SentEmail.should have_queued(@parent.id, @contact4.email, 1)
        end
      end

      context 'when sent broadcast sms' do
        it 'should add user and phone to sms queue' do
          SentSMS.should have_queue_size_of(3)
        end

        it 'should have queue' do
          SentSMS.should have_queued(@parent.id, @contact1.phone, 1)
          SentSMS.should have_queued(@parent.id, @contact2.phone, 1)
          SentSMS.should have_queued(@parent.id, @contact4.phone, 1)
        end

        it 'should' do
          open_last_text_message_for "84973796064"
          current_text_message.should have_body "This is an message. It gets sent to MOM-BOT"
        end

      end

      describe '#SentEmail' do
        it 'should send email' do
          SentEmail.perform(user.id, 'lhlong142@gmail.com', 1)
          ActionMailer::Base.deliveries.length.should == 1
          ActionMailer::Base.deliveries.last.to.should == ['lhlong142@gmail.com']
          ActionMailer::Base.deliveries.last.from.should == ["msrobot2014@gmail.com"]
          ActionMailer::Base.deliveries.last.subject.should == "EMERGENCY FROM MOM-BOT"
        end
      end
    end

    describe 'Child request emergency with right params' do
      before :each do
        post "/emergency.json?auth_token=#{user.authentication_token}", {:user_id => @parent.id, :message => @message}
      end

      context 'When sent broadcast email' do
        it 'should add user and email to email queue' do
          SentEmail.should have_queue_size_of(4)
        end

        it 'should have queue' do
          SentEmail.should have_queued(@parent.id, @contact1.email, 1)
          SentEmail.should have_queued(@parent.id, @contact2.email, 1)
          SentEmail.should have_queued(@parent.id, @contact3.email, 1)
          SentEmail.should have_queued(@parent.id, @contact4.email, 1)
        end
      end

      context 'when sent broadcast sms' do
        it 'should add user and phone to sms queue' do
          SentSMS.should have_queue_size_of(3)
        end

        it 'should have queue' do
          SentSMS.should have_queued(@parent.id, @contact1.phone, 1)
          SentSMS.should have_queued(@parent.id, @contact2.phone, 1)
          SentSMS.should have_queued(@parent.id, @contact4.phone, 1)
        end
      end

      describe '#SentEmail' do
        it 'should send email' do
          SentEmail.perform(user.id, 'lhlong142@gmail.com', 1)
          ActionMailer::Base.deliveries.length.should == 1
          ActionMailer::Base.deliveries.last.to.should == ['lhlong142@gmail.com']
          ActionMailer::Base.deliveries.last.from.should == ["msrobot2014@gmail.com"]
          ActionMailer::Base.deliveries.last.subject.should == "EMERGENCY FROM MOM-BOT"
        end
      end

      #describe '#SentSMS' do
      #  it 'should send sms' do
      #    SentSMS.perform(user.id, '841274249718')
      #    open_last_text_message_for "841274249718"
      #    current_text_message.should have_body "This is an message. It gets sent to MOM-BOT"
      #  end
      #end
    end

  end

  describe '#update_message' do
    before :each do
      @message = Message.create!({
        :user_id => @parent.id,
        :lat => "12312312",
        :lng => "12312312"
      })
    end

    context 'when there is no authentication token' do
      before do
        put "/emergency/#{@message.id}.json"
      end

      it 'should return 401' do
        expect(response.status).to equal(401)
      end
    end

    context 'when update photo to message' do
      before :each do
        @attr = {
          photo_url: fixture_file_upload(Rails.root + 'spec/fixtures/photo_files/photo.jpg', 'image/jpg')
        }
        put "/emergency/#{@message.id}.json?auth_token=#{@parent.authentication_token}", {:message => @attr}
      end

      it 'should store to message' do
        expect(response.status).to equal(201)
      end

      it 'should return correct format' do
        format = %w[id lat lng text photo_url audio_url]
        data = JSON.parse(response.body)

        format.each do |f|
          expect(data.key?(f)).to equal(true)
        end
      end

      it 'should update db' do
        expect(JSON.parse(response.body)['photo_url']['url']).to eq("#{Rails.root}/spec/support/uploads/message/photo_url/#{@message.id}/photo.jpg")
      end
    end

    context 'when upload audio to message' do
      before :each do
        @attr = {
            audio_url: fixture_file_upload(Rails.root + 'spec/fixtures/audio_files/audio.m4a', 'audio/m4a')
        }
        put "/emergency/#{@message.id}.json?auth_token=#{@parent.authentication_token}", {:message => @attr}
      end

      it 'should store to message' do
        expect(response.status).to equal(201)
      end

      it 'should return correct format' do
        format = %w[id lat lng text photo_url audio_url]
        data = JSON.parse(response.body)

        format.each do |f|
          expect(data.key?(f)).to equal(true)
        end
      end

      it 'should update db' do
        expect(JSON.parse(response.body)['audio_url']['url']).to eq("#{Rails.root}/spec/support/uploads/message/audio_url/#{@message.id}/audio.m4a")
      end
    end

    context 'when update text to message' do
      before :each do
        @attr = {
            text: "ngon roi nhe"
        }
        put "/emergency/#{@message.id}.json?auth_token=#{@parent.authentication_token}", {:message => @attr}
      end

      it 'should store to message' do
        expect(response.status).to equal(201)
      end

      it 'should return correct format' do
        format = %w[id lat lng text photo_url audio_url]
        data = JSON.parse(response.body)

        format.each do |f|
          expect(data.key?(f)).to equal(true)
        end
      end

      it 'should update db' do
        expect(JSON.parse(response.body)['text']).to eq(@attr[:text])
      end
    end

    context 'when wrong format photo upload' do
      before :each do
        @attr = {
            photo_url: fixture_file_upload(Rails.root + 'spec/fixtures/audio_files/audio.m4a', 'audio/m4a')
        }
        put "/emergency/#{@message.id}.json?auth_token=#{@parent.authentication_token}", {:message => @attr}
      end

      it 'should store to message' do
        expect(response.status).to equal(422)
      end
    end

    context 'when wrong format audio upload' do
      before :each do
        @attr = {
            audio_url: fixture_file_upload(Rails.root + 'spec/fixtures/photo_files/photo.jpg', 'image/jpg')
        }
        put "/emergency/#{@message.id}.json?auth_token=#{@parent.authentication_token}", {:message => @attr}
      end

      it 'should store to message' do
        expect(response.status).to equal(422)
      end
    end

  end

  describe '#delete_message' do
    before :each do
      @message = Message.create!({
        :user_id => @parent.id,
        :lat => "12312312",
        :lng => "12312312"
      })
      @group = GroupContact.create!({
        :name => "group 1",
        :user_id => @parent.id,
        :message_id => @message.id
      })
    end

    context 'when there is no authentication token' do
      before do
        delete "/emergency/#{@message.id}.json"
      end

      it 'should return 401' do
        expect(response.status).to equal(401)
      end
    end

    context 'when remove emergency' do
      before :each do
        delete "/emergency/#{@message.id}.json?auth_token=#{@parent.authentication_token}"
      end

      it 'should return 204' do
        expect(response.status).to equal(204)
      end

      it 'should remove from db' do
        expect(Message.count).to equal(0)
      end

      it 'should remove message_id from group' do
        expect(GroupContact.where(:id => @group.id).first.message_id).to eq(nil)
      end
    end

  end

end