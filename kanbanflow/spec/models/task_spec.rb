require "rails_helper"

RSpec.describe Task, type: :model do
  subject(:task) { build(:task) }

  # ─── Associations ────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to belong_to(:project) }
  end

  # ─── Validations ────────────────────────────────────────────
  describe "validations" do
    describe "#title" do
      it "é obrigatório" do
        task.title = ""
        expect(task).not_to be_valid
        expect(task.errors[:title]).to include("é obrigatório")
      end

      it "aceita título válido" do
        task.title = "Implementar login"
        expect(task).to be_valid
      end

      it "rejeita título com mais de 200 caracteres" do
        task.title = "T" * 201
        expect(task).not_to be_valid
        expect(task.errors[:title]).to include("deve ter no máximo 200 caracteres")
      end

      it "aceita título com exatamente 200 caracteres" do
        task.title = "T" * 200
        expect(task).to be_valid
      end
    end
  end

  # ─── Enum status ─────────────────────────────────────────────
  describe "enum status" do
    it "mapeia todo para 0" do
      expect(Task.statuses[:todo]).to eq(0)
    end

    it "mapeia in_progress para 1" do
      expect(Task.statuses[:in_progress]).to eq(1)
    end

    it "mapeia done para 2" do
      expect(Task.statuses[:done]).to eq(2)
    end

    it "define predicados de status" do
      task.status = :todo
      expect(task).to be_todo
      expect(task).not_to be_in_progress
      expect(task).not_to be_done
    end
  end

  # ─── Scopes ─────────────────────────────────────────────────
  describe ".by_status" do
    it "filtra tarefas pelo status informado" do
      project = create(:project)
      todo_task = create(:task, project: project, status: :todo)
      done_task = create(:task, project: project, status: :done)

      result = Task.by_status(:todo)
      expect(result).to include(todo_task)
      expect(result).not_to include(done_task)
    end
  end

  describe ".ordered" do
    it "retorna tarefas em ordem ascendente de position" do
      project = create(:project)
      # Cria as tasks — set_position define posições sequencialmente
      t1 = create(:task, project: project)
      t2 = create(:task, project: project)
      t3 = create(:task, project: project)

      expect(project.tasks.ordered.to_a).to eq([t1, t2, t3])
    end
  end

  # ─── Callback set_position ────────────────────────────────────
  describe "#set_position (before_create)" do
    it "define position = 1 para a primeira tarefa do projeto" do
      project = create(:project)
      task    = create(:task, project: project)
      expect(task.position).to eq(1)
    end

    it "incrementa position para tarefas subsequentes" do
      project = create(:project)
      t1 = create(:task, project: project)
      t2 = create(:task, project: project)
      t3 = create(:task, project: project)

      expect(t1.position).to eq(1)
      expect(t2.position).to eq(2)
      expect(t3.position).to eq(3)
    end

    it "cada projeto tem sua própria sequência de position" do
      p1 = create(:project)
      p2 = create(:project)

      create(:task, project: p1)
      create(:task, project: p1)
      first_p2_task = create(:task, project: p2)

      expect(first_p2_task.position).to eq(1)
    end
  end
end

