# frozen_string_literal: true

module VAForms
  class UpdateFormTagsService
    def run
      Rails.logger.info('Running VAForms::UpdateFormTagsService - Adding form tags')

      form_tags['form tags list'].each do |tag_info|
        tags_to_add = tag_info['tags']
        tag_info['form_names'].each { |form_name| add_tags_to_form(form_name, tags_to_add) }
      end
    end

    def self.run
      new.run
    end

    private

    def form_tags
      YAML.load_file(update_form_tags_yaml_path)
    end

    def update_form_tags_yaml_path
      Rails.root.join('modules','va_forms', 'config', 'update_form_tags.yaml').to_s
    end

    def add_tags_to_form(form_name, tags_to_add)
      form = VAForms::Form.find_by(form_name: form_name)
      return if form.blank? || form.tags.include?(tags_to_add)

      form.update_attribute(:tags, "#{form.tags} #{tags_to_add}")
    rescue
      Rails.logger.send(:error, "VAForms:UpdateFormTagsService failed to add tags to form_name:#{form_name},
      tags_to_add:#{tags_to_add}")
    end
  end
end
