--EXEC spr_list_Invoicewise_Collections_By_Customer 'THOMAS MALIGAI - JAHIR AMMAPALAYAM-SLM5', '04-Apr-2019', '05-Apr-2019', '%'
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'spr_list_Invoicewise_Collections_By_Customer')
BEGIN
	DROP PROC [spr_list_Invoicewise_Collections_By_Customer]
END
GO
CREATE PROCEDURE [dbo].[spr_list_Invoicewise_Collections_By_Customer] (@CustomerName nVarchar(2550), @FromDate datetime,@ToDate datetime,@PaymentMode nVarchar(50))        
As        
      
Declare @Delimeter as nChar(1)            
Set @Delimeter=Char(15)      
      
if @PaymentMode=N'AllCollectionType'      
 set @PaymentMode=N'%'      
      
Declare @OTHERS NVarchar(50)        
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)      
      
Create table #tmpCustomer(CustomerID  nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Company_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
      
if @CustomerName=N'%'             
begin      
   Insert Into #tmpCustomer(CustomerID, Company_Name) Select DISTINCT CustomerID, Company_Name From Customer   
end    
Else            
   Insert into #tmpCustomer  (CustomerID, Company_Name)
   Select DISTINCT CustomerID, Company_Name From Customer
   WHERE Company_Name IN (select x.ItemValue from dbo.sp_SplitIn2Rows(@CustomerName, @Delimeter) x)

CREATE TABLE #TmpCollectionDetails(        
 [DocumentID] [int] NOT NULL,        
 [CollectionID] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,        
 [CollectionReference] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,        
 [CollectionDate] [datetime] NOT NULL,        
 [PaymentMode] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,        
 [CollectionMode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,        
 [DocumentType] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,        
 [DocNumber] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,        
 [DocReference] [nvarchar](125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,        
 [DocDate] [datetime],        
 [CustomerID] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,        
 [CustomerName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,        
 [PayMode] [int] NOT NULL,        
 [SalesmanName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,        
 [DSType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
 [HandheldDS] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,        
 [InvoiceAmount] [decimal](18, 6) NULL,        
 [AmountRecd] [decimal](18, 6) NULL,        
 [AddlAdjustment] [decimal](18, 6) NULL,        
 [AdvanceCollection] [decimal](18, 6) NULL,        
 [TotalCollection] [decimal](38, 6) NULL        
) ON [PRIMARY]        
        
Insert into #TmpCollectionDetails        
SELECT C.DocumentID,        
C.FullDocID [CollectionID], C.DocReference [CollectionReference], Convert(date,C.DocumentDate) [CollectionDate],         
Case isnull(C.PaymentMode,0) When 0 then 'Cash' When 1 then 'Cheque' When 2 then 'DD' When 3 then 'Credit Card' When 4 then 'Bank Transfer' else 'Others' End [PaymentMode],      
[CollectionMode]=Isnull((Select IsNull(DocumentID,0) from Collections where DocumentID=        
(Select CollectionID from Collection_Details where CollectionID=c.DocumentID)),''),        
'Invoice' [DocumentType],        
CD1.OriginalID [DocNumber], CD1.DocRef [DocReference],CD1.DocumentDate [DocDate],        
C.CustomerID,CU.Company_Name  [CustomerName], C.PaymentMode,       
Case C.SalesmanID When 0 then 'Others' Else (Select Salesman_Name from Salesman where SalesmanID=C.SalesmanID) End [SalesmanName],        
[DSType]=(Select DSTypeValue from DSType_Master where DSTypeID =(Select DSTypeID from DSType_Details Where SalesmanID=C.SalesmanID and DSTypeCtlPos=1) and DSTypeCtlPos=1),  
[HandheldDS]=(Select DSTypeValue from DSType_Master where DSTypeID =(Select DSTypeID from DSType_Details Where SalesmanID=C.SalesmanID and DSTypeCtlPos=2) and DSTypeCtlPos=2),    
CD1.DocumentValue [InvoiceAmount], CD1.AdjustedAmount [AmountRecd],CD1.DocAdjustAmount [AddlAdjustment],C.Balance [AdvanceCollection],        
[TotalCollection]=(Select Sum(AdjustedAmount) From CollectionDetail WITH(NOLOCK)         
where CollectionID in(Select DocumentID from Collections WITH(NOLOCK) where (ISNULL(Status, 0) & 64 = 0) AND (ISNULL(Status, 0) & 128 = 0))        
And DocumentID=CD1.DocumentID And Convert(date,C.DocumentDate) <= @Todate and DocumentType=4)        
FROM Collections C WITH(NOLOCK),
Customer CU WITH(NOLOCK),
CollectionDetail CD1 WITH(NOLOCK)        
WHERE (C.DocumentID IN (SELECT DISTINCT CD.CollectionID FROM CollectionDetail AS CD WITH(NOLOCK)         
  INNER JOIN InvoiceAbstract IA WITH(NOLOCK) on CD.DocumentID = IA.InvoiceID          
  WHERE (IsNull(IA.PaymentMode,0) = 0)))        
 AND (ISNULL(C.Status, 0) & 64 = 0)         
 AND (ISNULL(C.Status, 0) & 128 = 0)         
 AND (C.CustomerID <> 'GIFT VOUCHER')         
 AND (C.CustomerID IS NOT NULL)        
 And (C.CustomerId=CU.CustomerID)         
 And (C.DocumentID=CD1.CollectionID)        
 And (CD1.DocumentType=4)        
 And (Convert(date,C.DocumentDate) between @FromDate and @ToDate)        
 AND C.CustomerID In (Select CustomerID from #tmpCustomer WITH(NOLOCK))
        
Insert into #TmpCollectionDetails        
SELECT C.DocumentID,        
C.FullDocID [CollectionID], C.DocReference [CollectionReference], Convert(date,C.DocumentDate) [CollectionDate],         
Case isnull(C.PaymentMode,0) When 0 then 'Cash' When 1 then 'Cheque' When 2 then 'DD' When 3 then 'Credit Card' When 4 then 'Bank Transfer' else 'Others' End [PaymentMode],'0',    
'Debit Note' [DocumentType],CD1.OriginalID [DocNumber], CD1.DocRef [DocReference],CD1.DocumentDate [DocDate],        
C.CustomerID,CU.Company_Name [CustomerName], C.PaymentMode,       
Case C.SalesmanID When 0 then 'Others' Else (Select Salesman_Name from Salesman where SalesmanID=C.SalesmanID) End [SalesmanName],        
[DSType]=(Select DSTypeValue from DSType_Master where DSTypeID =(Select DSTypeID from DSType_Details Where SalesmanID=C.SalesmanID and DSTypeCtlPos=1) and DSTypeCtlPos=1),  
[HandheldDS]=(Select DSTypeValue from DSType_Master where DSTypeID =(Select DSTypeID from DSType_Details Where SalesmanID=C.SalesmanID and DSTypeCtlPos=2) and DSTypeCtlPos=2),    
CD1.DocumentValue [InvoiceAmount], CD1.AdjustedAmount [AmountRecd],CD1.DocAdjustAmount [AddlAdjustment],C.Balance [AdvanceCollection],        
[TotalCollection]=(Select Sum(AdjustedAmount) From CollectionDetail         
where CollectionID in(Select DocumentID from Collections where (ISNULL(Status, 0) & 64 = 0) AND (ISNULL(Status, 0) & 128 = 0))        
And DocumentID=CD1.DocumentID And Convert(date,C.DocumentDate) <= @ToDate  and DocumentType=5)        
FROM Collections C,Customer CU,CollectionDetail CD1        
WHERE (C.DocumentID IN (SELECT DISTINCT CD.CollectionID FROM CollectionDetail AS CD INNER JOIN DebitNote DN on CD.DocumentID = DN.DebitID))        
 AND (ISNULL(C.Status, 0) & 64 = 0)         
 AND (ISNULL(C.Status, 0) & 128 = 0)         
 AND (C.CustomerID <> 'GIFT VOUCHER')         
 AND (C.CustomerID IS NOT NULL)        
 And (C.CustomerId=CU.CustomerID)         
 And (C.DocumentID=CD1.CollectionID)        
 And (CD1.DocumentType=5)        
 And (Convert(date,C.DocumentDate) between @FromDate and @ToDate)        
 AND C.CustomerID In (Select CustomerID from #tmpCustomer)        
        
Insert into #TmpCollectionDetails        
SELECT C.DocumentID,        
C.FullDocID [CollectionID], C.DocReference [CollectionReference], Convert(date,C.DocumentDate) [CollectionDate],         
Case isnull(C.PaymentMode,0) When 0 then 'Cash' When 1 then 'Cheque' When 2 then 'DD' When 3 then 'Credit Card' When 4 then 'Bank Transfer' else 'Others' End [PaymentMode],         
[CollectionMode]=Isnull((Select IsNull(DocumentID,0) from Collections where DocumentID=        
(Select CollectionID from Collection_Details where CollectionID=c.DocumentID)),''),        
'Advance Collection' [DocumentType],        
'' [DocNumber], '' [DocReference],Convert(date,C.DocumentDate) [DocDate],        
C.CustomerID,CU.Company_Name  [CustomerName],C.PaymentMode,      
Case C.SalesmanID When 0 then 'Others' Else (Select Salesman_Name from Salesman where SalesmanID=C.SalesmanID) End [SalesmanName],    
[DSType]=(Select DSTypeValue from DSType_Master where DSTypeID =(Select DSTypeID from DSType_Details Where SalesmanID=C.SalesmanID and DSTypeCtlPos=1) and DSTypeCtlPos=1),  
[HandheldDS]=(Select DSTypeValue from DSType_Master where DSTypeID =(Select DSTypeID from DSType_Details Where SalesmanID=C.SalesmanID and DSTypeCtlPos=2) and DSTypeCtlPos=2),        
 0.00 [InvoiceAmount], 0.00 [AmountRecd],0.00 [AddlAdjustment],C.Balance [AdvanceCollection],        
 0.00 [TotalCollection]        
FROM Collections C,Customer CU        
WHERE (C.DocumentID Not IN (Select Distinct CollectionID From CollectionDetail))        
 AND (ISNULL(C.Status, 0) & 64 = 0)         
 AND (ISNULL(C.Status, 0) & 128 = 0)         
 AND (C.CustomerID <> 'GIFT VOUCHER')         
 AND (C.CustomerID IS NOT NULL)        
 And (C.CustomerId=CU.CustomerID)        
 And (Convert(date,C.DocumentDate) between @FromDate and @ToDate)   
 AND C.CustomerID In (Select CustomerID from #tmpCustomer)     
        
        
Select DocumentID,CollectionID,CollectionReference,CollectionDate,PaymentMode,        
Case CollectionMode        
When 0 then 'Normal Collection'        
else 'Handheld Collection' End [CollectionMode],DocumentType,DocNumber,DocReference,        
DocDate,CustomerID,CustomerName,SalesmanName,DSType,HandheldDS,InvoiceAmount,        
AmountRecd,AddlAdjustment,AdvanceCollection [ExtraCollection],TotalCollection from #TmpCollectionDetails Where CustomerID In (Select CustomerID from #tmpCustomer)      
and       
cast(PayMode as nvarchar) like           
 (case @PaymentMode when 'Cash' then '0'           
 when 'Cheque' then '1'           
 when 'DD' then '2'           
 when 'Credit Card' then '3'           
 when 'Bank Transfer' then '4'        
 when 'Coupon' then '5'           
 else '%' end)      
Order by CollectionMode,DocDate,SalesmanName,DocumentType,PaymentMode  
   
Drop Table #TmpCollectionDetails    
Drop Table #tmpCustomer  
  
SET QUOTED_IDENTIFIER OFF

