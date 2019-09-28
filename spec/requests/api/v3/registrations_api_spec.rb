require 'rails_helper'

RSpec.describe 'POST /signup', type: :request do
  let(:url) { '/api/v3/users' }
  let(:params) do
    {
      user: {
        login: 'itsme',
        email: 'user@example.com',
        password: 'password',
        password_confirmation: 'password'
      }
    }
  end

  context 'when user is unauthenticated' do
    before { post url, params: params }

    it 'returns 200' do
      expect(response).to have_http_status(:created)
    end

    it 'returns a new user' do
      msg = JSON.parse(response.body)
      expect(msg).to have_key('id')
    end
  end

  context 'when user already exists' do
    before do
      create(:user, login: params[:user][:login])
      post url, params: params
    end

    it 'returns bad request status' do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns validation errors' do
      msg = JSON.parse(response.body)
      expect(msg['errors'].first).to match('Login has already been taken')
    end
  end
end
