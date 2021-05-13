ActiveAdmin.register Channel do
  menu priority: 1
  permit_params :label, :segment_duration_ms

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :label
      f.input :segment_duration_ms, hint: "you must specify the segment durtion in ms (>1000 and supporting the gop size)"
    end
    f.actions
  end

  index do
    column "Channel" do |channel|
      link_to channel, admin_channel_path(channel)
    end
    actions
  end
end
