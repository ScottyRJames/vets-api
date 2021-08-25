# frozen_string_literal: true

module AppealsApi
  module CharacterUtilities
    extend ActiveSupport::Concern

    included do
      OUTSIDE_WINDOWS_1252_PATTERN = /[^\u0000-\u0255]+/.freeze

      def transliterate_for_centralmail(str)
        I18n.transliterate(str.to_s).gsub(/[^a-zA-Z\-\s]/, '').strip.first(50)
      end

      def validate_characters
        characters = request_headers.to_s + params.to_s
        characters.delete! '"'

        render_invalid_characters_error if characters =~ OUTSIDE_WINDOWS_1252_PATTERN
      end

      private

      def render_invalid_characters_error
        render(
          status: :unprocessable_entity,
          json: {
            errors: [
              {
                status: 422,
                detail: 'Invalid characters in headers/body.',
                meta: { pattern: OUTSIDE_WINDOWS_1252_PATTERN.inspect }
              }
            ]
          }
        )
      end
    end
  end
end
