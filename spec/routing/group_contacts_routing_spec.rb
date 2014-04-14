require "spec_helper"

describe GroupContactsController do
  describe "routing" do

    it "routes to #index" do
      get("/group_contacts").should route_to("group_contacts#index")
    end

    it "routes to #new" do
      get("/group_contacts/new").should route_to("group_contacts#new")
    end

    it "routes to #show" do
      get("/group_contacts/1").should route_to("group_contacts#show", :id => "1")
    end

    it "routes to #edit" do
      get("/group_contacts/1/edit").should route_to("group_contacts#edit", :id => "1")
    end

    it "routes to #create" do
      post("/group_contacts").should route_to("group_contacts#create")
    end

    it "routes to #update" do
      put("/group_contacts/1").should route_to("group_contacts#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/group_contacts/1").should route_to("group_contacts#destroy", :id => "1")
    end

  end
end
