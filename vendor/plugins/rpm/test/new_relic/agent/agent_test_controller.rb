# This is a controller class used in testing controller instrumentation
class NewRelic::Agent::AgentTestController < ActionController::Base
  filter_parameter_logging :social_security_number

  def rescue_action(e) raise e end

  ActionController::Routing::Routes.draw do | map |
    map.connect ':controller/:action.:format'
#    map.connect '/new_relic/agent/agent_test/:action', :controller => 'new_relic/agent/agent_test'
  end
  
  def index
    render :text => params.inspect
  end
  def _filter_parameters(params)
    filter_parameters params
  end
  def action_to_render
    render :text => params.inspect
  end
  def action_to_ignore
    render :text => 'unmeasured'
  end
  def entry_action
    perform_action_with_newrelic_trace('internal_action') do
      internal_action
    end    
  end
  private
  def internal_action
    render :text => 'internal action'
  end
end