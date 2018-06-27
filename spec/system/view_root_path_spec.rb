require 'rails_helper'

RSpec.describe 'View Root Path', type: :system do
  it 'can view the home page' do
    visit root_path
    expect(page).to have_content('This is the homepage')
  end
end