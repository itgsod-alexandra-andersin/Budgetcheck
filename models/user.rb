class User
  include DataMapper::Resource

  property :id, Serial
  property :username, String
  property :password, BCryptHash

  has n, :budget

  def self.generate_tsv_files
    all.each do |user|
      File.open("data.tsv", "w+") do |file|
        file.puts("Date\tSpent\tAvgspent")
        user.budget.each do |budget|
          file.puts("#{budget.date}")
          file.puts("#{budget.last.date}\t
              #{budget.last.food+budget.last.clothes+budget.last.loans+budget.last(:leisures)+budget.last(:amorizations)+budget.last(:misc)+budget.last(:savings)}\t
              #{budget.avg(:food).round+budget.avg(:clothes).round+budget.avg(:loans).round+budget.avg(:leisures).round
              +budget.avg(:amorizations).round+budget.avg(:misc).round+budget.avg(:savings).round}")
        end
      end
    end
  end

end
