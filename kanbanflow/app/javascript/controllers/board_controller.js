import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Stimulus controller para drag-and-drop das tarefas entre colunas do Kanban
// Uso: data-controller="board" no elemento pai do board
//      data-board-update-url-value="..." para a URL de atualização de status
//      data-board-target="taskList" em cada lista de tarefas com data-status="..."

export default class extends Controller {
  static targets = ["taskList", "column"]
  static values  = { updateUrl: String }

  connect() {
    this.sortables = this.taskListTargets.map(list => this.#makeSortable(list))
  }

  disconnect() {
    this.sortables.forEach(s => s.destroy())
  }

  // --- privado ---

  // Realça a coluna de destino sob o cursor; limpa as demais.
  #highlightColumn(list) {
    const target = list && list.closest("[data-board-target='column']")
    this.columnTargets.forEach(col =>
      col.classList.toggle("kanban-column--over", col === target)
    )
  }

  #clearHighlight() {
    this.columnTargets.forEach(col => col.classList.remove("kanban-column--over"))
  }

  #makeSortable(list) {
    return Sortable.create(list, {
      group:     "kanban",          // permite mover entre listas diferentes
      animation: 150,
      ghostClass: "opacity-40",
      dragClass:  "shadow-xl",

      onStart: (event) => this.#highlightColumn(event.from),
      onMove:  (event) => { this.#highlightColumn(event.to); return true },

      onEnd: (event) => {
        this.#clearHighlight()

        const taskId = event.item.dataset.taskId
        const newStatus = event.to.dataset.status

        if (!taskId || !newStatus) return

        fetch(this.updateUrlValue, {
          method:  "PATCH",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
          },
          body: JSON.stringify({ task_id: taskId, status: newStatus })
        })
        .then(response => {
          if (!response.ok) {
            // Reverter posição visual se o servidor rejeitar
            event.from.insertBefore(event.item, event.from.children[event.oldIndex] || null)
          }
        })
      }
    })
  }
}
