# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

seed_templates = [
  {
    name: "Modern",
    slug: "modern",
    description: "Bold headings with balanced spacing for product and tech resumes.",
    active: true,
    layout_config: {
      "variant" => "modern",
      "accent_color" => "#0F172A",
      "font_scale" => "base"
    }
  },
  {
    name: "Classic",
    slug: "classic",
    description: "A compact, traditional layout tuned for ATS-friendly exports.",
    active: true,
    layout_config: {
      "variant" => "classic",
      "accent_color" => "#1D4ED8",
      "font_scale" => "sm"
    }
  }
]

seed_platform_setting = {
  feature_flags: {
    "llm_access" => false,
    "resume_suggestions" => false,
    "autofill_content" => false
  },
  preferences: {
    "default_template_slug" => "modern",
    "support_email" => "support@example.com"
  }
}

seed_users = if Rails.env.development? || Rails.env.test?
  seed_random = Random.new(ENV.fetch("SEED_RANDOM", Rails.env.test? ? "20260319" : "20260320").to_i)
  Faker::Config.random = seed_random
  Faker::UniqueGenerator.clear

  city_and_state = -> { "#{Faker::Address.city}, #{Faker::Address.state_abbr}" }
  sentence = ->(word_count: 8) { Faker::Lorem.sentence(word_count:) }
  paragraph = ->(sentence_count: 2) { Faker::Lorem.paragraph(sentence_count:) }
  degree = -> do
    [
      "B.S. Computer Science",
      "B.S. Information Systems",
      "B.A. Product Design",
      "B.F.A. Interaction Design"
    ].sample(random: seed_random)
  end
  skill_level = -> { ["Expert", "Advanced", "Advanced"].sample(random: seed_random) }

  build_seed_resume = lambda do |
    email_address:, template_slug:, accent_color:, primary_title:, secondary_title:, focus:, project_name:,
    project_role:, skills:|
    full_name = Faker::Name.name
    current_company = Faker::Company.name
    previous_company = Faker::Company.name
    hometown = city_and_state.call
    previous_location = city_and_state.call
    school_location = city_and_state.call
    full_name_slug = full_name.parameterize
    current_start_year = Faker::Number.between(from: 2021, to: 2023).to_s
    previous_start_year = Faker::Number.between(from: 2017, to: 2019).to_s
    previous_end_year = (current_start_year.to_i - 1).to_s
    education_end_year = Faker::Number.between(from: 2014, to: 2018)
    education_start_year = (education_end_year - 4).to_s
    website = "https://#{Faker::Internet.domain_name}"

    {
      slug: "#{full_name_slug}-#{template_slug}",
      template_slug:,
      title: "#{full_name} Resume",
      headline: "#{primary_title} | #{focus} | #{Faker::Job.field}",
      summary: paragraph.call(sentence_count: 2),
      contact_details: {
        "full_name" => full_name,
        "email" => email_address,
        "phone" => Faker::PhoneNumber.phone_number,
        "location" => hometown,
        "website" => website,
        "linkedin" => "linkedin.com/in/#{full_name_slug.delete("-")}"
      },
      settings: {
        "accent_color" => accent_color,
        "show_contact_icons" => true,
        "page_size" => "A4"
      },
      sections: [
        {
          title: "Experience",
          section_type: "experience",
          entries: [
            {
              "title" => primary_title,
              "organization" => current_company,
              "location" => hometown,
              "start_date" => current_start_year,
              "end_date" => "Present",
              "summary" => paragraph.call(sentence_count: 2),
              "highlights" => [
                sentence.call(word_count: 10),
                sentence.call(word_count: 10)
              ]
            },
            {
              "title" => secondary_title,
              "organization" => previous_company,
              "location" => previous_location,
              "start_date" => previous_start_year,
              "end_date" => previous_end_year,
              "summary" => paragraph.call(sentence_count: 2),
              "highlights" => [
                sentence.call(word_count: 10),
                sentence.call(word_count: 10)
              ]
            }
          ]
        },
        {
          title: "Education",
          section_type: "education",
          entries: [
            {
              "institution" => "#{Faker::Address.city} University",
              "degree" => degree.call,
              "location" => school_location,
              "start_date" => education_start_year,
              "end_date" => education_end_year.to_s,
              "details" => sentence.call(word_count: 12)
            }
          ]
        },
        {
          title: "Skills",
          section_type: "skills",
          entries: skills.map do |skill_name|
            { "name" => skill_name, "level" => skill_level.call }
          end
        },
        {
          title: "Projects",
          section_type: "projects",
          entries: [
            {
              "name" => project_name,
              "role" => project_role,
              "url" => "#{website}/#{project_name.parameterize}",
              "summary" => paragraph.call(sentence_count: 2),
              "highlights" => [
                sentence.call(word_count: 10),
                sentence.call(word_count: 10)
              ]
            }
          ]
        }
      ]
    }
  end

  build_seed_user = lambda do |
    label:, role:, email_address:, password:, template_slug:, accent_color:, primary_title:,
    secondary_title:, focus:, project_name:, project_role:, skills:|
    {
      label:,
      role:,
      email_address:,
      password:,
      resumes: [
        build_seed_resume.call(
          email_address:,
          template_slug:,
          accent_color:,
          primary_title:,
          secondary_title:,
          focus:,
          project_name:,
          project_role:,
          skills:
        )
      ]
    }
  end

  [
    build_seed_user.call(
      label: "Admin",
      role: :admin,
      email_address: "admin@resume-builder.local",
      password: "password123!",
      template_slug: "modern",
      accent_color: "#0F172A",
      primary_title: "Engineering Manager",
      secondary_title: "Senior Software Engineer",
      focus: "Rails Delivery",
      project_name: "Resume Builder",
      project_role: "Product Lead",
      skills: ["Ruby on Rails", "Hotwire", "Product Leadership"]
    ),
    build_seed_user.call(
      label: "Demo User",
      role: :user,
      email_address: "demo@resume-builder.local",
      password: "password123!",
      template_slug: "classic",
      accent_color: "#1D4ED8",
      primary_title: "Senior Product Designer",
      secondary_title: "Product Designer",
      focus: "UX Systems",
      project_name: "Portfolio Refresh",
      project_role: "Designer",
      skills: ["Product Design", "Design Systems", "User Research"]
    )
  ]
else
  []
end

ApplicationRecord.transaction do
  seed_templates.each do |attributes|
    template = Template.find_or_initialize_by(slug: attributes.fetch(:slug))
    template.update!(attributes)
  end

  platform_setting = PlatformSetting.find_or_initialize_by(name: "global")
  platform_setting.update!(seed_platform_setting)

  unless Rails.env.production?
    seed_users.each do |user_definition|
      user = User.find_or_initialize_by(email_address: user_definition.fetch(:email_address))
      password = user_definition.fetch(:password)

      user.assign_attributes(
        role: user_definition.fetch(:role),
        password: password,
        password_confirmation: password
      )
      user.save!

      user_definition.fetch(:resumes).each do |resume_definition|
        template = Template.find_by!(slug: resume_definition.fetch(:template_slug))
        resume = user.resumes.find_or_initialize_by(slug: resume_definition.fetch(:slug))

        resume.assign_attributes(
          title: resume_definition.fetch(:title),
          headline: resume_definition.fetch(:headline),
          summary: resume_definition.fetch(:summary),
          contact_details: resume_definition.fetch(:contact_details),
          settings: resume_definition.fetch(:settings),
          template: template
        )
        resume.save!

        resume.sections.destroy_all

        resume_definition.fetch(:sections).each_with_index do |section_definition, section_index|
          section = resume.sections.create!(
            title: section_definition.fetch(:title),
            section_type: section_definition.fetch(:section_type),
            position: section_index,
            settings: section_definition.fetch(:settings, {})
          )

          section_definition.fetch(:entries).each_with_index do |entry_definition, entry_index|
            section.entries.create!(content: entry_definition, position: entry_index)
          end
        end
      end
    end
  end
end

unless Rails.env.production?
  puts "Seeded demo accounts:"
  seed_users.each do |user_definition|
    puts(
      "- #{user_definition.fetch(:label)}: #{user_definition.fetch(:email_address)} / " \
      "#{user_definition.fetch(:password)}"
    )
  end
end
