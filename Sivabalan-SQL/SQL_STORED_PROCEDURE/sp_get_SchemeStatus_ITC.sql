CREATE Procedure sp_get_SchemeStatus_ITC(@SchemeID Int,@ItemCode nVarChar(15),@CustCode nVarChar(15))  
As  
Declare @ValidTo DateTime  
Declare @CurDate DateTime  
Declare @SchExp Int  
Declare @Active Int  
Declare @ItemMaping Int  
Declare @CustMaping Int  
Declare @SchemeStatus Int  
Set DateFormat DMY  
Select @CurDate = DateAdd(s,-1,dbo.StripDateFromTime(getdate()+1))  
  
Select @ValidTo = ValidTo , @Active = Active from Schemes   
Where SchemeID = @SchemeID  
  
if @ValidTo < @CurDate   
Set @SchExp = 1  
Else  
Set @SchExp = 0  
  
Select @ItemMaping = Count(*) from ItemSchemes   
where SchemeID = @SchemeID and Product_code = @ItemCode  
  
If (Select Customer from  Schemes where SchemeID = @SchemeID) = 1  
 Begin  
  Select @CustMaping = count(*) from SchemeCustomers   
  where SchemeID = @SchemeID and CustomerID = @CustCode  
 End  
Else  
 Begin  
  Set @CustMaping = 1  
 End  
  
Select SchemeName , @SchExp As SchExp, @Active As Active , @ItemMaping As ItemMap, 
       @CustMaping As CustMap, ValidFrom, ValidTo 
from Schemes   
Where SchemeID = @SchemeID  
  


