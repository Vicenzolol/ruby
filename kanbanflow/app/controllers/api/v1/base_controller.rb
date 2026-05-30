module Api
  module V1
    # Controller base da API — herda de ActionController::API (sem cookies, sem flash)
    # Toda autenticação é por Bearer token no header Authorization.
    # Inclui ActionView::Rendering para suporte a templates Jbuilder (.json.jbuilder).
    class BaseController < ActionController::API
      # Habilita renderização de templates Jbuilder em app/views/api/v1/
      include ActionView::Rendering
      include ActionView::Layouts
      prepend_view_path Rails.root.join("app/views")

      # Paginação via pagy v43+ (Pagy::Method substitui Pagy::Backend)
      include Pagy::Method

      before_action :authenticate_api_token!

      rescue_from Pagy::RangeError do
        json_error("Número de página inválido", status: :bad_request)
      end

      private

      def authenticate_api_token!
        token = request.headers["Authorization"]&.delete_prefix("Bearer ")&.strip
        @current_user = User.authenticate_by_token(token) if token.present?

        render json: { error: "Não autorizado. Inclua o header: Authorization: Bearer <seu_token>" },
               status: :unauthorized unless @current_user
      end

      def current_user
        @current_user
      end

      # Normaliza erros: array de mensagens vira string concatenada
      def json_error(message, status: :unprocessable_entity)
        message = message.join(", ") if message.is_a?(Array)
        render json: { error: message }, status: status
      end
    end
  end
end
