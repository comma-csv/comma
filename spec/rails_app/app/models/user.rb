class User < ActiveRecord::Base
  comma do
    first_name
    last_name
    full_name "Name"
  end

  comma :shortened do
    first_name
    last_name
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
