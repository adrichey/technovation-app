require "rails_helper"

RSpec.describe Account do
  subject(:account) { FactoryGirl.create(:account) }

  it "sets an auth token" do
    expect(account.auth_token).not_to be_blank
  end

  it "requires a secure password" do
    account = FactoryGirl.build(:account, password: "short")
    expect(account).not_to be_valid
    expect(account.errors[:password]).to eq(["is too short (minimum is 8 characters)"])
  end

  it "re-subscribes new email addresses" do
    ENV['ACCOUNT_LIST_ID'] = "some-id"
    account = FactoryGirl.create(:account)

    expect(UpdateEmailListJob).to receive(:perform_later)
      .with(account.email, "new@email.com", account.full_name, "some-id")

    account.update_attributes(email: "new@email.com")
  end
end
