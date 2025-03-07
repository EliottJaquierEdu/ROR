class RenameMasterToMasterIdInSchoolClasses < ActiveRecord::Migration[8.0]
  def change
    rename_column :school_classes, :master, :master_id
  end
end 