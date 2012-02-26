class Post < ActiveRecord::Base

  comma do
    title
    description

    user :full_name
  end

end