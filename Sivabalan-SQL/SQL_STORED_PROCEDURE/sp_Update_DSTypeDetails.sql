CREATE Procedure sp_Update_DSTypeDetails    
(@smanID Integer,@dsType nVarchar(100),@nPos Integer)    
As    
Begin    
Declare @TypeID as Integer,@dsName as nVarchar(100)    
Declare @ModifyDt as Integer


if @nPos >= 1  and @nPos <= 3     
	if Not Exists(Select * from DSType_Details Where SalesManID = @smanID and DSTypeCtlPos  = @nPos and DSTypeID = @dsType)
		Set @ModifyDt = 1


 

if @nPos  = 4 Set @dsName = 'Field3'
if @nPos  = 5 Set @dsName = 'Field4'
if @nPos  = 6 Set @dsName = 'Field5'
	


  
if @nPos >= 1  and @nPos <= 3     
Begin    
	if Cast(@dsType as Integer) > 0     
    Begin    
    	if Exists(Select * From DSType_Details  Where SalesmanID = @smanID and DSTypeCtlPos  = @nPos ) 
    		Update DSType_Details Set DSTypeID = @dsType Where SalesmanID = @smanID and DSTypeCtlPos  = @nPos     
      	else    
       		Insert Into DSType_Details(SalesManID,DSTypeId,DSTypeCtlPos) Values (@smanID,@dsType,@nPos)    
    End    
    Else    
      Delete From DSType_Details Where SalesManID = @smanID and DSTypeCtlPos = @nPos    
  	End    
Else    
Begin    
	if @dsType <> ''     
	begin    
		Select @TypeID = DSTypeID From DSType_Master Where DSTypeValue = @dsType and DSTypeCtlPos  = @nPos     
		if @TypeID > 0     
		begin  
			if  Not Exists(Select * from DSType_Details Where SalesManID = @smanID and DSTypeCtlPos  = @nPos and DSTypeID = @TypeID)  
				Set @ModifyDt = 1
			if Exists(Select * From DSType_Details  Where SalesmanID = @smanID and DSTypeCtlPos  = @nPos )    
				Update DSType_Details Set DSTypeID = @TypeID Where SalesmanID = @smanID and DSTypeCtlPos  = @nPos        
    		else    
				Insert Into DSType_Details(SalesManID,DSTypeId,DSTypeCtlPos) Values (@smanID,@TypeID,@nPos)     
   		end    
		else    
		begin    
			Set @ModifyDt = 1
			--Select @dsName = DSTypeName From DSType_Master Where DSTypeCtlPos = @nPos       
			Insert Into DSType_Master(DSTypeName,DSTypeValue,DSTypeCtlPos) Values (@dsName, @dsType,@nPos)    
			if Exists(Select * From DSType_Details  Where SalesmanID = @smanID and DSTypeCtlPos  = @nPos )    
				Update DSType_Details Set DSTypeID = @@identity Where SalesmanID = @smanID and DSTypeCtlPos  = @nPos        
			else
				Insert  Into DSType_Details(SalesManID,DSTypeId,DSTypeCtlPos) Values (@smanID,@@identity,@nPos)     
		end    
	end      
	else    
		Delete From DSType_Details Where SalesManID = @smanID and DSTypeCtlPos = @nPos    
End    

  





if Exists(Select * from Beat_Salesman Where SalesManID = @smanID and BeatID <> 0 and isnull(CustomerID,'') <> '')
Begin
	If	@ModifyDt = 1
	begin
		Update Salesman Set ModifiedDate = Getdate() Where SalesmanID  = @smanID
		Update Customer Set ModifiedDate = GetDate() Where isnull(CustomerID,'') IN
		(Select ISNull(CustomerID,'') From Beat_Salesman Where SalesManID = @smanID and BeatID <> 0)
	end
End

End    

