# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'routes for Session', type: :routing do
  it 'doesnt route something not matching the constraint' do
    expect(get('/sessions/unknown/new')).to route_to(
      controller: 'application',
      action: 'routing_error',
      path: 'sessions/unknown/new'
    )
  end
end
