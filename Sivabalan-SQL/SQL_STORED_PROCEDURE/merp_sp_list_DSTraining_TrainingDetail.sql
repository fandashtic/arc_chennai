Create Procedure merp_sp_list_DSTraining_TrainingDetail
As
Begin
  Select DSTraining_ID, DSTraining_Name from tbl_merp_DSTraining
  Where DSTraining_Active = 1
  Order by 1
End
