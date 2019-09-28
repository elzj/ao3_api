module AuthHelper
  def authenticate(user)
    url = '/api/v3/users/login'
    params = {
      user: {
        login: user.login,
        password: user.password
      }
    }
    post url, params: params
    response.headers['Authorization']
  end

  def log_out
    delete '/api/v3/users/logout'
  end
end
