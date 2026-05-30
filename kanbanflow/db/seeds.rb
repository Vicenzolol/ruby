# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# ─── Seeds de Desenvolvimento ─────────────────────────────────────────────────
# Usa Faker para dados realistas. Idempotente: `find_or_create_by!` evita duplicatas.
# Rodar: bundle exec rails db:seed
# ──────────────────────────────────────────────────────────────────────────────

puts "🌱 Populando banco de dados..."

if Rails.env.production?
  puts "  ⏭️  Ambiente production: seeds de demo ignorados."
  puts "\n✅ Seeds concluídos! (produção)"
else
  STATUSES   = %w[todo in_progress done].freeze
  TASK_COUNT = (5..10)

  # ─── 2 usuários de demonstração ───────────────────────────────────────────────
  usuarios = [
    { email_address: "admin@kanbanflow.dev",   password: "senha_segura123" },
    { email_address: "dev@kanbanflow.dev",      password: "senha_segura123" }
  ]

  usuarios.each do |attrs|
    user = User.find_or_initialize_by(email_address: attrs[:email_address])
    if user.new_record?
      user.password = attrs[:password]
      user.save!
      puts "  ✅ Usuário criado: #{user.email_address}"
    else
      puts "  ⏭️  Usuário já existe: #{user.email_address}"
    end

    # ─── 3 projetos por usuário ─────────────────────────────────────────────
    3.times do
      project = user.projects.create!(
        name:        Faker::App.name.first(60),
        description: Faker::Lorem.paragraph(sentence_count: 2),
        color:       Project::COLORS.sample
      )
      puts "    📁 Projeto: #{project.name}"

      # ─── 5–10 tasks por projeto com statuses variados ─────────────────
      rand(TASK_COUNT).times do
        project.tasks.create!(
          title:       Faker::Lorem.sentence(word_count: rand(3..7)).first(180),
          description: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
          status:      STATUSES.sample
        )
      end

      puts "      🃏 #{project.tasks.count} tarefas criadas"
    end
  end

  puts "\n✅ Seeds concluídos!"
  puts "   Usuários: #{User.count}"
  puts "   Projetos: #{Project.count}"
  puts "   Tarefas:  #{Task.count}"
end

