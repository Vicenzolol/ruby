module Api
  module V1
    # GET /api/v1/me — retorna dados do usuário autenticado + seu api_token
    class UsersController < BaseController
      def me
        render json: {
          id:          current_user.id,
          email:       current_user.email_address,
          api_token:   current_user.api_token,
          projects_count: current_user.projects.count,
          created_at:  current_user.created_at
        }
      end
    end
  end
end
