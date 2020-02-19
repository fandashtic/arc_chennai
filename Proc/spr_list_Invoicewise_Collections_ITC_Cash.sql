--Exec ARC_Insert_ReportData 374, 'Collections Report', 1, ' spr_list_Invoicewise_Collections_ITC_Cash', 'View InvoiceWise Collections', 151, 76, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
--exec spr_list_Invoicewise_Collections_ITC_Cash '%','2020-02-17 00:00:00','2020-02-19 23:59:59','Cash'
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'spr_list_Invoicewise_Collections_ITC_Cash')
BEGIN
	DROP PROC [spr_list_Invoicewise_Collections_ITC_Cash]
END
GO
CREATE PROCEDURE [dbo].[spr_list_Invoicewise_Collections_ITC_Cash] (@Salesman nVarchar(2550), @FromDate datetime,@ToDate datetime,@PaymentMode nVarchar(50))        
As        
     SET DATEFORMAT DMY
Create table #tmpSalesMan(SalesmanID INT)     

if @PaymentMode=N'AllCollectionType'      
 set @PaymentMode=N'%'
      
if @Salesman = '%'             
begin      
   Insert Into #tmpSalesMan Select distinct SalesmanID From SalesMan WITH (NOLOCK)
end    
Else      
begin  
   Insert into #tmpSalesMan 
   select distinct SalesmanID From Salesman WITH (NOLOCK) Where Salesman_Name in (select * from dbo.sp_SplitIn2Rows(@Salesman, ',') )
end

SELECT 1,
		CO.DocumentID,
		CO.CollectionDate,
		CO.CustomerId,
		(SELECT TOP 1 Company_Name FROM Customer WITH (NOLOCK) WHERE CustomerID = CO.CustomerId) [CustomerName], 
		CO.SalesmanID,
		Case CO.SalesmanID When 0 then 'Others' Else (Select Salesman_Name from Salesman WITH (NOLOCK) where SalesmanID = CO.SalesmanID) End [SalesmanName],
		CO.BeatID,
		Case CO.BeatID When 0 then 'Others' Else (Select Description from Beat WITH (NOLOCK) where BeatID = CO.BeatID) End [BeatName],
		CO.CollectionId,
		CO.CollectionAmount,
		CO.InvoiceReference,
		((case cast(CO.Paymentmode as nvarchar) 
		 when '0' then  'Cash'           
		 when '1'  then 'Cheque'             
		 when  '2' then 'DD'            
		 when '3'   then 'Credit Card'           
		 when  '4'  then 'Bank Transfer'        
		 when '5' then 'Coupon'            
		 else 'Others' end)) PaymentType,
		Case CO.DocumentID When 0 then 'Normal Collection' else 'Handheld Collection' End [CollectionMode],
		CO.ChequeDate,
		CO.ChequeNumber,
		CO.ChequeDetails,
		CO.DepositDate,
		CO.BankCode,
		CO.BranchCode,
		CO.ClearingAmount,
		CO.Realised,
		CO.RealiseDate,
		CO.BankCharges,
		CO.ExtraCollection,
		CO.Adjustment
	FROM 
	V_ARC_Collections CO WITH (NOLOCK)
	JOIN #tmpSalesMan S WITH (NOLOCK) ON S.SalesmanID = CO.SalesmanID
	WHERE dbo.StripDateFromTime(CO.CollectionDate) Between @FromDate AND @ToDate
	AND cast(CO.Paymentmode as nvarchar) like           
	 (case @PaymentMode when 'Cash' then '0'           
	 when 'Cheque' then '1'           
	 when 'DD' then '2'           
	 when 'Credit Card' then '3'           
	 when 'Bank Transfer' then '4'        
	 when 'Coupon' then '5'           
	 else '%' end)
	

	Drop table #tmpSalesMan
  
SET QUOTED_IDENTIFIER OFF
Go

