
CREATE Procedure Sp_Get_BouncedCheque_Pidilite(@CustomerID nVarchar(25),@CollectionDate DateTime = '')    
As    
Begin    
 if @CollectionDate = ''     
  Set @CollectionDate = GetDate()    
    
 Select Top 1    
    "Cheque Number" =  ChequeNumber,    
    "Cheque Date" = ChequeDate ,    
    "Days" = Datediff(dd,DocumentDate,@CollectionDate)     
 From Collections     
 Where CustomerID=@CustomerID    
 And IsNull(Realised ,0) = 2    
 Order By DocumentDate Desc  
End    

