Create Procedure mERP_sp_GetOldDispDate(@DispID Int)  
As  
 Declare @i Int  
 Set @i = 1  
 While @i <> 0  
 Begin  
  If (Select IsNull(Original_Reference, 0) From DispatchAbstract Where DispatchID = @DispID) = 0  
  Begin  
   Set @i = 0  
   Select DispatchDate,CreationTime From DispatchAbstract Where DispatchId = @DispID  
  End  
  Else  
   Select @DispID = Original_Reference From DispatchAbstract Where DispatchId = @DispID  
 End  
