module RedmineSpentTimeRequired
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          alias_method_chain :update, :check_spent_time
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def update_with_check_spent_time
          allowed_statuses = Setting.plugin_redmine_spent_time_required['statuses'].scan(/\d+/)
          current_status = params[:issue][:status_id] 

          current_user = User.current.id.to_i
          assignee = params[:issue][:assigned_to_id].to_i

          if ((!params[:time_entry].nil?) && (!Issue.find(params[:id]).children?))
            if ((params[:time_entry][:hours] == "") && 
                (allowed_statuses.member?(current_status.to_s)) &&
                (current_user == assignee) && (current_status.to_i != Issue.find(params[:id])[:status_id].to_i))
              find_issue
              update_issue_from_params
              @time_entry.errors.add :hours, :empty
              render(:action => 'edit') and return
            else
              update_without_check_spent_time
            end
          else
            update_without_check_spent_time
          end
        end
      end

    end
  end
end
