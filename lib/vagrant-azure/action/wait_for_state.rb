#--------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------
require 'log4r'
require 'timeout'

module VagrantPlugins
  module WinAzure
    module Action
      class WaitForState
        def initialize(app, env, state, timeout)
          @app = app
          @state = state
          @timeout = timeout
          @logger = Log4r::Logger.new("vagrant_azure::action::wait_for_state")
        end

        def call(env)
          env[:result] = true

          if env[:machine].state.id == @state
            @logger.info(
              I18n.t('vagrant_azure.already_status', :status => @state)
            )
          else
            env[:ui].info "Waiting for machine to reach state #{@state}"
            @logger.info("Waiting for machine to reach state #{@state}")

            begin
              Timeout.timeout(@timeout)  do
                until env[:machine].state.id == @state
                  sleep 10
                end
              end
            rescue Timeout::Error
              env[:ui].error "Machine failed to reached state '#{@state}' in '#{@timeout}' seconds."
              env[:result] = false # couldn't reach state in time
            end
          end

          env[:ui].success "Machine reached state #{@state}"
          @app.call(env)
        end
      end
    end
  end
end
