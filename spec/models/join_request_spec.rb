require "rails_helper"

RSpec.describe JoinRequest do
  it "cannot be duplicated" do
    student = FactoryBot.create(:student)
    team = FactoryBot.create(:team)

    FactoryBot.create(:join_request, team: team, requestor: student)

    dupe = FactoryBot.build(:join_request, team: team, requestor: student)
    expect(dupe).not_to be_valid
  end

  it "deletes other student requests upon acceptance" do
    student = FactoryBot.create(:student)
    approve_me = FactoryBot.create(:join_request, requestor: student)
    delete_me = FactoryBot.create(:join_request, requestor: student)

    JoinRequestApproved.(approve_me)

    expect {
      delete_me.reload
    }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "does not mess with pending mentor join requests on approval" do
    mentor = FactoryBot.create(:mentor)
    approve_me = FactoryBot.create(:join_request, requestor: mentor)
    still_pending = FactoryBot.create(:join_request, requestor: mentor)

    JoinRequestApproved.(approve_me)

    expect(still_pending.reload).to be_pending
  end
end
