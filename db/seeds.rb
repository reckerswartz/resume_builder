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
  skill_level = -> { ["Expert", "Advanced", "Advanced"].sample(random: seed_random) }

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
    project_role:, skills:, driving_licence:, personal_details:, photo_seed:|
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
    secondary_title:, focus:, project_name:, project_role:, skills:, driving_licence:, personal_details:,
    photo_seed:|
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
          photo_seed:
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
      skills: ["Ruby on Rails", "Hotwire", "Product Leadership"],
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
      skills: ["Product Design", "Design Systems", "User Research"],
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
      skills: ["Product Design", "Design Systems", "Art Direction"],
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
