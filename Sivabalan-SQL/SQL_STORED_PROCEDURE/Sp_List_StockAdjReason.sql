Create Procedure Sp_List_StockAdjReason  
As  
Begin  
	Select "MessageID" = IsNull(MessageID,0),"Message" = IsNull(Message,'') 
	From StockAdjustmentReason Where Message IN (N'Stock transfer to other CA/Factory ',N'Transfer to Damage',
	N'Transfer from Good',N'Physical Stock Difference',N'Adjustment due to error made in STI',N'Adjustment for loose conversion',N'Others')  
End  
