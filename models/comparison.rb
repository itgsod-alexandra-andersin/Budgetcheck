class Comparison
  include DataMapper::Resource

  property :id, Serial

  belongs_to :budget
end