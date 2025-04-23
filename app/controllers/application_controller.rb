class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  def after_sign_out_path_for(resource_or_scope)
    root_path # or any custom path like welcome_path
  end

  private

  def authenticate_admin!
    # TEMP LOGIC (Simple)
    if current_user.nil? || !current_user.admin?
      redirect_to root_path, alert: "Access denied."
    end
  end
end
