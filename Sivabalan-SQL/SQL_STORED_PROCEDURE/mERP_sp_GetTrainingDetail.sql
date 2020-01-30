Create Procedure mERP_sp_GetTrainingDetail (@DSCode Int)
As
	Select DSTA.DSTraining_Name As DSTrainingName, 
		DSTD.ActualDate, 
		IsNull(DSTD.Facilitator, '') As Facilitator, 
		IsNull(DSTD.Score, 0) As Score 
		From tbl_mERP_DSTrainingDetail DSTD, tbl_mERP_DSTraining DSTA
		Where DSTD.DSCode = @DSCode and 
        DSTA.DSTraining_ID = DSTD.DSTrainingID and 
		DSTD.Attended = 1 
    Order by 2,1 
