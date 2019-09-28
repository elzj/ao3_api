# frozen_string_literal: true

class Api::V3::Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  # before_action :configure_sign_in_params, only: [:create]
  respond_to :json

  def resource_name
    'user'
  end

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options.merge(scope: :user))
    sign_in(resource_name, resource)
    yield resource if block_given?
    render json: { msg: "Successfully logged in" }
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # def sign_in_params
  #   params.require(:user).permit(:login, :password)
  # end

  # # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:login])
  # end
end
