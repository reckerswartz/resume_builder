module Resumes
  class SeedProfileCatalog
    PROFILES = [
      {
        key: "senior-engineer",
        label: "Senior Software Engineer",
        primary_title: "Senior Software Engineer",
        secondary_title: "Software Engineer",
        third_title: "Technical Lead",
        fourth_title: "Junior Developer",
        fifth_title: "Engineering Intern",
        sixth_title: "Research Assistant",
        seventh_title: "Open Source Contributor",
        eighth_title: "Freelance Developer",
        focus: "Full-Stack Development",
        industry: "Technology",
        career_years: 14,
        project_name: "Cloud Migration Platform",
        project_role: "Architect",
        second_project_name: "Real-Time Analytics Engine",
        second_project_role: "Tech Lead",
        third_project_name: "Developer Portal",
        third_project_role: "Core Contributor",
        skills: [
          "Ruby on Rails", "PostgreSQL", "Redis", "Docker", "Kubernetes",
          "AWS", "Terraform", "GraphQL", "React", "TypeScript",
          "CI/CD Pipelines", "System Design", "Microservices", "Event Sourcing", "gRPC"
        ],
        certifications: [
          { name: "AWS Solutions Architect Professional", issuer: "Amazon Web Services", year: "2024", details: "Advanced cloud architecture patterns, multi-account strategies, and cost optimization." },
          { name: "Certified Kubernetes Administrator (CKA)", issuer: "CNCF", year: "2023", details: "Production-grade Kubernetes cluster administration and troubleshooting." },
          { name: "HashiCorp Terraform Associate", issuer: "HashiCorp", year: "2022", details: "Infrastructure as code workflows and multi-cloud provisioning." },
          { name: "Google Cloud Professional Data Engineer", issuer: "Google Cloud", year: "2021", details: "Data pipeline design, machine learning integration, and BigQuery optimization." }
        ],
        languages: [
          { name: "English", level: "Native" },
          { name: "Mandarin", level: "Professional" },
          { name: "Japanese", level: "Conversational" },
          { name: "Korean", level: "Basic" }
        ],
        driving_licence: "Class B",
        personal_details: {
          "date_of_birth" => "",
          "nationality" => "United States",
          "marital_status" => "",
          "visa_status" => "U.S. citizen"
        },
        education: [
          { degree: "M.S. Computer Science", institution_suffix: "Institute of Technology", details_focus: "distributed systems and database internals" },
          { degree: "B.S. Computer Science", institution_suffix: "State University", details_focus: "software engineering and algorithms" }
        ],
        summary_sentences: 5,
        highlight_density: :high,
        sections_enabled: %w[experience education skills projects certifications languages]
      },
      {
        key: "design-director",
        label: "Design Director",
        primary_title: "Design Director",
        secondary_title: "Senior Product Designer",
        third_title: "Product Designer",
        fourth_title: "UX Designer",
        fifth_title: "Visual Designer",
        sixth_title: "Design Intern",
        seventh_title: "Freelance Brand Designer",
        eighth_title: "Junior Graphic Designer",
        focus: "Product & Brand Design",
        industry: "Design",
        career_years: 16,
        project_name: "Design System Overhaul",
        project_role: "Design Lead",
        second_project_name: "Brand Identity Refresh",
        second_project_role: "Creative Director",
        third_project_name: "Mobile App Redesign",
        third_project_role: "UX Lead",
        skills: [
          "Product Design", "Design Systems", "Brand Strategy", "Art Direction", "Motion Design",
          "Figma", "Sketch", "Adobe Creative Suite", "Prototyping", "User Research",
          "Accessibility", "Typography", "Information Architecture", "Design Ops", "Workshop Facilitation"
        ],
        certifications: [
          { name: "Interaction Design Foundation Certificate", issuer: "IDF", year: "2022", details: "Advanced interaction design patterns and design thinking methodologies." },
          { name: "Adobe Certified Expert – InDesign", issuer: "Adobe", year: "2020", details: "Professional editorial layout and publication design." },
          { name: "Certified Usability Analyst (CUA)", issuer: "Human Factors International", year: "2019", details: "Evidence-based usability evaluation methods and heuristic analysis." }
        ],
        languages: [
          { name: "English", level: "Native" },
          { name: "French", level: "Professional" },
          { name: "Italian", level: "Conversational" },
          { name: "Portuguese", level: "Basic" }
        ],
        driving_licence: "Class C",
        personal_details: {
          "date_of_birth" => "",
          "nationality" => "Canada",
          "marital_status" => "",
          "visa_status" => "Permanent Resident (U.S.)"
        },
        education: [
          { degree: "M.F.A. Interaction Design", institution_suffix: "School of Design", details_focus: "human-centered design and design research" },
          { degree: "B.F.A. Graphic Design", institution_suffix: "College of Art", details_focus: "typography, layout, and visual communication" }
        ],
        summary_sentences: 5,
        highlight_density: :high,
        sections_enabled: %w[experience education skills projects certifications languages]
      },
      {
        key: "healthcare-administrator",
        label: "Healthcare Administrator",
        primary_title: "Director of Operations",
        secondary_title: "Healthcare Program Manager",
        third_title: "Clinical Operations Coordinator",
        fourth_title: "Patient Services Supervisor",
        fifth_title: "Medical Office Manager",
        sixth_title: "Administrative Assistant",
        seventh_title: "Health Policy Research Intern",
        eighth_title: "Volunteer Coordinator",
        focus: "Healthcare Operations",
        industry: "Healthcare",
        career_years: 18,
        project_name: "EHR System Migration",
        project_role: "Project Director",
        second_project_name: "Telehealth Expansion Program",
        second_project_role: "Program Lead",
        third_project_name: "Patient Satisfaction Initiative",
        third_project_role: "Quality Lead",
        skills: [
          "Healthcare Administration", "HIPAA Compliance", "EHR Systems", "Budget Management", "Quality Improvement",
          "Staff Development", "Regulatory Compliance", "Patient Safety", "Strategic Planning", "Change Management",
          "Data Analytics", "Process Improvement", "Vendor Management", "Grant Writing", "Accreditation"
        ],
        certifications: [
          { name: "Fellow of the American College of Healthcare Executives (FACHE)", issuer: "ACHE", year: "2023", details: "Advanced healthcare leadership and strategic management." },
          { name: "Certified Professional in Healthcare Quality (CPHQ)", issuer: "NAHQ", year: "2021", details: "Healthcare quality management, patient safety, and regulatory compliance." },
          { name: "Lean Six Sigma Green Belt – Healthcare", issuer: "ASQ", year: "2020", details: "Process improvement methodologies applied to clinical and operational workflows." },
          { name: "Project Management Professional (PMP)", issuer: "PMI", year: "2019", details: "Project lifecycle management and stakeholder coordination." }
        ],
        languages: [
          { name: "English", level: "Native" },
          { name: "Spanish", level: "Professional" },
          { name: "Tagalog", level: "Conversational" }
        ],
        driving_licence: "Class C",
        personal_details: {
          "date_of_birth" => "",
          "nationality" => "United States",
          "marital_status" => "",
          "visa_status" => "U.S. citizen"
        },
        education: [
          { degree: "M.H.A. Healthcare Administration", institution_suffix: "School of Public Health", details_focus: "healthcare policy, finance, and organizational leadership" },
          { degree: "B.S. Biology", institution_suffix: "University", details_focus: "pre-medical studies and public health foundations" }
        ],
        summary_sentences: 5,
        highlight_density: :high,
        sections_enabled: %w[experience education skills projects certifications languages]
      },
      {
        key: "finance-analyst",
        label: "Senior Financial Analyst",
        primary_title: "Senior Financial Analyst",
        secondary_title: "Financial Analyst",
        third_title: "Investment Banking Associate",
        fourth_title: "Junior Analyst",
        fifth_title: "Accounting Intern",
        sixth_title: "Treasury Assistant",
        seventh_title: "Audit Intern",
        eighth_title: "Research Assistant",
        focus: "Financial Analysis & Strategy",
        industry: "Finance",
        career_years: 12,
        project_name: "M&A Valuation Framework",
        project_role: "Lead Analyst",
        second_project_name: "Treasury Optimization Platform",
        second_project_role: "Project Lead",
        third_project_name: "ESG Reporting Dashboard",
        third_project_role: "Data Lead",
        skills: [
          "Financial Modeling", "Valuation", "M&A Analysis", "Excel / VBA", "Python",
          "SQL", "Bloomberg Terminal", "FactSet", "Risk Management", "Budgeting & Forecasting",
          "GAAP / IFRS", "Tableau", "Power BI", "Regulatory Reporting", "Due Diligence"
        ],
        certifications: [
          { name: "Chartered Financial Analyst (CFA) Level III", issuer: "CFA Institute", year: "2023", details: "Portfolio management, wealth planning, and advanced investment analysis." },
          { name: "Financial Risk Manager (FRM)", issuer: "GARP", year: "2021", details: "Market risk, credit risk, and operational risk measurement and management." },
          { name: "Certified Public Accountant (CPA)", issuer: "AICPA", year: "2019", details: "Financial reporting, auditing standards, and tax regulation compliance." }
        ],
        languages: [
          { name: "English", level: "Native" },
          { name: "German", level: "Professional" },
          { name: "Hindi", level: "Native" },
          { name: "French", level: "Basic" }
        ],
        driving_licence: "Class B",
        personal_details: {
          "date_of_birth" => "",
          "nationality" => "India",
          "marital_status" => "",
          "visa_status" => "H-1B Work Visa"
        },
        education: [
          { degree: "M.B.A. Finance", institution_suffix: "Business School", details_focus: "corporate finance, derivatives, and quantitative methods" },
          { degree: "B.Com. Accounting & Finance", institution_suffix: "University of Commerce", details_focus: "financial accounting, auditing, and business law" }
        ],
        summary_sentences: 5,
        highlight_density: :high,
        sections_enabled: %w[experience education skills projects certifications languages]
      },
      {
        key: "education-specialist",
        label: "Education Program Director",
        primary_title: "Director of Curriculum & Instruction",
        secondary_title: "Lead Curriculum Developer",
        third_title: "Senior Instructional Designer",
        fourth_title: "High School Teacher",
        fifth_title: "Teaching Fellow",
        sixth_title: "Student Teacher",
        seventh_title: "After-School Program Coordinator",
        eighth_title: "Tutoring Center Assistant",
        focus: "Educational Leadership",
        industry: "Education",
        career_years: 15,
        project_name: "STEM Curriculum Redesign",
        project_role: "Program Director",
        second_project_name: "Digital Literacy Initiative",
        second_project_role: "Curriculum Lead",
        third_project_name: "Teacher Professional Development Portal",
        third_project_role: "Content Lead",
        skills: [
          "Curriculum Development", "Instructional Design", "Assessment Design", "Learning Management Systems", "EdTech Integration",
          "Teacher Training", "Data-Driven Instruction", "Differentiated Learning", "Grant Management", "Accreditation",
          "Stakeholder Engagement", "Program Evaluation", "Universal Design for Learning", "FERPA Compliance", "Budget Administration"
        ],
        certifications: [
          { name: "National Board Certification – Generalist", issuer: "NBPTS", year: "2022", details: "Advanced teaching standards and evidence-based instructional practice." },
          { name: "Certified Instructional Designer (CID)", issuer: "ATD", year: "2020", details: "Adult learning theory, blended curriculum design, and assessment alignment." },
          { name: "Google Certified Educator Level 2", issuer: "Google for Education", year: "2019", details: "Advanced Google Workspace integration for classroom instruction." }
        ],
        languages: [
          { name: "English", level: "Native" },
          { name: "Spanish", level: "Professional" },
          { name: "American Sign Language", level: "Conversational" }
        ],
        driving_licence: "Class C",
        personal_details: {
          "date_of_birth" => "",
          "nationality" => "United States",
          "marital_status" => "",
          "visa_status" => "U.S. citizen"
        },
        education: [
          { degree: "Ed.D. Educational Leadership", institution_suffix: "Graduate School of Education", details_focus: "curriculum policy, organizational change, and equity in education" },
          { degree: "M.Ed. Curriculum & Instruction", institution_suffix: "College of Education", details_focus: "instructional strategies and educational technology" },
          { degree: "B.A. English Literature", institution_suffix: "Liberal Arts College", details_focus: "writing pedagogy and literary analysis" }
        ],
        summary_sentences: 5,
        highlight_density: :high,
        sections_enabled: %w[experience education skills projects certifications languages]
      },
      {
        key: "marketing-strategist",
        label: "VP of Marketing",
        primary_title: "VP of Marketing",
        secondary_title: "Senior Marketing Manager",
        third_title: "Marketing Manager",
        fourth_title: "Digital Marketing Specialist",
        fifth_title: "Content Marketing Coordinator",
        sixth_title: "Marketing Intern",
        seventh_title: "Social Media Manager",
        eighth_title: "Brand Ambassador",
        focus: "Growth & Brand Strategy",
        industry: "Marketing",
        career_years: 16,
        project_name: "Global Brand Repositioning",
        project_role: "Strategy Lead",
        second_project_name: "Marketing Automation Platform",
        second_project_role: "Program Owner",
        third_project_name: "Content Studio Launch",
        third_project_role: "Creative Director",
        skills: [
          "Brand Strategy", "Growth Marketing", "Marketing Automation", "SEO / SEM", "Content Strategy",
          "Data Analytics", "A/B Testing", "CRM Management", "Social Media Strategy", "Public Relations",
          "Event Marketing", "Influencer Marketing", "Budget Management", "Team Leadership", "Copywriting"
        ],
        certifications: [
          { name: "HubSpot Inbound Marketing Certification", issuer: "HubSpot Academy", year: "2024", details: "Inbound methodology, content marketing, and lead nurturing strategies." },
          { name: "Google Analytics 4 Certification", issuer: "Google", year: "2023", details: "Web analytics, conversion tracking, and audience segmentation." },
          { name: "Meta Certified Marketing Science Professional", issuer: "Meta", year: "2022", details: "Data-driven advertising optimization and measurement across Meta platforms." },
          { name: "Certified Brand Manager", issuer: "AIBM", year: "2020", details: "Strategic brand development, positioning, and portfolio management." }
        ],
        languages: [
          { name: "English", level: "Native" },
          { name: "Spanish", level: "Native" },
          { name: "Portuguese", level: "Professional" },
          { name: "French", level: "Conversational" }
        ],
        driving_licence: "Class C",
        personal_details: {
          "date_of_birth" => "",
          "nationality" => "Mexico",
          "marital_status" => "",
          "visa_status" => "Permanent Resident (U.S.)"
        },
        education: [
          { degree: "M.B.A. Marketing", institution_suffix: "Business School", details_focus: "consumer behavior, brand management, and digital marketing strategy" },
          { degree: "B.A. Communications", institution_suffix: "University", details_focus: "media studies, public relations, and strategic communication" }
        ],
        summary_sentences: 5,
        highlight_density: :high,
        sections_enabled: %w[experience education skills projects certifications languages]
      },
      {
        key: "data-scientist",
        label: "Principal Data Scientist",
        primary_title: "Principal Data Scientist",
        secondary_title: "Senior Data Scientist",
        third_title: "Machine Learning Engineer",
        fourth_title: "Data Analyst",
        fifth_title: "Research Scientist Intern",
        sixth_title: "Data Engineering Intern",
        seventh_title: "Graduate Research Assistant",
        eighth_title: "Teaching Assistant – Statistics",
        focus: "Machine Learning & AI",
        industry: "Data Science",
        career_years: 13,
        project_name: "Recommendation Engine v3",
        project_role: "ML Lead",
        second_project_name: "Fraud Detection Pipeline",
        second_project_role: "Technical Lead",
        third_project_name: "NLP Document Classification",
        third_project_role: "Research Lead",
        skills: [
          "Python", "R", "TensorFlow", "PyTorch", "Scikit-learn",
          "SQL", "Spark", "Airflow", "MLOps", "A/B Testing",
          "Natural Language Processing", "Computer Vision", "Statistical Modeling", "Deep Learning", "Feature Engineering"
        ],
        certifications: [
          { name: "AWS Machine Learning Specialty", issuer: "Amazon Web Services", year: "2024", details: "ML model deployment, SageMaker pipelines, and production inference optimization." },
          { name: "TensorFlow Developer Certificate", issuer: "Google", year: "2022", details: "Deep learning model architecture, training, and deployment with TensorFlow." },
          { name: "Databricks Certified ML Professional", issuer: "Databricks", year: "2021", details: "Distributed ML training, feature stores, and MLflow lifecycle management." }
        ],
        languages: [
          { name: "English", level: "Native" },
          { name: "Russian", level: "Native" },
          { name: "German", level: "Conversational" }
        ],
        driving_licence: "",
        personal_details: {
          "date_of_birth" => "",
          "nationality" => "Russia",
          "marital_status" => "",
          "visa_status" => "O-1 Extraordinary Ability Visa"
        },
        education: [
          { degree: "Ph.D. Computer Science (Machine Learning)", institution_suffix: "Institute of Technology", details_focus: "deep learning, reinforcement learning, and probabilistic graphical models" },
          { degree: "M.S. Applied Mathematics", institution_suffix: "University", details_focus: "optimization, stochastic processes, and numerical methods" },
          { degree: "B.S. Mathematics", institution_suffix: "State University", details_focus: "pure mathematics and theoretical computer science" }
        ],
        summary_sentences: 5,
        highlight_density: :high,
        sections_enabled: %w[experience education skills projects certifications languages]
      },
      {
        key: "legal-counsel",
        label: "Senior Corporate Counsel",
        primary_title: "Senior Corporate Counsel",
        secondary_title: "Corporate Counsel",
        third_title: "Associate Attorney",
        fourth_title: "Legal Associate",
        fifth_title: "Law Clerk",
        sixth_title: "Legal Intern",
        seventh_title: "Paralegal",
        eighth_title: "Legal Research Assistant",
        focus: "Corporate & Technology Law",
        industry: "Legal",
        career_years: 14,
        project_name: "Global Data Privacy Program",
        project_role: "Lead Counsel",
        second_project_name: "IP Portfolio Consolidation",
        second_project_role: "Project Lead",
        third_project_name: "Regulatory Compliance Framework",
        third_project_role: "Compliance Lead",
        skills: [
          "Corporate Law", "M&A Transactions", "Contract Negotiation", "Data Privacy (GDPR/CCPA)", "Intellectual Property",
          "Regulatory Compliance", "Securities Law", "Employment Law", "Legal Research", "Risk Assessment",
          "Litigation Management", "Legal Operations", "eDiscovery", "Board Governance", "Policy Drafting"
        ],
        certifications: [
          { name: "Certified Information Privacy Professional (CIPP/US)", issuer: "IAPP", year: "2023", details: "U.S. privacy law, regulatory frameworks, and compliance strategies." },
          { name: "Certified Information Privacy Manager (CIPM)", issuer: "IAPP", year: "2022", details: "Privacy program governance, risk assessment, and cross-border data transfer." },
          { name: "Licensed Attorney – State Bar of California", issuer: "State Bar of California", year: "2014", details: "Active bar membership with good standing." }
        ],
        languages: [
          { name: "English", level: "Native" },
          { name: "Mandarin", level: "Professional" },
          { name: "French", level: "Conversational" },
          { name: "Arabic", level: "Basic" }
        ],
        driving_licence: "Class C",
        personal_details: {
          "date_of_birth" => "",
          "nationality" => "United States",
          "marital_status" => "",
          "visa_status" => "U.S. citizen"
        },
        education: [
          { degree: "J.D. Law", institution_suffix: "School of Law", details_focus: "corporate transactions, intellectual property, and technology law" },
          { degree: "B.A. Political Science", institution_suffix: "University", details_focus: "constitutional law, public policy, and international relations" }
        ],
        summary_sentences: 5,
        highlight_density: :high,
        sections_enabled: %w[experience education skills projects certifications languages]
      }
    ].freeze

    class << self
      def all
        PROFILES
      end

      def keys
        PROFILES.map { |p| p.fetch(:key) }
      end

      def find(key)
        PROFILES.detect { |p| p.fetch(:key) == key.to_s } || raise(KeyError, "Unknown seed profile: #{key}")
      end

      def profile_count
        PROFILES.size
      end

      def sections_for(profile, mode: :full)
        enabled = profile.fetch(:sections_enabled)
        return enabled if mode == :full

        enabled & %w[experience education skills]
      end
    end
  end
end
