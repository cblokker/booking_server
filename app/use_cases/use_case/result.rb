module UseCase
  class Result
    attr_reader :success, :data, :errors

    def initialize(success:, data: nil, errors: [])
      @success = success
      @data = data
      @errors = errors
    end

    def success?
      success
    end

    def self.success(data: nil)
      new(success: true, data: data)
    end

    def self.failure(errors: [])
      new(success: false, errors: errors)
    end
  end
end