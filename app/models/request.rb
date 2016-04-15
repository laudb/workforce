class Request < ActiveRecord::Base
	belongs_to :client, counter_cache: true
	has_and_belongs_to_many :workers

	validates :bathrooms, :bedrooms, :kitchens, :hall, :date_time, :frequency, presence: true
    validate :weekday_array_cannot_be_empty
    validate :restrict_selection
    validate :forbidden_dates

    def weekday_array_cannot_be_empty
      if weekdays == [""]
      	errors.add(:weekdays, "please choose a day")
      end      
    end

    def restrict_selection
      if frequency == 60 && weekdays.length > 2
      	errors.add(:weekdays, "You can only choose one day for One-Off package")
      elsif frequency == 150 && weekdays.length > 4
      	errors.add(:weekdays, "You can't choose more than 3 days for weekly package.")
      elsif frequency ==500 && weekdays.length > 4
      	errors.add(:weekdays, "You can't choose more than 3 days for Monthly package")
      end
    end

    def forbidden_dates
      if date_time.year == 2016 && date_time.month < Time.now.month
      	errors.add(:date_time, "Can't choose a month in the past")
      elsif date_time.year == 2016 && date_time.month > Time.now.month + 3
      	errors.add(:date_time, "Can't choose a month beyond 3 months from now.")      		
      elsif date_time.year == 2016 && date_time.month == Time.now.month && date_time.day < Time.now.day
      	errors.add(:date_time, "Can't choose a day in the past.")
      elsif date_time.month == Time.now.month && date_time.hour < Time.now.hour
      	errors.add(:date_time, "Can't choose a time in the past.")
      elsif date_time.year == 2017 && date_time.month < 10
      	errors.add(:date_time, "the year is too far off")
      end
    end





	scope :resolved_requests, lambda {where(status: "resolved")}
  


	def resolve
	  self.update(status: "resolved")
	end


	def close_request
	  self.update(status: "done")
	end

	def reopen_request
	  self.update(status:"redo")
	end


	def add
	  self.update(client_id: Client.current.id)
	end
	
end
