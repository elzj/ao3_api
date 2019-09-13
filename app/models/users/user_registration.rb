class UserRegistration
  attr_reader :user, :errors
  
  def initialize(user_data)
    @user = User.new(user_data)
    @errors = []
  end

  def save
    if !user.valid?
      @errors = user.errors.full_messages
      return false
    end
    User.transaction do
      user.save!
      Pseud.create_default(user)
      Profile.create_default(user)
      Preference.create_default(user)
    end
  rescue ActiveRecord::RecordInvalid => exception
    @errors << exception.message
    false
  end

  def error_message
    @errors.join("\n")
  end
end
