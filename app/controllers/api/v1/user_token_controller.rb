class Api::V1::UserTokenController < Knock::AuthTokenController
  resource_description do
    name 'Authentication'
    short 'Ways to authenticate to this API'
  end

  api! 'Create a JWT access token'
  description <<-DOC
  Credentials provided are sent to Foreman and Foreman returns a session ID used to build the access token

  The access token is a {JSON Web Token}[https://jwt.io/] and stored as the value to key +jwt+.
  This token expires after 1 hour.

  A refresh token, stored as the value to key +refresh_token+, is also provided only if authenticating with a username and password.
  This token expires after 1 month or after the Foreman session expires, whichever is earlier.

  The client should store both the access token and the refresh token.

  To renew an expired access token, call this method with the refresh token. If this fails, try again with a username and password.

  All authenticated API calls must contain the following header:

   Authorization: Bearer <jwt>

  Replace <code>\<jwt\></code> with the access token provided in this method's response.
  DOC
  param :auth, Hash, required: true, desc: '
  Credentials. One of the following sets of keys is required:
  - +username+, +password+
  - +refresh_token+
  The first set provided takes precedence.
  ' do
    param :username, String, required: false, desc: 'Foreman username. Must be provided with Foreman password.'
    param :password, String, required: false, desc: 'Foreman password. Must be provided with Foreman username.'
    param :refresh_token, String, required: false, desc: 'Refresh token. Ignored if Foreman username and Foreman password are provided.'
  end
  error code: 201, desc: 'Not an error. The credentials provided were authenticated and an access token is provided in the body.'
  error code: 404, desc: 'Foreman did not accept the credentials provided.'
  example <<-DOC
  {
    "jwt": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MTk3NzA2MjcsInN1YiI6ImFkbWluIiwidXNlcm5hbWUiOiJhZG1pbiIsImZvcmVtYW5fc2Vzc2lvbl9pZCI6IjQ2Nzc1NjJkZTQ5NDk1Y2RlNmFkN2RjN2I3MjkzODRkIn0.LBAc0GXj_rjfqidc2JhX8Yguhgca-oQbGCBHVXrdHWU",
    "refresh_token": "4458c707-c74c-4787-a354-c4679a3e4bc9"
  }
  DOC
  formats ['JSON']
  def create
    hash = {
      jwt: auth_token.token
    }
    hash[:refresh_token] = entity.refresh_token.token if entity.refresh_token
    render json: hash, status: :created
  end

  private

  def auth_params
    params.require(:auth).permit(:username, :password, :refresh_token)
  end
end
