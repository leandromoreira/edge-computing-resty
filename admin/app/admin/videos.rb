ActiveAdmin.register Video do
  menu priority: 20
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :label, :duration_ms, :schedule_id, :renditions,
                  renditions_attributes: [:id, :label, :path, :_destroy]
  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :label
      f.input :duration_ms
    end
    f.inputs do
      f.has_many :renditions, allow_destroy: true do |a|
        a.input :label
        a.input :path
      end
    end
    f.actions
  end
  index do
    column "Label" do |video|
      link_to video, admin_video_path(video)
    end
    actions
  end

  #
  # or
  #
  # permit_params do
  #   permitted = [:label, :duration_ms, :schedule_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
