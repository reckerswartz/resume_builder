# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "base64"
require "stringio"

seed_templates = [
  {
    name: "Modern",
    slug: "modern",
    description: "Bold headings with balanced spacing for product and tech resumes.",
    active: true,
    layout_config: {
      "family" => "modern",
      "variant" => "modern",
      "accent_color" => "#0F172A",
      "font_scale" => "base",
      "density" => "comfortable",
      "section_spacing" => "standard",
      "paragraph_spacing" => "standard",
      "line_spacing" => "standard",
      "column_count" => "single_column",
      "theme_tone" => "slate",
      "supports_headshot" => false
    }
  },
  {
    name: "Classic",
    slug: "classic",
    description: "A compact, traditional layout tuned for ATS-friendly exports.",
    active: true,
    layout_config: {
      "family" => "classic",
      "variant" => "classic",
      "accent_color" => "#1D4ED8",
      "font_scale" => "sm",
      "density" => "compact",
      "section_spacing" => "tight",
      "paragraph_spacing" => "tight",
      "line_spacing" => "standard",
      "column_count" => "single_column",
      "theme_tone" => "blue",
      "supports_headshot" => false
    }
  },
  {
    name: "ATS Minimal",
    slug: "ats-minimal",
    description: "A stripped-down layout tuned for ATS-friendly screening and dense professional histories.",
    active: true,
    layout_config: {
      "family" => "ats-minimal",
      "variant" => "ats-minimal",
      "accent_color" => "#334155",
      "font_scale" => "sm",
      "density" => "compact",
      "section_spacing" => "tight",
      "paragraph_spacing" => "tight",
      "line_spacing" => "standard",
      "column_count" => "single_column",
      "theme_tone" => "slate",
      "supports_headshot" => false
    }
  },
  {
    name: "Professional",
    slug: "professional",
    description: "Balanced structure with conservative hierarchy for operations, management, and consulting resumes.",
    active: true,
    layout_config: {
      "family" => "professional",
      "variant" => "professional",
      "accent_color" => "#0F4C81",
      "font_scale" => "base",
      "density" => "comfortable",
      "section_spacing" => "standard",
      "paragraph_spacing" => "standard",
      "line_spacing" => "standard",
      "column_count" => "single_column",
      "theme_tone" => "blue",
      "supports_headshot" => false
    }
  },
  {
    name: "Modern Clean",
    slug: "modern-clean",
    description: "Spacious contemporary cards with lighter chrome for product, design, and tech profiles.",
    active: true,
    layout_config: {
      "family" => "modern-clean",
      "variant" => "modern-clean",
      "accent_color" => "#0F766E",
      "font_scale" => "base",
      "density" => "relaxed",
      "section_spacing" => "relaxed",
      "paragraph_spacing" => "relaxed",
      "line_spacing" => "standard",
      "column_count" => "single_column",
      "theme_tone" => "teal",
      "supports_headshot" => false
    }
  },
  {
    name: "Sidebar Accent",
    slug: "sidebar-accent",
    description: "A two-column layout that tucks supporting details into a tinted sidebar without duplicating content.",
    active: true,
    layout_config: {
      "family" => "sidebar-accent",
      "variant" => "sidebar-accent",
      "accent_color" => "#4338CA",
      "font_scale" => "base",
      "density" => "comfortable",
      "section_spacing" => "standard",
      "paragraph_spacing" => "standard",
      "line_spacing" => "standard",
      "column_count" => "two_column",
      "theme_tone" => "indigo",
      "supports_headshot" => false,
      "sidebar_position" => "left",
      "sidebar_section_types" => %w[skills education]
    }
  },
  {
    name: "Editorial Split",
    slug: "editorial-split",
    description: "An asymmetric editorial layout with a narrow supporting column, stretched name band, and utility rail inspired by polished design-portfolio resumes.",
    active: true,
    layout_config: {
      "family" => "editorial-split",
      "variant" => "editorial-split",
      "accent_color" => "#D7F038",
      "font_scale" => "sm",
      "density" => "compact",
      "section_spacing" => "standard",
      "paragraph_spacing" => "standard",
      "line_spacing" => "standard",
      "column_count" => "two_column",
      "theme_tone" => "lime",
      "supports_headshot" => true,
      "shell_style" => "flat",
      "header_style" => "split",
      "section_heading_style" => "rule",
      "skill_style" => "inline",
      "entry_style" => "list",
      "sidebar_section_types" => %w[education skills projects]
    }
  }
].freeze

seed_platform_setting = {
  feature_flags: {
    "llm_access" => false,
    "resume_suggestions" => false,
    "autofill_content" => false,
    "photo_processing" => !Rails.env.production?,
    "resume_image_generation" => false
  },
  preferences: {
    "default_template_slug" => "modern",
    "support_email" => "support@example.com"
  }
}

seed_llm_providers = [
  {
    name: "Ollama Local",
    slug: "ollama-local",
    adapter: "ollama",
    base_url: "http://127.0.0.1:11434",
    api_key_env_var: nil,
    active: true,
    settings: {
      "request_timeout_seconds" => 30
    }
  },
  {
    name: "NVIDIA Build",
    slug: "nvidia-build",
    adapter: "nvidia_build",
    base_url: "https://integrate.api.nvidia.com",
    api_key_env_var: "NVIDIA_API_KEY",
    active: true,
    settings: {
      "request_timeout_seconds" => 45
    }
  }
].freeze

seed_llm_models = [
  {
    provider_slug: "ollama-local",
    name: "Llama 3.2",
    identifier: "llama3.2:latest",
    active: true,
    supports_text: true,
    supports_vision: false,
    settings: {
      "temperature" => 0.2,
      "max_output_tokens" => 300
    },
    metadata: {
      "seeded" => true
    }
  },
  {
    provider_slug: "ollama-local",
    name: "Llava",
    identifier: "llava:latest",
    active: true,
    supports_text: true,
    supports_vision: true,
    settings: {
      "temperature" => 0.2,
      "max_output_tokens" => 300
    },
    metadata: {
      "seeded" => true
    }
  },
  {
    provider_slug: "nvidia-build",
    name: "Gemma 2 9B IT",
    identifier: "google/gemma-2-9b-it",
    active: true,
    supports_text: true,
    supports_vision: false,
    settings: {
      "temperature" => 0.2,
      "max_output_tokens" => 300
    },
    metadata: {
      "seeded" => true
    }
  },
  {
    provider_slug: "nvidia-build",
    name: "Phi-4 Multimodal Instruct",
    identifier: "microsoft/phi-4-multimodal-instruct",
    active: true,
    supports_text: true,
    supports_vision: true,
    settings: {
      "temperature" => 0.2,
      "max_output_tokens" => 300
    },
    metadata: {
      "seeded" => true
    }
  }
].freeze

seed_users = if Rails.env.development? || Rails.env.test?
  seed_random = Random.new(ENV.fetch("SEED_RANDOM", Rails.env.test? ? "20260319" : "20260320").to_i)
  Faker::Config.random = seed_random
  Faker::UniqueGenerator.clear

  seed_headshot_png = Base64.decode64(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO2Z7mQAAAAASUVORK5CYII="
  )

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
  skill_level = -> { [ "Expert", "Advanced", "Advanced" ].sample(random: seed_random) }

  find_or_create_seed_photo_asset = lambda do |photo_profile:, asset_kind:, filename:, source_asset: nil|
    existing_asset = photo_profile.photo_assets
      .where(asset_kind: asset_kind.to_s, source_asset: source_asset)
      .detect { |asset| asset.display_name == filename || asset.file.filename.to_s == filename }

    if existing_asset.present?
      unless existing_asset.file.attached?
        existing_asset.file.attach(io: StringIO.new(seed_headshot_png), filename: filename, content_type: "image/png")
      end

      existing_asset.update!(status: :ready)
      existing_asset.attach_metadata!(
        "seeded" => true,
        "display_name" => filename,
        "content_type" => existing_asset.file.blob.content_type,
        "byte_size" => existing_asset.file.blob.byte_size,
        "checksum" => existing_asset.file.blob.checksum
      )
      existing_asset
    else
      Photos::AssetBuilder.new(
        photo_profile: photo_profile,
        source_asset: source_asset,
        asset_kind: asset_kind,
        file_io: StringIO.new(seed_headshot_png),
        filename: filename,
        content_type: "image/png",
        metadata: { "seeded" => true },
        status: :ready
      ).call
    end
  end

  seed_photo_library_for_resume = lambda do |user:, resume:, photo_seed:|
    return if photo_seed.blank?

    photo_profile = user.photo_profiles.find_or_initialize_by(name: photo_seed.fetch(:profile_name))
    photo_profile.assign_attributes(status: :active)
    photo_profile.save!

    source_asset = find_or_create_seed_photo_asset.call(
      photo_profile: photo_profile,
      asset_kind: :source,
      filename: photo_seed.fetch(:source_filename)
    )
    preferred_asset = find_or_create_seed_photo_asset.call(
      photo_profile: photo_profile,
      source_asset: source_asset,
      asset_kind: photo_seed.fetch(:preferred_asset_kind, :enhanced),
      filename: photo_seed.fetch(:preferred_filename)
    )

    if photo_profile.selected_source_photo_asset_id != source_asset.id
      photo_profile.update!(selected_source_photo_asset: source_asset)
    end

    resume.update!(photo_profile: photo_profile) if resume.photo_profile_id != photo_profile.id

    selection = resume.resume_photo_selections.find_or_initialize_by(
      template: resume.template,
      slot_name: "headshot"
    )
    selection.photo_asset = photo_seed.fetch(:template_selection, "preferred") == "source" ? source_asset : preferred_asset
    selection.status = :active
    selection.save!
  end

  build_seed_resume = lambda do |
    email_address:, template_slug:, accent_color:, primary_title:, secondary_title:, focus:, project_name:,
    project_role:, skills:, driving_licence:, personal_details:, photo_seed:,
    certifications: [], languages: []|
    full_name = Faker::Name.name
    current_company = Faker::Company.name
    previous_company = Faker::Company.name
    third_company = Faker::Company.name
    fourth_company = Faker::Company.name
    fifth_company = Faker::Company.name
    hometown = city_and_state.call
    previous_location = city_and_state.call
    third_location = city_and_state.call
    fourth_location = city_and_state.call
    school_location = city_and_state.call
    grad_school_location = city_and_state.call
    full_name_slug = full_name.parameterize
    current_start_year = Faker::Number.between(from: 2022, to: 2024).to_s
    second_start_year = Faker::Number.between(from: 2019, to: 2021).to_s
    second_end_year = (current_start_year.to_i - 1).to_s
    third_start_year = Faker::Number.between(from: 2016, to: 2018).to_s
    third_end_year = (second_start_year.to_i - 1).to_s
    fourth_start_year = Faker::Number.between(from: 2013, to: 2015).to_s
    fourth_end_year = (third_start_year.to_i - 1).to_s
    fifth_start_year = Faker::Number.between(from: 2011, to: 2012).to_s
    fifth_end_year = (fourth_start_year.to_i - 1).to_s
    grad_end_year = Faker::Number.between(from: 2012, to: 2014)
    grad_start_year = (grad_end_year - 2).to_s
    undergrad_end_year = grad_start_year.to_i
    undergrad_start_year = (undergrad_end_year - 4).to_s
    website = "https://#{Faker::Internet.domain_name}"

    third_title = [ "Technical Lead", "Lead Developer", "Staff Engineer", "Principal Designer" ].sample(random: seed_random)
    fourth_title = [ "Software Engineer", "Junior Developer", "Associate Designer", "Product Analyst" ].sample(random: seed_random)
    fifth_title = [ "Engineering Intern", "Design Intern", "Graduate Assistant", "Junior Analyst" ].sample(random: seed_random)
    second_project_name = "#{Faker::App.name} Platform"
    second_project_role = [ "Architect", "Tech Lead", "Core Contributor", "Design Lead" ].sample(random: seed_random)

    {
      slug: "#{full_name_slug}-#{template_slug}",
      template_slug:,
      title: "#{full_name} Resume",
      headline: "#{primary_title} | #{focus} | #{Faker::Job.field}",
      summary: "#{paragraph.call(sentence_count: 3)} #{paragraph.call(sentence_count: 2)}",
      contact_details: {
        "full_name" => full_name,
        "email" => email_address,
        "phone" => Faker::PhoneNumber.phone_number,
        "location" => hometown,
        "website" => website,
        "linkedin" => "linkedin.com/in/#{full_name_slug.delete("-")}",
        "driving_licence" => driving_licence
      },
      personal_details: personal_details,
      photo_seed: photo_seed,
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
              "summary" => paragraph.call(sentence_count: 3),
              "highlights" => [
                sentence.call(word_count: 14),
                sentence.call(word_count: 12),
                sentence.call(word_count: 14),
                sentence.call(word_count: 10)
              ]
            },
            {
              "title" => secondary_title,
              "organization" => previous_company,
              "location" => previous_location,
              "start_date" => second_start_year,
              "end_date" => second_end_year,
              "summary" => paragraph.call(sentence_count: 2),
              "highlights" => [
                sentence.call(word_count: 14),
                sentence.call(word_count: 12),
                sentence.call(word_count: 10)
              ]
            },
            {
              "title" => third_title,
              "organization" => third_company,
              "location" => third_location,
              "start_date" => third_start_year,
              "end_date" => third_end_year,
              "summary" => paragraph.call(sentence_count: 2),
              "highlights" => [
                sentence.call(word_count: 12),
                sentence.call(word_count: 14),
                sentence.call(word_count: 10)
              ]
            },
            {
              "title" => fourth_title,
              "organization" => fourth_company,
              "location" => fourth_location,
              "start_date" => fourth_start_year,
              "end_date" => fourth_end_year,
              "summary" => paragraph.call(sentence_count: 2),
              "highlights" => [
                sentence.call(word_count: 12),
                sentence.call(word_count: 10)
              ]
            },
            {
              "title" => fifth_title,
              "organization" => fifth_company,
              "location" => hometown,
              "start_date" => fifth_start_year,
              "end_date" => fifth_end_year,
              "summary" => paragraph.call(sentence_count: 2),
              "highlights" => [
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
              "degree" => [ "M.S. Computer Science", "M.B.A.", "M.A. Design Strategy", "M.S. Data Science" ].sample(random: seed_random),
              "location" => grad_school_location,
              "start_date" => grad_start_year,
              "end_date" => grad_end_year.to_s,
              "details" => "#{sentence.call(word_count: 12)} #{sentence.call(word_count: 10)}"
            },
            {
              "institution" => "#{Faker::Address.city} State University",
              "degree" => degree.call,
              "location" => school_location,
              "start_date" => undergrad_start_year,
              "end_date" => undergrad_end_year.to_s,
              "details" => "#{sentence.call(word_count: 12)} #{sentence.call(word_count: 10)}"
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
              "summary" => paragraph.call(sentence_count: 3),
              "highlights" => [
                sentence.call(word_count: 14),
                sentence.call(word_count: 12),
                sentence.call(word_count: 10)
              ]
            },
            {
              "name" => second_project_name,
              "role" => second_project_role,
              "url" => "#{website}/#{second_project_name.parameterize}",
              "summary" => paragraph.call(sentence_count: 2),
              "highlights" => [
                sentence.call(word_count: 12),
                sentence.call(word_count: 10)
              ]
            }
          ]
        },
        (if certifications.any?
          {
            title: "Certifications",
            section_type: "certifications",
            entries: certifications.map do |cert|
              {
                "name" => cert.fetch(:name),
                "organization" => cert.fetch(:issuer),
                "start_date" => cert.fetch(:year),
                "details" => cert.fetch(:details, "")
              }
            end
          }
         end),
        (if languages.any?
          {
            title: "Languages",
            section_type: "languages",
            entries: languages.map do |lang|
              { "name" => lang.fetch(:name), "level" => lang.fetch(:level) }
            end
          }
         end)
      ].compact
    }
  end

  build_seed_user = lambda do |
    label:, role:, email_address:, password:, template_slug:, accent_color:, primary_title:,
    secondary_title:, focus:, project_name:, project_role:, skills:, driving_licence:, personal_details:,
    photo_seed:, certifications: [], languages: []|
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
          skills:,
          driving_licence:,
          personal_details:,
          photo_seed:,
          certifications:,
          languages:
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
      skills: [
        "Ruby on Rails", "Hotwire", "Product Leadership", "PostgreSQL", "Redis",
        "Docker", "Kubernetes", "CI/CD Pipelines", "Agile Methodologies", "System Design"
      ],
      certifications: [
        { name: "AWS Solutions Architect Associate", issuer: "Amazon Web Services", year: "2023", details: "Cloud architecture design and deployment best practices." },
        { name: "Certified Scrum Master (CSM)", issuer: "Scrum Alliance", year: "2021", details: "Agile team facilitation and sprint planning." }
      ],
      languages: [
        { name: "English", level: "Native" },
        { name: "Hindi", level: "Native" },
        { name: "German", level: "Intermediate" }
      ],
      driving_licence: "Class B",
      personal_details: {
        "date_of_birth" => "",
        "nationality" => "Indian",
        "marital_status" => "",
        "visa_status" => "Authorized to work in India"
      },
      photo_seed: nil
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
      skills: [
        "Product Design", "Design Systems", "User Research", "Figma", "Sketch",
        "Prototyping", "Usability Testing", "Information Architecture", "Accessibility", "Typography"
      ],
      certifications: [
        { name: "Google UX Design Professional Certificate", issuer: "Google / Coursera", year: "2022", details: "End-to-end UX design process including research, wireframing, and high-fidelity prototyping." },
        { name: "Certified Usability Analyst (CUA)", issuer: "Human Factors International", year: "2020", details: "Evidence-based usability evaluation methods." }
      ],
      languages: [
        { name: "English", level: "Native" },
        { name: "Spanish", level: "Conversational" }
      ],
      driving_licence: "Class C",
      personal_details: {
        "date_of_birth" => "",
        "nationality" => "United States",
        "marital_status" => "",
        "visa_status" => "U.S. citizen"
      },
      photo_seed: nil
    )
  ].tap do |users|
    users << build_seed_user.call(
      label: "Demo User with Photo",
      role: :user,
      email_address: "demo-with-photo@resume-builder.local",
      password: "password123!",
      template_slug: "editorial-split",
      accent_color: "#D7F038",
      primary_title: "Design Director",
      secondary_title: "Senior Product Designer",
      focus: "Editorial Systems",
      project_name: "Portfolio Studio Refresh",
      project_role: "Design Lead",
      skills: [
        "Product Design", "Design Systems", "Art Direction", "Brand Strategy", "Motion Design",
        "Creative Direction", "Design Ops", "Cross-functional Leadership", "Stakeholder Management", "Workshop Facilitation"
      ],
      certifications: [
        { name: "Interaction Design Foundation Certificate", issuer: "IDF", year: "2021", details: "Advanced interaction design patterns and design thinking." },
        { name: "Adobe Certified Expert – InDesign", issuer: "Adobe", year: "2019", details: "Professional editorial layout and publication design." }
      ],
      languages: [
        { name: "English", level: "Native" },
        { name: "French", level: "Professional" },
        { name: "Japanese", level: "Basic" }
      ],
      driving_licence: "Class C",
      personal_details: {
        "date_of_birth" => "",
        "nationality" => "United States",
        "marital_status" => "",
        "visa_status" => "U.S. citizen"
      },
      photo_seed: {
        profile_name: "Demo User Photo Library",
        source_filename: "demo-user-source-headshot.png",
        preferred_filename: "demo-user-enhanced-headshot.png",
        template_selection: "preferred"
      }
    )
  end
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

  llm_providers_by_slug = seed_llm_providers.each_with_object({}) do |attributes, registry|
    llm_provider = LlmProvider.find_or_initialize_by(slug: attributes.fetch(:slug))
    llm_provider.update!(attributes)
    registry[attributes.fetch(:slug)] = llm_provider
  end

  seed_llm_models.each do |attributes|
    llm_provider = llm_providers_by_slug.fetch(attributes.fetch(:provider_slug))
    llm_model = LlmModel.find_or_initialize_by(
      llm_provider: llm_provider,
      identifier: attributes.fetch(:identifier)
    )

    llm_model.update!(attributes.except(:provider_slug, :identifier).merge(identifier: attributes.fetch(:identifier)))
  end

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
          personal_details: resume_definition.fetch(:personal_details, {}),
          settings: resume_definition.fetch(:settings),
          template: template
        )
        resume.save!

        seed_photo_library_for_resume.call(
          user: user,
          resume: resume,
          photo_seed: resume_definition.fetch(:photo_seed, nil)
        )

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

    demo_admin = User.find_by(email_address: "admin@resume-builder.local")
    sample_error_log = ErrorLog.find_or_initialize_by(reference_id: "ERR-SEED-0001")
    sample_error_log.assign_attributes(
      source: :request,
      error_class: "StandardError",
      message: "Sample tracked error for the admin dashboard.",
      context: {
        request_id: "seed-request-0001",
        path: "/resumes",
        method: "GET",
        user_id: demo_admin&.id,
        note: "Generated from db/seeds.rb for admin monitoring previews."
      },
      backtrace_lines: [
        "app/controllers/resumes_controller.rb:12:in `index'",
        "app/services/errors/tracker.rb:15:in `capture'"
      ],
      duration_ms: 184,
      occurred_at: Time.current - 2.hours
    )
    sample_error_log.save!

    seed_template_artifacts = [
      {
        template_slug: "modern",
        artifacts: [
          {
            artifact_type: "reference_design",
            name: "Modern template baseline v1",
            description: "Initial reference design for the Modern template family. Bold headings with balanced spacing optimized for product and tech resumes.",
            content: "",
            metadata: {
              "pixel_status" => "close",
              "reference_source_url" => "",
              "design_principles" => [ "bold_headings", "balanced_spacing", "card_shell", "marker_sections" ],
              "target_page_count" => 2
            },
            version_label: "v1.0"
          },
          {
            artifact_type: "layout_spec",
            name: "Modern layout specification",
            description: "Defines the canonical layout rules for the Modern family.",
            content: "## Modern Layout Spec\n\n- Shell: card with rounded-[2rem] corners, shadow-sm\n- Header: split layout with name/headline left, contact pills right\n- Section headings: marker style with accent dot + bold title\n- Skills: chip pills with border\n- Entries: card style with rounded-2xl border\n- Font scale: base\n- Density: comfortable\n- Column count: single\n- Theme tone: slate\n- Accent: #0F172A (near-black slate)",
            metadata: {
              "shell_style" => "card",
              "header_style" => "split",
              "section_heading_style" => "marker",
              "skill_style" => "chips",
              "entry_style" => "cards"
            },
            version_label: "v1.0"
          },
          {
            artifact_type: "discrepancy_report",
            name: "Modern template audit – initial",
            description: "Discrepancies identified between current renderer and ideal design for the Modern template.",
            content: "## Modern Template Discrepancy Report\n\nAudit date: 2026-03-21\n\n### Summary\nThe Modern template is the closest to its reference design. Minor spacing and typography adjustments remain.\n\n### Discrepancies\n\n1. **Contact pill wrapping at narrow widths** – On mobile, contact pills stack vertically but lose their balanced spacing. Expected: consistent 8px gap. Actual: variable gap when wrapping.\n\n2. **Section marker dot alignment** – The accent dot marker is vertically centered but should sit on the text baseline for optical alignment with the section title.\n\n3. **Entry card shadow depth** – Entry cards use no shadow, relying only on border. Reference design shows a subtle shadow-sm for lifted card feel.\n\n4. **Summary paragraph line-height** – Current leading-7 produces slightly loose spacing. Reference uses leading-6 for tighter professional feel.\n\n5. **Page break behavior** – No explicit page-break-inside avoidance on entry cards, causing mid-entry splits in PDF export.",
            metadata: {
              "pixel_status" => "close",
              "discrepancies" => [
                { "id" => "MOD-001", "area" => "contact_pills", "severity" => "minor", "status" => "open" },
                { "id" => "MOD-002", "area" => "section_marker", "severity" => "minor", "status" => "open" },
                { "id" => "MOD-003", "area" => "entry_card_shadow", "severity" => "minor", "status" => "open" },
                { "id" => "MOD-004", "area" => "summary_line_height", "severity" => "minor", "status" => "open" },
                { "id" => "MOD-005", "area" => "page_break", "severity" => "major", "status" => "open" }
              ],
              "open_count" => 5,
              "resolved_count" => 0
            },
            version_label: "v1.0"
          }
        ]
      },
      {
        template_slug: "classic",
        artifacts: [
          {
            artifact_type: "reference_design",
            name: "Classic template baseline v1",
            description: "Traditional ATS-friendly layout with compact density, rule-based section headings, and inline skills.",
            content: "",
            metadata: {
              "pixel_status" => "close",
              "design_principles" => [ "traditional_hierarchy", "compact_density", "ats_friendly", "rule_headings" ],
              "target_page_count" => 2
            },
            version_label: "v1.0"
          },
          {
            artifact_type: "discrepancy_report",
            name: "Classic template audit – initial",
            description: "Discrepancies identified between current renderer and ideal design for the Classic template.",
            content: "## Classic Template Discrepancy Report\n\nAudit date: 2026-03-21\n\n### Summary\nThe Classic template closely matches its reference. Key issues are around header weight and ATS-safe font rendering.\n\n### Discrepancies\n\n1. **Header border weight** – Uses border-b-2 with accent color. Reference shows a 3px rule for stronger visual anchoring at the top.\n\n2. **Contact separator character** – Uses ' · ' (middle dot). Reference uses ' | ' (pipe) for stronger ATS parsing compatibility.\n\n3. **Section title tracking** – tracking-[0.18em] uppercase produces slightly wide letter spacing. Reference uses tracking-[0.12em] for tighter professional feel.\n\n4. **Highlight list markers** – Uses standard disc markers. Reference shows custom square markers for visual distinction.\n\n5. **Font weight on entry titles** – font-semibold used uniformly. Reference shows font-bold on entry titles for stronger hierarchy against meta text.",
            metadata: {
              "pixel_status" => "close",
              "discrepancies" => [
                { "id" => "CLS-001", "area" => "header_border", "severity" => "minor", "status" => "open" },
                { "id" => "CLS-002", "area" => "contact_separator", "severity" => "minor", "status" => "open" },
                { "id" => "CLS-003", "area" => "section_tracking", "severity" => "minor", "status" => "open" },
                { "id" => "CLS-004", "area" => "list_markers", "severity" => "minor", "status" => "open" },
                { "id" => "CLS-005", "area" => "entry_title_weight", "severity" => "minor", "status" => "open" }
              ],
              "open_count" => 5,
              "resolved_count" => 0
            },
            version_label: "v1.0"
          }
        ]
      },
      {
        template_slug: "ats-minimal",
        artifacts: [
          {
            artifact_type: "reference_design",
            name: "ATS Minimal template baseline v1",
            description: "Stripped-down layout tuned for maximum ATS compatibility and dense professional histories.",
            content: "",
            metadata: {
              "pixel_status" => "close",
              "design_principles" => [ "maximum_ats_compatibility", "minimal_chrome", "dense_content", "rule_headings" ],
              "target_page_count" => 2
            },
            version_label: "v1.0"
          },
          {
            artifact_type: "discrepancy_report",
            name: "ATS Minimal template audit – initial",
            description: "Discrepancies identified for the ATS Minimal template.",
            content: "## ATS Minimal Template Discrepancy Report\n\nAudit date: 2026-03-21\n\n### Summary\nThe ATS Minimal template is now pixel perfect. It renders hidden sections correctly, exports to a 4-page PDF within the target range, uses stronger section-heading hierarchy, keeps date ranges aligned in a stable trailing column at tablet-like widths, and now has clearly visible accent rules on the white page surface.\n\n### Open discrepancies\n\nNo open discrepancies remain.\n\n### Resolved discrepancies\n\n1. **Accent color visibility** – Header and section rules now use stronger line weight and opacity, restoring visible accent structure on white surfaces.\n\n2. **Heading hierarchy contrast** – Section headings now render larger and darker than entry titles, restoring clearer scan order.\n\n3. **Date range alignment** – Entry headers now reserve a dedicated trailing date column and keep the date range on one line, preventing wrap at tablet-like widths.\n\n4. **Inline skill separator** – ATS-safe `|` separators already render in the current template, so the earlier open report is now stale.\n\n5. **PDF character encoding** – Bullet characters were replaced with safer `|` separators in inline skill rendering.",
            metadata: {
              "pixel_status" => "pixel_perfect",
              "discrepancies" => [
                { "id" => "ATS-001", "area" => "accent_visibility", "severity" => "minor", "status" => "resolved" },
                { "id" => "ATS-002", "area" => "heading_hierarchy", "severity" => "moderate", "status" => "resolved" },
                { "id" => "ATS-003", "area" => "skill_separator", "severity" => "minor", "status" => "resolved" },
                { "id" => "ATS-004", "area" => "date_alignment", "severity" => "moderate", "status" => "resolved" },
                { "id" => "ATS-005", "area" => "pdf_encoding", "severity" => "major", "status" => "resolved" }
              ],
              "open_count" => 0,
              "resolved_count" => 5
            },
            version_label: "v1.0"
          }
        ]
      },
      {
        template_slug: "professional",
        artifacts: [
          {
            artifact_type: "reference_design",
            name: "Professional template baseline v1",
            description: "Balanced structure with conservative hierarchy for operations, management, and consulting resumes.",
            content: "",
            metadata: {
              "pixel_status" => "close",
              "design_principles" => [ "conservative_hierarchy", "balanced_structure", "professional_tone", "split_header" ],
              "target_page_count" => 2
            },
            version_label: "v1.0"
          },
          {
            artifact_type: "discrepancy_report",
            name: "Professional template audit – initial",
            description: "Discrepancies identified for the Professional template.",
            content: "## Professional Template Discrepancy Report\n\nAudit date: 2026-03-21\n\n### Summary\nThe Professional template is stable but shares too much visual DNA with Classic, reducing its distinct identity.\n\n### Discrepancies\n\n1. **Visual differentiation from Classic** – Both use rule-based headings and inline skills. Professional should have distinct section treatment to justify being a separate family.\n\n2. **Header split balance** – Contact pills in the right column sometimes exceed the max-w-xs constraint, causing asymmetric header layout.\n\n3. **Summary placement** – Summary sits inside the header block. Reference shows it as a standalone section below the header rule for cleaner separation.\n\n4. **Entry spacing consistency** – Comfortable density entry spacing is slightly too generous for consulting/management resumes that typically need more entries per page.\n\n5. **Accent color application** – #0F4C81 blue accent is only applied to the name. Reference shows accent on section heading rules as well for visual threading.",
            metadata: {
              "pixel_status" => "close",
              "discrepancies" => [
                { "id" => "PRO-001", "area" => "visual_identity", "severity" => "moderate", "status" => "open" },
                { "id" => "PRO-002", "area" => "header_balance", "severity" => "minor", "status" => "open" },
                { "id" => "PRO-003", "area" => "summary_placement", "severity" => "moderate", "status" => "open" },
                { "id" => "PRO-004", "area" => "entry_spacing", "severity" => "minor", "status" => "open" },
                { "id" => "PRO-005", "area" => "accent_threading", "severity" => "minor", "status" => "open" }
              ],
              "open_count" => 5,
              "resolved_count" => 0
            },
            version_label: "v1.0"
          }
        ]
      },
      {
        template_slug: "modern-clean",
        artifacts: [
          {
            artifact_type: "reference_design",
            name: "Modern Clean template baseline v1",
            description: "Spacious contemporary cards with lighter chrome for product, design, and tech profiles.",
            content: "",
            metadata: {
              "pixel_status" => "close",
              "design_principles" => [ "spacious_layout", "lighter_chrome", "card_entries", "chip_skills" ],
              "target_page_count" => 3
            },
            version_label: "v1.0"
          },
          {
            artifact_type: "discrepancy_report",
            name: "Modern Clean template audit – initial",
            description: "Discrepancies identified for the Modern Clean template.",
            content: "## Modern Clean Template Discrepancy Report\n\nAudit date: 2026-03-21\n\n### Summary\nModern Clean has the most generous spacing but risks excessive whitespace with sparse content. Rich content fills well.\n\n### Discrepancies\n\n1. **Relaxed density page overflow** – With 5+ experience entries and projects, relaxed density pushes content to 4+ pages. Need intelligent density auto-adjustment or explicit page-count guidance.\n\n2. **Card entry border radius** – Uses rounded-2xl (1rem). Reference shows rounded-xl (0.75rem) for slightly tighter card feel at relaxed density.\n\n3. **Skill chip padding** – Chips at relaxed density have px-4 py-2 which is generous. Reference shows px-3 py-1.5 even at relaxed density.\n\n4. **Section heading rule color** – Uses accent_color with 33% alpha. Reference shows 20% alpha for more subtle separation.\n\n5. **Empty section handling** – Sections with zero entries still render the heading. Should suppress empty sections entirely.\n\n6. **Teal accent contrast** – #0F766E teal on white meets WCAG AA but barely. Consider darkening to #0D6B63 for stronger contrast.",
            metadata: {
              "pixel_status" => "in_progress",
              "discrepancies" => [
                { "id" => "MCL-001", "area" => "density_overflow", "severity" => "major", "status" => "open" },
                { "id" => "MCL-002", "area" => "card_border_radius", "severity" => "minor", "status" => "open" },
                { "id" => "MCL-003", "area" => "chip_padding", "severity" => "minor", "status" => "open" },
                { "id" => "MCL-004", "area" => "heading_rule_alpha", "severity" => "minor", "status" => "open" },
                { "id" => "MCL-005", "area" => "empty_sections", "severity" => "moderate", "status" => "open" },
                { "id" => "MCL-006", "area" => "accent_contrast", "severity" => "moderate", "status" => "open" }
              ],
              "open_count" => 6,
              "resolved_count" => 0
            },
            version_label: "v1.0"
          }
        ]
      },
      {
        template_slug: "sidebar-accent",
        artifacts: [
          {
            artifact_type: "reference_design",
            name: "Sidebar Accent template baseline v1",
            description: "Two-column layout with tinted sidebar for skills and education, main column for experience.",
            content: "",
            metadata: {
              "pixel_status" => "close",
              "design_principles" => [ "two_column", "tinted_sidebar", "section_separation", "chip_skills" ],
              "target_page_count" => 2
            },
            version_label: "v1.0"
          },
          {
            artifact_type: "discrepancy_report",
            name: "Sidebar Accent template audit – initial",
            description: "Discrepancies identified for the Sidebar Accent template.",
            content: "## Sidebar Accent Template Discrepancy Report\n\nAudit date: 2026-03-21\n\n### Summary\nThe Sidebar Accent template now matches the intended desktop column balance and mobile reading order. The main content keeps priority on mobile and the desktop sidebar renders at ~27.8% width, leaving more room for experience content. Four minor polish discrepancies remain in the sidebar surface styling.\n\n### Open discrepancies\n\n1. **Sidebar tint opacity** – Uses accent_color with 10% alpha. On lighter indigo accents this is barely visible. Consider 15% minimum.\n\n2. **Profile section card treatment** – Profile/summary has a distinct card with border and tinted background. This card has inconsistent border-radius when compared to entry cards.\n\n3. **Sidebar skill chips white background** – Skill chips in sidebar use white background which creates high contrast against the tinted sidebar. Reference shows transparent/matching background.\n\n4. **Contact section in sidebar** – Contact labels use font-semibold which is heavier than needed for the sidebar context. Reference shows font-medium.\n\n### Resolved discrepancies\n\n1. **Sidebar width ratio** – Desktop layout now uses a dedicated `sidebar-accent-layout` split with `minmax(0, 1fr) minmax(0, 2.6fr)`, which lands the sidebar at ~27.8% width and gives the main column more room.\n\n2. **Mobile column collapse** – Main content stays first in the DOM while the sidebar reorders back to the left on desktop, preserving the intended mobile reading order.",
            metadata: {
              "pixel_status" => "close",
              "discrepancies" => [
                { "id" => "SAC-001", "area" => "sidebar_width", "severity" => "moderate", "status" => "resolved" },
                { "id" => "SAC-002", "area" => "mobile_order", "severity" => "major", "status" => "resolved" },
                { "id" => "SAC-003", "area" => "sidebar_tint", "severity" => "minor", "status" => "open" },
                { "id" => "SAC-004", "area" => "profile_card_radius", "severity" => "minor", "status" => "open" },
                { "id" => "SAC-005", "area" => "skill_chip_bg", "severity" => "minor", "status" => "open" },
                { "id" => "SAC-006", "area" => "contact_weight", "severity" => "minor", "status" => "open" }
              ],
              "open_count" => 4,
              "resolved_count" => 2
            },
            version_label: "v1.0"
          }
        ]
      },
      {
        template_slug: "editorial-split",
        artifacts: [
          {
            artifact_type: "reference_design",
            name: "Editorial Split template baseline v1",
            description: "Asymmetric editorial layout with narrow supporting column, stretched name band, and utility rail. Inspired by Reuix Studio Behance project.",
            content: "",
            metadata: {
              "pixel_status" => "close",
              "reference_source_url" => "https://www.behance.net/gallery/245736819/Resume-Cv-Template",
              "design_principles" => [ "asymmetric_editorial", "utility_rail", "identity_tile", "lime_accent" ],
              "target_page_count" => 2
            },
            version_label: "v1.0"
          },
          {
            artifact_type: "discrepancy_report",
            name: "Editorial Split template audit – initial",
            description: "Discrepancies between current editorial-split renderer and the original Behance reference.",
            content: "## Editorial Split Template Discrepancy Report\n\nAudit date: 2026-03-21\nBehance reference: https://www.behance.net/gallery/245736819/Resume-Cv-Template\n\n### Summary\nThe editorial-split template was implemented from a Behance reference and is the closest to pixel-perfect among all templates. Remaining gaps are mostly in the utility rail and identity tile details.\n\n### Discrepancies\n\n1. **Identity tile photo overlay** – When headshot is attached, the right-side accent color overlay uses bg-slate-950/30. Reference shows a gradient from transparent to dark, not a flat overlay.\n\n2. **Utility rail badge sizing** – Current badges are h-16 w-16 with text-base labels. Reference shows slightly larger badges (h-18 w-18) with bolder type.\n\n3. **Name band letter-spacing** – Accent name uses tracking-[0.45em]. Reference appears to use closer to tracking-[0.35em] for tighter editorial feel.\n\n4. **Sidebar section heading color** – Uses accent_color (#D7F038 lime). On the light sidebar background, lime-on-white has low contrast. Reference shows the headings in a darker variant.\n\n5. **Main column entry divider** – Uses border-t border-slate-100. Reference shows a thicker accent-colored rule (2px) between experience entries.\n\n6. **Contact badge circle border** – Rail contact badges use border-slate-300. Reference uses a slightly darker border for better definition.\n\n7. **Mobile utility badge layout** – Mobile badges wrap as flex-wrap. Reference shows them in a horizontal scroll rail on mobile.",
            metadata: {
              "pixel_status" => "close",
              "reference_source_url" => "https://www.behance.net/gallery/245736819/Resume-Cv-Template",
              "discrepancies" => [
                { "id" => "EDT-001", "area" => "photo_overlay", "severity" => "moderate", "status" => "open" },
                { "id" => "EDT-002", "area" => "utility_badge_size", "severity" => "minor", "status" => "open" },
                { "id" => "EDT-003", "area" => "name_tracking", "severity" => "minor", "status" => "open" },
                { "id" => "EDT-004", "area" => "sidebar_heading_contrast", "severity" => "moderate", "status" => "open" },
                { "id" => "EDT-005", "area" => "entry_divider", "severity" => "minor", "status" => "open" },
                { "id" => "EDT-006", "area" => "contact_badge_border", "severity" => "minor", "status" => "open" },
                { "id" => "EDT-007", "area" => "mobile_badge_layout", "severity" => "minor", "status" => "open" }
              ],
              "open_count" => 7,
              "resolved_count" => 0
            },
            version_label: "v1.0"
          }
        ]
      }
    ]

    seed_template_artifacts.each do |family_def|
      template = Template.find_by(slug: family_def.fetch(:template_slug))
      next unless template

      reference_artifact = nil

      family_def.fetch(:artifacts).each do |artifact_attrs|
        artifact = template.template_artifacts.find_or_initialize_by(
          artifact_type: artifact_attrs.fetch(:artifact_type),
          name: artifact_attrs.fetch(:name)
        )
        artifact.assign_attributes(
          description: artifact_attrs.fetch(:description),
          content: artifact_attrs.fetch(:content),
          metadata: artifact_attrs.fetch(:metadata),
          version_label: artifact_attrs.fetch(:version_label),
          status: "active"
        )
        artifact.parent_artifact = reference_artifact if reference_artifact.present? && artifact.artifact_type != "reference_design"
        artifact.save!
        reference_artifact ||= artifact if artifact.artifact_type == "reference_design"
      end

      reference_artifact ||= template.template_artifacts.reference_designs.active.order(:created_at).first
      discrepancy_artifact = template.template_artifacts.discrepancy_reports.active.order(updated_at: :desc).first
      discrepancy_items = Array(discrepancy_artifact&.metadata&.fetch("discrepancies", []))
      open_count = discrepancy_items.count { |item| item["status"] != "resolved" }
      resolved_count = discrepancy_items.count { |item| item["status"] == "resolved" }
      pixel_status = discrepancy_artifact&.pixel_status || reference_artifact&.pixel_status || "not_started"
      implementation_status = case pixel_status
      when "pixel_perfect"
        "seeded"
      when "close"
        "stable"
      when "in_progress"
        "validated"
      else
        "draft"
      end

      decision_artifact = template.template_artifacts.find_or_initialize_by(
        artifact_type: "decision_log",
        name: "#{template.name} baseline implementation decision"
      )
      decision_artifact.assign_attributes(
        description: "Tracks the current implementation lifecycle state for the template baseline.",
        content: "Implementation status: #{implementation_status}\nPixel status: #{pixel_status}\nOpen discrepancies: #{open_count}\nResolved discrepancies: #{resolved_count}",
        metadata: {
          "implementation_status" => implementation_status,
          "pixel_status" => pixel_status,
          "open_discrepancy_count" => open_count,
          "resolved_discrepancy_count" => resolved_count,
          "source_artifact_identifier" => reference_artifact&.identifier,
          "source_url" => reference_artifact&.reference_source_url
        },
        version_label: "v1.0",
        status: "active",
        parent_artifact: reference_artifact
      )
      decision_artifact.save!

      implementation = template.template_implementations.find_or_initialize_by(identifier: "#{template.slug}-baseline")
      implementation.assign_attributes(
        source_artifact: reference_artifact,
        name: "#{template.name} baseline implementation",
        status: implementation_status,
        renderer_family: template.layout_family,
        render_profile: template.normalized_layout_config,
        notes: "Baseline implementation seeded from stored artifacts and current renderer configuration.",
        metadata: {
          "pixel_status" => pixel_status,
          "open_discrepancy_count" => open_count,
          "resolved_discrepancy_count" => resolved_count,
          "decision_artifact_identifier" => decision_artifact.identifier
        },
        validated_at: (%w[validated stable seeded].include?(implementation_status) ? Time.current : nil),
        seeded_at: (implementation_status == "seeded" ? Time.current : nil)
      )
      implementation.save!

      seed_snapshot = template.template_artifacts.find_or_initialize_by(
        artifact_type: "seed_snapshot",
        version_label: "#{implementation.identifier}-seeded"
      )

      if implementation.seeded?
        seed_snapshot.assign_attributes(
          name: implementation.name,
          description: "Seeded implementation snapshot.",
          content: JSON.pretty_generate(implementation.effective_render_profile),
          metadata: {
            "artifact_role" => "seeded_implementation_snapshot",
            "seed_mode" => "db_seed_baseline",
            "template_implementation_id" => implementation.id,
            "template_implementation_identifier" => implementation.identifier,
            "source_artifact_identifier" => reference_artifact&.identifier,
            "status" => implementation.status,
            "seeded_at" => implementation.seeded_at&.iso8601,
            "created_at" => Time.current.iso8601
          }.compact,
          status: "active",
          parent_artifact: reference_artifact
        )
        seed_snapshot.save!
      elsif seed_snapshot.persisted?
        seed_snapshot.update!(status: "superseded")
      end

      validation_run = template.template_validation_runs.find_or_initialize_by(identifier: "#{template.slug}-baseline-manual-review")
      validation_run.assign_attributes(
        template_implementation: implementation,
        reference_artifact: reference_artifact,
        validation_type: "manual_review",
        status: open_count.zero? ? "passed" : "needs_review",
        validator_name: "db/seeds.rb",
        notes: "Baseline seeded validation summary for the current template implementation.",
        metrics: {
          "pixel_status" => pixel_status,
          "open_discrepancy_count" => open_count,
          "resolved_discrepancy_count" => resolved_count,
          "target_page_count" => reference_artifact&.metadata&.fetch("target_page_count", nil)
        },
        metadata: {
          "source_artifact_identifier" => reference_artifact&.identifier,
          "source_url" => reference_artifact&.reference_source_url,
          "decision_artifact_identifier" => decision_artifact.identifier
        },
        validated_at: Time.current
      )
      validation_run.save!
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

  # --- Template audit profiles ---
  # Creates diverse resumes across every template for pixel-perfect auditing.
  # Each profile × template combination produces a 3–5 page resume.
  audit_email = "template-audit@resume-builder.local"
  audit_password = "password123!"
  audit_user = User.find_or_initialize_by(email_address: audit_email)
  audit_user.assign_attributes(role: :user, password: audit_password, password_confirmation: audit_password)
  audit_user.save!

  audit_random = Random.new(20260321)
  Faker::Config.random = audit_random
  Faker::UniqueGenerator.clear

  audit_city_and_state = -> { "#{Faker::Address.city}, #{Faker::Address.state_abbr}" }
  audit_sentence = ->(word_count: 10) { Faker::Lorem.sentence(word_count:) }
  audit_paragraph = ->(sentence_count: 3) { Faker::Lorem.paragraph(sentence_count:) }

  build_audit_resume = lambda do |profile:, template_slug:, mode:|
    template = Template.find_by(slug: template_slug)
    return unless template

    slug = "audit-#{profile.fetch(:key)}-#{template_slug}-#{mode}"
    resume = audit_user.resumes.find_or_initialize_by(slug: slug)

    full_name = Faker::Name.name
    full_name_slug = full_name.parameterize
    hometown = audit_city_and_state.call
    website = "https://#{Faker::Internet.domain_name}"
    sections_enabled = Resumes::SeedProfileCatalog.sections_for(profile, mode: mode.to_sym)
    hidden_sections = (profile.fetch(:sections_enabled) - sections_enabled)

    resume.assign_attributes(
      title: "#{full_name} – #{profile.fetch(:label)} (#{template.name}, #{mode})",
      headline: "#{profile.fetch(:primary_title)} | #{profile.fetch(:focus)} | #{profile.fetch(:industry)}",
      summary: (1..profile.fetch(:summary_sentences, 3)).map { audit_paragraph.call(sentence_count: 2) }.join(" "),
      contact_details: {
        "full_name" => full_name,
        "email" => "#{full_name_slug}@example.com",
        "phone" => Faker::PhoneNumber.phone_number,
        "location" => hometown,
        "website" => website,
        "linkedin" => "linkedin.com/in/#{full_name_slug.delete("-")}",
        "driving_licence" => profile.fetch(:driving_licence, "")
      },
      personal_details: profile.fetch(:personal_details, {}),
      settings: {
        "accent_color" => template.normalized_layout_config.fetch("accent_color"),
        "show_contact_icons" => true,
        "page_size" => "A4",
        "hidden_sections" => hidden_sections
      },
      template: template
    )
    resume.save!

    resume.sections.destroy_all

    section_position = 0

    # Experience — 8 entries for high density
    if sections_enabled.include?("experience")
      titles = [
        profile.fetch(:primary_title), profile.fetch(:secondary_title),
        profile.fetch(:third_title), profile.fetch(:fourth_title),
        profile.fetch(:fifth_title), profile.fetch(:sixth_title, "Consultant"),
        profile.fetch(:seventh_title, "Advisor"), profile.fetch(:eighth_title, "Intern")
      ]
      experience_section = resume.sections.create!(title: "Experience", section_type: "experience", position: section_position)
      section_position += 1

      base_year = 2025
      titles.each_with_index do |title, idx|
        start_year = base_year - (idx * 2) - 2
        end_year = idx == 0 ? "Present" : (base_year - (idx * 2)).to_s
        highlight_count = profile.fetch(:highlight_density) == :high ? Faker::Number.between(from: 3, to: 5) : 2
        experience_section.entries.create!(
          position: idx,
          content: {
            "title" => title,
            "organization" => Faker::Company.name,
            "location" => audit_city_and_state.call,
            "start_date" => start_year.to_s,
            "end_date" => end_year,
            "summary" => audit_paragraph.call(sentence_count: 3),
            "highlights" => (1..highlight_count).map { audit_sentence.call(word_count: Faker::Number.between(from: 10, to: 16)) }
          }
        )
      end
    end

    # Education
    if sections_enabled.include?("education")
      education_section = resume.sections.create!(title: "Education", section_type: "education", position: section_position)
      section_position += 1

      profile.fetch(:education, []).each_with_index do |edu, idx|
        grad_year = Faker::Number.between(from: 2008, to: 2016) - (idx * 3)
        education_section.entries.create!(
          position: idx,
          content: {
            "institution" => "#{Faker::Address.city} #{edu.fetch(:institution_suffix)}",
            "degree" => edu.fetch(:degree),
            "location" => audit_city_and_state.call,
            "start_date" => (grad_year - (edu.fetch(:degree).start_with?("Ph.D") ? 5 : edu.fetch(:degree).start_with?("J.D", "Ed.D", "M.") ? 2 : 4)).to_s,
            "end_date" => grad_year.to_s,
            "details" => "Focused on #{edu.fetch(:details_focus)}. #{audit_sentence.call(word_count: 12)} #{audit_sentence.call(word_count: 10)}"
          }
        )
      end
    end

    # Skills
    if sections_enabled.include?("skills")
      skills_section = resume.sections.create!(title: "Skills", section_type: "skills", position: section_position)
      section_position += 1

      skill_levels = [ "Expert", "Advanced", "Advanced", "Proficient" ]
      profile.fetch(:skills, []).each_with_index do |skill_name, idx|
        skills_section.entries.create!(
          position: idx,
          content: { "name" => skill_name, "level" => skill_levels[idx % skill_levels.size] }
        )
      end
    end

    # Projects
    if sections_enabled.include?("projects")
      projects_section = resume.sections.create!(title: "Projects", section_type: "projects", position: section_position)
      section_position += 1

      [
        { name: profile.fetch(:project_name), role: profile.fetch(:project_role) },
        { name: profile.fetch(:second_project_name), role: profile.fetch(:second_project_role) },
        { name: profile.fetch(:third_project_name), role: profile.fetch(:third_project_role) }
      ].each_with_index do |proj, idx|
        projects_section.entries.create!(
          position: idx,
          content: {
            "name" => proj.fetch(:name),
            "role" => proj.fetch(:role),
            "url" => "#{website}/#{proj.fetch(:name).parameterize}",
            "summary" => audit_paragraph.call(sentence_count: 3),
            "highlights" => (1..3).map { audit_sentence.call(word_count: Faker::Number.between(from: 10, to: 14)) }
          }
        )
      end
    end

    # Certifications
    if sections_enabled.include?("certifications")
      certs_section = resume.sections.create!(title: "Certifications", section_type: "certifications", position: section_position)
      section_position += 1

      profile.fetch(:certifications, []).each_with_index do |cert, idx|
        certs_section.entries.create!(
          position: idx,
          content: {
            "name" => cert.fetch(:name),
            "organization" => cert.fetch(:issuer),
            "start_date" => cert.fetch(:year),
            "details" => cert.fetch(:details, "")
          }
        )
      end
    end

    # Languages
    if sections_enabled.include?("languages")
      lang_section = resume.sections.create!(title: "Languages", section_type: "languages", position: section_position)

      profile.fetch(:languages, []).each_with_index do |lang, idx|
        lang_section.entries.create!(
          position: idx,
          content: { "name" => lang.fetch(:name), "level" => lang.fetch(:level) }
        )
      end
    end

    resume
  end

  template_slugs = seed_templates.map { |t| t.fetch(:slug) }
  profiles = Resumes::SeedProfileCatalog.all

  profiles.each do |profile|
    template_slugs.each do |template_slug|
      build_audit_resume.call(profile: profile, template_slug: template_slug, mode: "full")
      build_audit_resume.call(profile: profile, template_slug: template_slug, mode: "minimal")
    end
  end

  audit_resume_count = audit_user.resumes.count
  puts "- Template Audit: #{audit_email} / #{audit_password} (#{audit_resume_count} audit resumes)"
end
