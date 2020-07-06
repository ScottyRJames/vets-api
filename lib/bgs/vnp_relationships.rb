# frozen_string_literal: true

module BGS
  class VnpRelationships < Service
    def initialize(proc_id:, veteran:, dependents:, user:)
      @proc_id = proc_id
      @dependents = dependents
      @veteran = veteran


      super(user) # is this cool? Might be smelly. Might indicate a new class/object 🤔
    end

    def create
      spouse_marriages, vet_dependents = @dependents.partition { |dependent| dependent[:type] == 'spouse_former_marriage' }
      spouse = @dependents.find { |dependent| dependent[:type] == 'spouse' }

      spouse_marriages.each do |dependent|
        create_relationship(@proc_id, spouse[:vnp_participant_id], dependent)
      end

      vet_dependents.each do |dependent|
        create_relationship(@proc_id, @veteran[:vnp_participant_id], dependent)
      end
    end
  end
end
