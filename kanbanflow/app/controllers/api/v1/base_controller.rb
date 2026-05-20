module Api
  module V1
    # Controller base da API — herda de ActionController::API (sem views, sem cookies)
    # Toda autenticação é por Bearer token no header Authorization
    class BaseController < ActionController::API
      before_action :authenticate_api_token!

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

      def json_error(message, status: :unprocessable_entity)
        render json: { error: message }, status: status
      end
    end
  end
end
