module Vantiv
  module Environment
    PRODUCTION = :production
    CERTIFICATION = :certification

    def self.production?
      Vantiv.environment == PRODUCTION
    end

    def self.certification?
      Vantiv.environment == CERTIFICATION
    end
  end
end
