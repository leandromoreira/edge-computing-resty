ActiveAdmin.register ComputingUnit do
  permit_params :name, :phase, :code, :sampling
  
  form do |f|
    f.inputs "Computing Unit" do
      f.input :name
      f.input :phase, as: :select, collection: ComputingUnit::PHASE_OPTIONS
      f.input :code, :as => :text
      f.input :sampling, :as => :number
    end
    actions
  end
end
