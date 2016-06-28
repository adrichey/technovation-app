if Region.create(name: "US/Canada").valid?
  puts "Created Region: #{Region.last.name}"
end

if Season.create(year: Time.current.year, starts_at: Time.current).valid?
  puts "Created Season: #{Season.current.year}"
end

if CreateScoringRubric.([{
     category: "Ideation",
     questions: [{ label: "Did the team identify a real problem in their community?",
                   values: [{ value: 0, label: "No" },
                            { value: 3, label: "Yes" }] }]
   },
   { category: "Technical" },
   { category: "Entrepreneurship" },
   { category: "Subjective", expertise: false },
   { category: "Bonus", expertise: false },
])

  ScoreCategory.all.each do |category|
    puts "Created ScoreCategory: #{category.name}"

    category.score_questions.each do |score_question|
      puts "Created ScoreQuestion: #{score_question.label}"

      score_question.score_values.each do |score_value|
        puts "Created ScoreValue: #{score_value.label} - #{score_value.value}"
      end
    end
  end
end

if Expertise.create(name: "Science").valid?
  puts "Created Expertise: #{Expertise.last.name}"
end

if (team = Team.create(name: "The Techno Girls",
                       description: "A great team of smart and capable girls!",
                       division: Division.high_school,
                       region: Region.last)).valid?

  puts "Created Team: #{team.name}"

  team.submissions.create!(code: "code", description: "description", pitch: "pitch", demo: "demo")
  puts "Created Submission"
end

if (team = Team.create(name: "Girl Power",
                       description: "Another great team of smart and capable girls!",
                       division: Division.high_school,
                       region: Region.last)).valid?

  puts "Created Team: #{team.name}"

  team.submissions.create!(code: "code", description: "description", pitch: "pitch", demo: "demo")
  puts "Created Submission"
end

if (judge = CreateAuthentication.(email: "judge@judging.com",
                                  password: "judge@judging.com",
                                  password_confirmation: "judge@judging.com",
                                  judge_profile_attributes: {
                                    scoring_expertise_ids: ScoreCategory.is_expertise.pluck(:id),
                                    company_name: "ACME, Inc.",
                                    job_title: "Engineer",
                                  },
                                  basic_profile_attributes: {
                                    first_name: "Judgy",
                                    last_name: "McGee",
                                    date_of_birth: Date.today - 31.years,
                                    city: "Chicago",
                                    region: "IL",
                                    country: "USA",
                                  },)).save
  puts "Created Judge: #{judge.email} with password #{judge.password}"
end

if (admin = CreateAdmin.(email: "admin@admin.com",
                         password: "admin@admin.com",
                         password_confirmation: "admin@admin.com",
                         basic_profile_attributes: {
                          first_name: "Test",
                          last_name: "Admin",
                          date_of_birth: Date.today,
                          city: "Chicago",
                          region: "IL",
                          country: "US"
                         })).save
  puts "Created Admin: #{admin.email} with password #{admin.password}"
end
