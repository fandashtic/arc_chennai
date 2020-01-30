
Create Procedure spr_ser_Month_wise_sales_wise_Beat (@CatName varchar(2550), 
@Beat varchar(2550),@FromDate datetime, @ToDate datetime)      
As        

Declare @Delimeter as Char(1)  
Set @Delimeter = Char(15)  

Create Table #TmpCat(CategoryName varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Create Table #TmpBeat(BeatName varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  

If @CatName='%'   
	Insert Into #TmpCat Select Category_Name From ItemCategories  
Else  
	Insert Into #TmpCat	Select * From dbo.sp_SplitIn2Rows(@CatName,@Delimeter)  
  
If @Beat='%'  
	Insert Into #TmpBeat Select Description From Beat  
Else  
	Insert Into #TmpBeat Select * From dbo.sp_SplitIn2Rows(@Beat,@Delimeter)  


Create Table #Temp(CategoryId Int, 
Category_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Status Int)        
Declare @Continue Int        
Declare @CategoryId Int        

Set @Continue = 1        

Insert Into #Temp 
Select CategoryId,Category_Name,0 
From ItemCategories 
Where Category_Name In (Select CategoryName COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpCat) 

If @CatName not like '%' 
Begin
	While @Continue > 0 
	Begin        
		Declare Parent Cursor Static For        
		Select CategoryId From #Temp Where Status = 0        
		Open Parent   
		Fetch From Parent Into @CategoryId        
		While @@Fetch_Status = 0        
		Begin        
			Insert Into #Temp 
			Select CategoryId, Category_Name, 0 
			From ItemCategories 
			Where ParentID = @CategoryId        
			
			Update #Temp Set Status = 1 Where CategoryId = @CategoryId        
			Fetch Next From Parent Into @CategoryId        
		End        
		Close Parent        
		DeAllocate Parent        

		Select @Continue = Count(*) From #Temp 	Where Status = 0        
	End        
End -- End for Cat rec code

Create Table #Temp1 (Beatid Int, 
[Description] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
invMonth Int, netvalue Decimal(18,6))    

If @Beat='%'  
Begin
	--Invoice
	Insert Into #Temp1    
	Select  IsNull(Beat.Beatid,0), 
	Case IsNull(Beat.Beatid,0) when 0 then 'Others' Else Beat.Description End, 
	Month(InvoiceAbstract.Invoicedate),     
	Sum(Case Invoicetype when 4 then (0 - (Amount)) Else (Amount) End )     
	From Beat 
	Right Outer Join InvoiceAbstract On Beat.Beatid = InvoiceAbstract.Beatid
	And Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBeat) 
	Inner Join InvoiceDetail On InvoiceAbstract.InvoiceId = InvoiceDetail.InvoiceId  	
	And InvoiceAbstract.Invoicedate between @Fromdate And @Todate    	
	And InvoiceAbstract.Invoicetype in (1,2,3,4)
	And (InvoiceAbstract.Status & 128) = 0 
	Inner Join Items On Items.Product_Code = InvoiceDetail.Product_Code 
	Inner Join ItemCategories On Items.CategoryId = ItemCategories.CategoryId 
	And ItemCategories.CategoryId in (Select CategoryId From #Temp) 
	Group By Month(InvoiceAbstract.InvoiceDate),
	Beat.Beatid, Beat.Description, InvoiceType     
	--Service Invoice
	Insert Into #Temp1    
	Select  0 ,'Others',
	Month(SerAbs.ServiceInvoicedate),     
	Sum(IsNull(SerDet.NetValue,0))     
	From ServiceInvoiceAbstract SerAbs Inner Join ServiceInvoiceDetail SerDet
	On SerAbs.ServiceInvoiceId = SerDet.ServiceInvoiceId 
	Inner Join Items On Items.Product_Code = SerDet.SpareCode 
	Inner Join ItemCategories On Items.CategoryId = ItemCategories.CategoryId 
	And ItemCategories.CategoryId in (Select CategoryId From #Temp) 
	And IsNull(SerAbs.Status,0) & 192 = 0  
	And IsNull(SerAbs.ServiceInvoiceType,0) = 1 
	And ServiceInvoicedate between @Fromdate And @Todate    
	Group By Month(SerAbs.ServiceInvoiceDate)    
End
Else
	--Particular Beat For Invoice
	Insert into #Temp1
	Select  IsNull(Beat.Beatid,0), 
	Beat.Description , 
	Month(InvoiceAbstract.Invoicedate),     
	Sum(Case Invoicetype when 4 then (0 - (Amount)) Else (Amount) End )     
	From Beat 
	Inner Join InvoiceAbstract On Beat.Beatid = InvoiceAbstract.Beatid 
	And Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBeat) 
	Inner Join InvoiceDetail On InvoiceAbstract.InvoiceId = InvoiceDetail.InvoiceId 
	And InvoiceAbstract.Invoicedate Between @Fromdate And @Todate
	And (InvoiceAbstract.Status & 128) = 0  
	And InvoiceAbstract.Invoicetype in (1,2,3,4)
	Inner Join Items On Items.Product_Code = InvoiceDetail.Product_Code 
	Inner Join ItemCategories On Items.CategoryId = ItemCategories.CategoryId 
	And ItemCategories.CategoryId in (Select CategoryId From #Temp)
	Group By Month(InvoiceAbstract.InvoiceDate),Beat.Beatid, 
	Beat.Description, InvoiceType    

Create Table #Temp2 (Beatid Int, 
[Description] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,     
January Decimal(18,6),  February Decimal(18,6), March Decimal(18,6), 
April Decimal(18,6), May Decimal(18,6), June Decimal(18,6), 
July Decimal(18,6), August Decimal(18,6), September Decimal(18,6), 
October Decimal(18,6), November Decimal(18,6), December Decimal(18,6))

Insert Into #Temp2    
-- Initialize values to 0 for all Months
Select distinct Beatid, 
[Description] , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
From #Temp1    

Declare @Beat_id Int     
Declare @Inv_Month Int    
Declare @Net_Value Decimal(18,6)    
Declare @Jan Decimal(18,6) Declare  @Feb Decimal(18,6) Declare  @Mar Decimal(18,6) 
Declare @Apr Decimal(18,6) Declare  @May Decimal(18,6) Declare  @Jun Decimal(18,6)    
Declare @Jul Decimal(18,6) Declare  @Aug Decimal(18,6) Declare  @Sep Decimal(18,6) 
Declare @Oct Decimal(18,6) Declare  @Nov Decimal(18,6) Declare  @Dec Decimal(18,6)    

--Declaring Cursor    
Declare Beat_Cursor Cursor for 
Select Beatid, invMonth, Sum(Netvalue) From #Temp1 Group By BeatId,InvMonth
Open Beat_Cursor    
Fetch Next From Beat_Cursor Into @Beat_id , @Inv_Month, @Net_Value    
While @@Fetch_Status = 0    
Begin    
	Set @Jan = 0 Set @Feb = 0 Set @Mar = 0 Set @Apr = 0 Set @May = 0 Set @Jun = 0     
	Set @Jul = 0 Set @Aug = 0 Set @Sep = 0 Set @Oct = 0 Set @Nov = 0 Set @Dec = 0    

	If @Inv_Month =  1  Set @Jan = @Net_Value     
	If @Inv_Month =  2  Set @Feb = @Net_Value    
	If @Inv_Month =  3  Set @Mar = @Net_Value    
	If @Inv_Month =  4  Set @Apr = @Net_Value    
	If @Inv_Month =  5  Set @May = @Net_Value    
	If @Inv_Month =  6  Set @Jun = @Net_Value    
	If @Inv_Month =  7  Set @Jul = @Net_Value    
	If @Inv_Month =  8  Set @Aug = @Net_Value    
	If @Inv_Month =  9  Set @Sep = @Net_Value    
	If @Inv_Month =  10 Set @Oct = @Net_Value    
	If @Inv_Month =  11 Set @Nov = @Net_Value    
	If @Inv_Month =  12 Set @Dec = @Net_Value    

	Update #Temp2 Set 
	January = IsNull(January,0) + @Jan ,February = IsNull(February,0) + @Feb , 
	March = IsNull(March,0) + @Mar,April = IsNull(April,0) + @Apr, 
	May = IsNull(May,0) + @May, June = IsNull(June,0) + @Jun,     
	July = IsNull(July,0) + @Jul, August = IsNull(August,0) + @Aug, 
	September = IsNull(September, 0) + @Sep,October = IsNull(October,0) + @Oct, 
	November = IsNull(November,0) + @Nov, December = IsNull(December,0) + @Dec    
	Where Beatid = @Beat_Id    

	Set @Jan = 0 Set @Feb = 0 Set @Mar = 0 Set @Apr = 0 
	Set @May = 0 Set @Jun = 0 Set @Jul = 0 Set @Aug = 0 
	Set @Sep = 0 Set @Oct = 0 Set @Nov = 0 Set @Dec = 0    

	Fetch Next From Beat_Cursor Into @Beat_id , @Inv_Month, @Net_Value    
End    

Select * From #Temp2    
Close Beat_Cursor    
Deallocate Beat_Cursor    

Drop Table #Temp    
Drop Table #Temp1    
Drop Table #Temp2 
Drop Table #TmpCat
Drop Table #TmpBeat

