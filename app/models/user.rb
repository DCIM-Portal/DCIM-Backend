class User
  class << self
    def from_token_request(request)
      params = request.params
      auth = params['auth']
      return false unless auth
      return from_foreman_login(auth['username']) if auth['username'] && auth['password']
      return from_refresh_token(auth['refresh_token']) if auth['refresh_token']
      false
    end

    def from_token_payload(payload)
      new(payload)
    end

    def from_foreman_login(username)
      new(username: username)
    end

    def from_refresh_token(refresh_token_string)
      refresh_token = RefreshToken.find_by(token: refresh_token_string)
      return false unless refresh_token
      refresh_token.user
    end
  end

  attr_reader :refresh_token

  def initialize(**kwargs)
    @username = kwargs[:username]
    @foreman_session_id = kwargs[:foreman_session_id]
  end

  def authenticate(password)
    return authenticate_existing_session unless password

    api = Dcim::ForemanApiFactory.unauthenticated_instance
    response = api.users.login.get
    body = response.body
    cookies = response.cookies
    page = Nokogiri::HTML(body)
    csrf_token = page.at_css('#login-form').at_css('[name=authenticity_token]').attribute('value').to_s
    begin
      response = api.users.login.post(
        payload:
            {
              'login' =>
                    {
                      'login' => @username,
                      'password' => password
                    },
              'authenticity_token' => csrf_token
            }.to_json,
        cookies: cookies,
        max_redirects: 0
      )
    rescue RestClient::ExceptionWithResponse => e
      response = e.response

      # Authentication failed
      return false if response.headers[:location].end_with?('/users/login')
    end
    cookies = response.cookies
    @foreman_session_id = cookies['_session_id']
    create_refresh_token
    self
  end

  def authenticate_existing_session
    api = Dcim::ForemanApiFactory.unauthenticated_instance
    api.api.get(cookies: { '_session_id' => @foreman_session_id })
    true
  rescue RestClient::ExceptionWithResponse
    false
  end

  def create_refresh_token
    @refresh_token = RefreshToken.new(
      data: to_token_payload.to_json
    )
    @refresh_token.save!
  end

  def to_token_payload
    {
      sub: @username,
      username: @username,
      foreman_session_id: @foreman_session_id
    }
  end
end
