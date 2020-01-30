CREATE procedure FixOpeningItemsMisMatch_Specific (
@ProdCode nvarchar(50),
@FromDate DateTime = Null
)
as  
begin  
  
--This procedure is to insert missing Item data for the date(s) between  
--Min(Opening_Date) and Max(Opening_Date)  
Set DateFormat DMY
Declare @MinDate DateTime  
Declare @MaxDate DateTime  
Declare @OpenDate DateTime  
Declare @Query nvarchar(500)  
Declare @Rowcnt Int

--Select @MinDate = Min(Opening_Date) From OpeningDetails  
Select @MinDate = @FromDate
If @MinDate Is Null
Select @MinDate = Max(OpeningDate) From Setup

Select @MaxDate = Max(Opening_Date) From OpeningDetails  

If @MaxDate < (Select dbo.StripDateFromTime(Max(TransactionDate)) From Setup)
	Select @MaxDate = dbo.StripDateFromTime(Max(TransactionDate)) From Setup

--For the given item only
Set @OpenDate = @MinDate  
--From Min(Opening_Date) to Max(Opening_Date) in Setup  

While @OpenDate <= @MaxDate
begin  
	Select @Rowcnt = Count(*) From OpeningDetails Where Product_Code = @ProdCode And Opening_Date = @OpenDate
	If IsNull(@Rowcnt,0) = 0
		Insert Into OpeningDetails values (@ProdCode, @OpenDate, 0, 0, 0, 0, 0, 0, 0, 0)
	If IsNull(@Rowcnt,0) > 1
	Begin
		Delete From OpeningDetails Where Product_Code = @ProdCode And Opening_Date = @OpenDate
		Insert Into OpeningDetails values (@ProdCode, @OpenDate, 0, 0, 0, 0, 0, 0, 0, 0)
	End
	Set @OpenDate = DateAdd(d,1,@OpenDate)  
End  

Exec FixOpeningDetails_Specific @ProdCode, @FromDate
----Call FixOpeningDetails to update the OpeningQuantity  
--If Exists (Select * From SysColumns Where Name = 'PTS' And ID = (Select ID From Sysobjects Where Name = 'Items'))  
--Begin  
-- --Pharma version  
-- set @Query = 'FixOpeningDetails_Specific'
--End  
--else  
--Begin  
-- --FMCG version  
-- set @Query = 'FixOpeningDetails_Specific_FMCG'
--End  
--If Exists (Select * From Sysobjects Where Name = @Query)  
--Begin  
-- --SP Exists  
-- Exec ('Exec ' + @Query + ' ''' + @ProdCode + '''')  
--End  
End
