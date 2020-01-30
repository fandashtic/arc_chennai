CREATE procedure FixOpeningItemsMisMatch  
as  
begin  
  
--This procedure is to insert missing Items for the date(s) between  
--Min(Opening_Date) and Max(Opening_Date)  
  
Declare @MinDate DateTime  
Declare @MaxDate DateTime  
Declare @OpenDate DateTime  
Declare @ProdCode nvarchar(50)  
Declare @Query nvarchar(500)  
  
Select @MinDate = Min(Opening_Date) From OpeningDetails  
Select @MaxDate = Max(Opening_Date) From OpeningDetails  
  
Declare ItemsCursor Cursor  
for  
select Product_Code from Items  
Open ItemsCursor  
Fetch Next From ItemsCursor Into @ProdCode  
 --For all Items in Items table  
 While @@FETCH_STATUS = 0  
 begin  
  Set @OpenDate = @MinDate  
  --From Min(Opening_Date) to Max(Opening_Date) in Setup  
  While @OpenDate <= @MaxDate
  begin  
   If Not Exists (Select @ProdCode From OpeningDetails Where Product_Code = @ProdCode And Opening_Date = @OpenDate)  
   Begin  
    --Insert the Item with Date and values as zero  
    insert into OpeningDetails values (@ProdCode, @OpenDate, 0, 0, 0, 0, 0, 0, 0, 0)  
   End  
   Set @OpenDate = DateAdd(d,1,@OpenDate)  
  end  
  Fetch Next From ItemsCursor Into @ProdCode  
 end  
Close ItemsCursor  
Deallocate ItemsCursor  
  
--Call FixOpeningDetails to update the OpeningQuantity  
If Exists (Select * From SysColumns Where Name = 'PTS' And ID = (Select ID From Sysobjects Where Name = 'Items'))  
Begin  
 --Pharma version  
 set @Query = 'FixOpeningDetails'  
End  
else  
Begin  
 --FMCG version  
 set @Query = 'FixOpeningDetails_FMCG'  
End  
If Exists (Select * From Sysobjects Where Name = @Query)  
Begin  
 --SP Exists  
 Exec ('Exec ' + @Query)  
End  
End  
  
  


