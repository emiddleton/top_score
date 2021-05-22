RSpec.shared_context 'json' do
  def json_headers
    { Accept: 'application/json', "Content-type": 'application/json' }
  end

  def json_expected_response(status = :ok)
    expect(response.content_type).to eq('application/json; charset=utf-8')
    expect(response).to have_http_status(status)
  end

  def get_json(path, arguments = nil, status = :ok)
    get path, params: arguments, headers: json_headers
    json_expected_response(status)
  end

  def post_json(path, arguments = nil, status = :created)
    post path, params: arguments, headers: json_headers
    json_expected_response(status)
  end

  def delete_json(path, arguments = nil, status = :no_content)
    delete path, params: arguments, headers: json_headers
    expect(response).to have_http_status(status)
  end
end
