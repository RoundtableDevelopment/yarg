module Features
  module SessionHelpers
    def login_as_user
      @user = create(:user)

      visit new_user_session_path

      fill_in 'Email', with: @user.email
      fill_in 'Password', with: '11111111'

      click_button 'Sign In'
    end
  end
end