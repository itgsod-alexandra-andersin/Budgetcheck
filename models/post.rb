class Post
  include DataMapper::Resource

  property :id,     Serial
  property :title,  String
  property :text,   Text
  property :date,   Date

  belongs_to :user
end