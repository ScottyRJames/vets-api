# frozen_string_literal: true

require_dependency 'mobile/application_controller'

module Mobile
  class DiscoveryController < ApplicationController
    skip_before_action :authenticate
    
    SERVICE_GRAPH = Mobile::ServiceGraph.new(
      %i[bgs evss],
      %i[iam_ssoe auth],
      %i[mpi auth],
      %i[mpi evss],
      %i[arcgis facility_locator],
      %i[auth auth_dslogon],
      %i[auth auth_idme],
      %i[auth auth_mhv],
      %i[caseflow appeals],
      %i[dslogon auth_dslogon],
      %i[emis military_service_history],
      %i[evss claims],
      %i[evss direct_deposit_benefits],
      %i[evss letters_and_documents],
      %i[idme auth_idme],
      %i[mhv auth_mhv],
      %i[mhv secure_messaging],
      %i[vaos appointments],
      %i[vet360 user_profile_update]
    )
    
    def index
      render json: Mobile::V0::DiscoverySerializer.new(discovery)
    end
    
    def welcome
      render json: { data: { attributes: { message: 'Welcome to the mobile API' } } }
    end
    
    private
    
    def discovery
      Mobile::Discovery.new(
        id: SecureRandom.uuid,
        auth_base_url: Settings.mobile_api.auth_base_url,
        api_root_url: Settings.mobile_api.api_root_url,
        minimum_version: Settings.mobile_api.minimum_version,
        maintenance_windows: maintenance_windows,
        web_views: Settings.mobile_api.web_views
      )
    end
    
    def maintenance_windows
      api_maintenance_windows = {}
      upstream_maintenance_windows = ::MaintenanceWindow.end_after(Time.zone.now)
      
      upstream_maintenance_windows.each do |window|
        affected_services = SERVICE_GRAPH.affected_services(window.external_service.to_sym)
        
        binding.pry
        
        affected_services.each do |service|
          api_maintenance_windows[window.external_service] = if api_maintenance_windows[window.external_service]
                                                               Mobile::MaintenanceWindow.new(
                                                                 id: window.id,
                                                                 external_service: window.external_service,
                                                                 start_time: window.start_time,
                                                                 end_time: window.start_time,
                                                                 description: window.description
                                                               )
                                                             else
                                                               Mobile::MaintenanceWindow.new(
                                                                 id: window.id,
                                                                 external_service: window.external_service,
                                                                 start_time: window.start_time,
                                                                 end_time: window.start_time,
                                                                 description: window.description
                                                               )
                                                             end
        end
        
        api_maintenance_windows.to_a
      end
    end
  end
end
