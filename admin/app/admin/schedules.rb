ActiveAdmin.register Schedule do
  menu priority: 10
  permit_params :airing_time, :video_index, :segments_count, :channel_id, :video_id

  filter :channel
  filter :video
  config.per_page = 10

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :channel
      f.input :video
      f.input :airing_time, as: :date_time_picker,
        hint: "If you don't specifiy, it'll use now or fit after the last video for this channel."
    end
    f.actions
  end

  index do
    column "Schedule" do |schedule|
      link_to schedule, admin_schedule_path(schedule)
    end
    actions
  end

  controller do
    def create
      create! do |format|
        format.html { redirect_to collection_path }
      end
    end
  end
end
