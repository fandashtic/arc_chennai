Create Function fn_getbeatcustomer (@CustomerID nvarchar(100))        
Returns nvarchar(2100)        
As        
Begin  
Declare @Result nvarchar(2100)  
Declare @BeatName nvarchar(100)
Set @Result=''
Declare BeatList Cursor Keyset For
Select Distinct Description from Beat , Beat_Salesman 
Where Beat.BeatID = Beat_Salesman.BeatID 
And Beat_Salesman.CustomerID = @CustomerID
Open BeatList        
Fetch From BeatList into @BeatName
While @@Fetch_Status = 0        
Begin
Set @Result= @Result + @BeatName + ' | '
Fetch Next From BeatList into @BeatName
End
  
Close BeatList      
Deallocate BeatList        
Return @Result        
End
