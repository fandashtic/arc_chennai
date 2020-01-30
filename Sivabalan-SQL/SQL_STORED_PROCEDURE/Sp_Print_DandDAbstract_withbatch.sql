
Create Procedure Sp_Print_DandDAbstract_withbatch(@ID Int)  
AS  
  
Declare @CategoryName nvarchar(4000)  
Declare @BrandName nvarchar(510)  
Declare @CategoryID Int  
Declare @Remarks nvarchar(1000)  
  
Set @CategoryName = ''  
Set @BrandName = ''  
Set @Remarks = ''  
  
Declare Cur_Category Cursor For  
Select CategoryID From DandDCategory Where ID = @ID  
Open Cur_Category  
Fetch From Cur_Category Into @CategoryID  
While @@Fetch_Status = 0  
 Begin  
  Select @BrandName = IsNull(Category_Name, '') from ItemCategories Where CategoryID = @CategoryID    
  Set @CategoryName = @CategoryName + @BrandName + ','  
  Fetch Next From Cur_Category Into @CategoryID  
 End  
Close Cur_Category  
Deallocate Cur_Category  
  
IF LEN(@CategoryName) > 0  
 Set @CategoryName = SUBSTRING(@CategoryName, 1, LEN(@CategoryName) - 1)   
  
--Select @Remarks = Remarks + ' From ' + FromMonth + ' To ' + ToMonth  
--From DandDAbstract Where ID = @ID  

Select @Remarks = RemarksDescription
From DandDAbstract Where ID = @ID  
  
Create Table #tmpCount(Product_code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,Batch_Number nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
						,PTS Decimal(18, 6), TaxSuffered Decimal(18, 6) )  
Insert into #tmpCount  
Select D.product_code,BP.Batch_Number, D.PTS, D.TaxSuffered from DandDDetail D,Batch_Products BP where D.ID=@ID   
 and D.Product_code=BP.Product_code   
 and D.Batch_code=BP.Batch_code  
 Group by D.product_code,BP.Batch_Number, D.PTS, D.TaxSuffered  
Select   
 "Item Count" = (SELECT COUNT(*) FROM #tmpCount),  
 "Task Number" = DocumentID,  
 "Category" = @CategoryName,  
 "Date" = ClaimDate,   
    "Last Day Close Date" = DayCloseDate,  
 "Remarks" = @Remarks  
From  
 DandDAbstract DA,DandDDetail DD  
Where  
 DA.ID = @ID  
 And DA.ID=DD.ID  
 Group by DocumentID,ClaimDate,DayCloseDate  
Drop Table #tmpCount  

