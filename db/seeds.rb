# Clear existing data
Booking.delete_all
AvailabilityWindow.delete_all
User.delete_all


# Prepare coaches data
coaches_data = [
  {
    first_name: 'Sarah',
    last_name: 'Johnson',
    role: 1, # Coach
    phone_number: '555-123-0001',
    image_url: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=256&h=256&q=80',
    email: 'sarah.johnson@example.com',
    encrypted_password: Devise::Encryptor.digest(User, 'password'),
  },
  {
    first_name: 'Michael',
    last_name: 'Chen',
    role: 1, # Coach
    phone_number: '555-123-0002',
    image_url: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=256&h=256&q=80',
    email: 'michael.chen@example.com',
    encrypted_password: Devise::Encryptor.digest(User, 'password'),
  }
]

# Prepare students data
students_data = [
  {
    first_name: 'Alice',
    last_name: 'Thompson',
    role: 0, # Student
    phone_number: '555-456-0001',
    image_url: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=256&h=256&q=80',
    email: 'alice.thompson@example.com',
    encrypted_password: Devise::Encryptor.digest(User, 'password'),
  },
  {
    first_name: 'James',
    last_name: 'Carter',
    role: 0, # Student
    phone_number: '555-456-0002',
    image_url: 'https://images.unsplash.com/photo-1502767089025-6572583495f6?auto=format&fit=crop&w=256&h=256&q=80',
    email: 'james.carter@example.com',
    encrypted_password: Devise::Encryptor.digest(User, 'password'),
  }
]

# Insert users into the database
User.insert_all(coaches_data + students_data)

# Retrieve inserted coaches and students
coaches = User.where(role: 1).order(:id)
students = User.where(role: 0).order(:id)

# Insert availability windows for coaches
availability_windows_data = [
  {
    intervals: [{ start_time: "09:00", end_time: "11:00" }],
    day_of_week: 1, # Monday
    coach_id: coaches[0].id,
  },
  {
    intervals: [{ start_time: "14:00", end_time: "16:00" }],
    day_of_week: 3, # Wednesday
    coach_id: coaches[0].id,
  },
  {
    intervals: [{ start_time: "10:00", end_time: "12:00" }],
    day_of_week: 2, # Tuesday
    coach_id: coaches[1].id,
  },
  {
    intervals: [{ start_time: "15:00", end_time: "17:00" }],
    day_of_week: 4, # Thursday
    coach_id: coaches[1].id,
  }
]
AvailabilityWindow.insert_all(availability_windows_data)
