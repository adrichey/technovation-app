require "rails_helper"

RSpec.feature "Find a mentor" do
  scenario "See the list of mentors" do
    Season.create_current
    mentor = FactoryGirl.create(:mentor, :with_expertises)
    student = FactoryGirl.create(:student)

    sign_in(student)
    click_link "Find a mentor"

    within('.mentor') do
      expect(page).to have_link(mentor.full_name, href: mentor_path(mentor))

      mentor.expertises.pluck(:name).each do |expertise_name|
        expect(page).to have_css('.mentor_expertise', text: expertise_name)
      end
    end
  end
end
