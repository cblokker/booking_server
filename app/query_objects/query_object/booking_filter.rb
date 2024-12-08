module QueryObject
  class BookingFilter
    def initialize(user, state)
      @user = user
      @state = state
    end

    def filter
      bookings = Booking.includes(:student, :coach)
      bookings = filter_by_role(bookings)
      bookings = filter_by_state(bookings)
      bookings
    end

    private

    def filter_by_role(bookings)
      if @user.student?
        bookings.for_student(@user.id)
      elsif @user.coach?
        bookings.for_coach(@user.id)
      else
        bookings
      end
    end

    def filter_by_state(bookings)
      case @state
      when 'missed'
        bookings.missed
      when 'upcoming'
        bookings.upcoming_booked
      when 'completed'
        bookings.completed # this includes future complete
      else
        bookings
      end
    end
  end
end
