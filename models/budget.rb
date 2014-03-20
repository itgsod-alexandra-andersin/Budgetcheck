class Budget
  include DataMapper::Resource

  property :id, Serial
  property :income, Integer
  property :food, Integer
  property :clothes, Integer
  property :loans, Integer
  property :leisures, Integer
  property :amorizations, Integer
  property :misc, Integer
  property :savings, Integer
  property :date, Date

  belongs_to :user
  #belongs_to :comparison
end