class UserDatabase
  def initialize
    @users = []
  end

  def insert(user)
    validate!(user, :username, :password)

    user = user.dup
    user[:id] = next_id

    @users.push(user)

    user.dup
  end

  def find_id_from_username(user)
    id = nil
    @users.each do |hash|
      if hash[:username] == user
        id = hash[:id]
      end
    end
    id
  end

  def find(id)
    (@users[offset_id(id)] or raise UserNotFoundError).dup
  end

  def delete(id)
    @users.delete_at(offset_id(id)) or raise UserNotFoundError
  end

  def all
    @users.dup
  end

  class UserNotFoundError < RuntimeError; end

  private

  def validate!(user, *attributes)
    invalid_attributes = attributes.select { |a| !user.has_key?(a) }

    if invalid_attributes.any?
      message = "#{invalid_attributes.join(", ")} required"
      raise ArgumentError, message
    end
  end

  def next_id
    @users.length + 1
  end

  def offset_id(id)
    id - 1
  end
end
