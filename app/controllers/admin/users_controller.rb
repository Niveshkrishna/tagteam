# frozen_string_literal: true

module Admin
  # Controller for admins to see existing users in the system
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :set_sort, only: :index

    after_action :verify_authorized

    def index
      authorize User

      breadcrumbs.add 'Admin', admin_users_path
      breadcrumbs.add 'Users', admin_users_path

      @users =
        Users::Sort.run!(users: policy_scope(User), sort_method: @sort)
                   .paginate(page: params[:page], per_page: get_per_page)
    end

    private

    def set_sort
      @sort =
        if %w[application_roles confirmed locked owned_hubs username last_sign_in_at].include?(params[:sort])
          params[:sort]
        else
          'username'
        end
    end
  end
end
