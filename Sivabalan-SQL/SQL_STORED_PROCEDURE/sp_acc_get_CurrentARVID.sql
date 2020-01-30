CREATE Procedure sp_acc_get_CurrentARVID (@Position Int,@CurARVID int = 0)  
As  
If @Position = 1 /* Last ARV ID */  
Begin  
	Select Top 1 DocumentID From ARVAbstract
	Order By DocumentID Desc  
End  
Else if @Position = 2 /* Previous ARV ID */  
Begin  
	Select Top 1 DocumentID From ARVAbstract Where DocumentID < @CurARVID    
	Order By DocumentID Desc    
End  
Else if @Position = 3 /* Next ARV ID */  
Begin  
	Select Top 1 DocumentID From ARVAbstract Where DocumentID > @CurARVID    
	Order By DocumentID    
End  



