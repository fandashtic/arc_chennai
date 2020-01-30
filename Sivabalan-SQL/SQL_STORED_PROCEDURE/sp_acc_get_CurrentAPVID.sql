CREATE Procedure sp_acc_get_CurrentAPVID (@Position Int,@CurAPVID int = 0)  
As  
If @Position = 1 /* Last APV ID */  
Begin  
	Select Top 1 DocumentID From apvabstract
	Order By DocumentID Desc  
End  
Else if @Position = 2 /* Previous APV ID */  
Begin  
	Select Top 1 DocumentID From apvabstract Where DocumentID < @CurAPVID    
	Order By DocumentID Desc    
End  
Else if @Position = 3 /* Next APV ID */  
Begin  
	Select Top 1 DocumentID From apvabstract Where DocumentID > @CurAPVID    
	Order By DocumentID    
End  



