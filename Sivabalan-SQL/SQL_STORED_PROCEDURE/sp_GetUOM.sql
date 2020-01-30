

CREATE Procedure sp_GetUOM(  
  @FromDate datetime,   
  @ToDate datetime,  
  @SegmentIDs nvarchar(2000))  
  
As  
	Declare @UomUnique as int  
	Declare @Delimeter as Char(1)    
	Set @Delimeter=Char(44) -- Char(44) - for (,) Comma Delimeter  
	Create Table #TmpSegmentIDs(SegmentID int)  
	Insert into  #TmpSegmentIDs Select * from dbo.sp_SplitIn2Rows(@SegmentIDs,@Delimeter)  
	Create Table #TmpCustList (CustCode Varchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	Insert into  #TmpCustList   Select CustomerID From Customer where SegmentID in (Select SegmentID from #TmpSegmentIDs)  
	
	Select Count(Distinct(Items.UOM) ) From Items,InvoiceAbstract,InvoiceDetail  
	WHERE   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And   
	InvoiceAbstract.InvoiceType in (1,4) And  
	(InvoiceAbstract.Status & 128) = 0 And   
	InvoiceAbstract.InvoiceDate Between @FromDate and @ToDate And   
	InvoiceAbstract.CustomerID in (Select CustCode  from #TmpCustList) And  
	Items.Product_Code = InvoiceDetail.Product_Code  
	
	Drop Table #TmpCustList
	Drop Table #TmpSegmentIDs


