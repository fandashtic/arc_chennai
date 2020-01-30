CREATE procedure sp_InvoiceHistory_Detail_DataExport (@FromDate as datetime,@ToDate as DateTime,@SalesmanID as nvarchar(255) )  
AS   
Select IA.InvoiceID as SO_NO
,ID.Serial as ORD_DTL_ID
,PRD_IND ='N'
,ID.Product_Code as PRODUCT_CD
,TYPE = 'S'
,Items.UOM as TXN_UOM_CD
,sum(ID.Quantity) as TXN_QTY
,TXN_UOM_CONV = 1
,Items.UOM as TARGET_UOM_CD
,sum(ID.Quantity) as TARGET_QTY 
,null as TARGET_QTY_ON_BASEUOM
,Items.MRP as LIST_PRICE
,Items.PTR as SELL_PRICE
,null as DISC_AMT
,null as DISC_PERCENTAGE
,null as NET_AMT
,null as LINK_PRODUCT_CD
,null as SCHEME_CD    
from invoiceabstract IA inner join InvoiceDetail ID on IA.InvoiceID = ID.InvoiceID   
inner join Items on ID.Product_Code = Items.Product_Code 
where  IA.InvoiceDate BETWEEN @FROMDATE AND @TODATE 
	and  IA.SalesmanID in (select  * from dbo.sp_SplitIn2Rows(@SalesmanID, ','))  
	and (isnull(IA.Status,0) & 128 ) = 0 
	and (isnull(IA.Status,0) & 64 ) = 0 
	and IA.InvoiceType in (1,3)
Group by IA.InvoiceID,ID.Serial,ID.Product_Code ,Items.UOM,Items.MRP,Items.PTR 

