Create Proc sp_SKU_Process_SchemeProducts  
AS  
Begin   

	Exec Sp_Insert_SchSKUDetail 'IsNew'
	Exec Sp_Update_SchSKUDetail 'IsUpdate'
End  
