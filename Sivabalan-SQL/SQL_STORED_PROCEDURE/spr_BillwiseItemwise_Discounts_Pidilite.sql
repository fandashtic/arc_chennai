CREATE Procedure spr_BillwiseItemwise_Discounts_Pidilite  
(         
@VendorID nVarchar(50),        
@FromDate DateTime,         
@ToDate DateTime  
)        
AS        
  
Declare @AlterSQL nVarchar(200)        
Declare @UpdateSQL nVarchar(200)        
Declare @Description nVarchar(20)        
Declare @DiscPerc Decimal(18,6)  
Declare @DiscAmount Decimal(18,6)  
Declare @BillID nVarchar(20)        
Declare @Delimeter as Char(1)    
Declare @Field_Str nVarchar(2000)        

Set @Delimeter=Char(15)    
  
Create Table #Vendors (VendorID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
  
If @VendorID='%'   
 Insert into #Vendors Select VendorID From Vendors  
Else  
 Insert into #Vendors select VendorID From Vendors Where Vendor_Name In (Select * from dbo.sp_SplitIn2Rows(@VendorID,@Delimeter))
  
  
Create Table #BillDiscount ([Bill ID] nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS, [DocID] nvarchar(10), 
[Bill Reference] nVarchar(20), [Gross Value] Decimal(18,6),
[Trade Discount%] Decimal(18,6),[Trade Discount] Decimal(18,6),[Addl.Discount%] Decimal(18,6),[Addl.Discount] Decimal(18,6),  
[Total Discount] Decimal(18,6), [Amount After Discount] Decimal(18,6),
Freight Decimal(18,6),[Octroi%] Decimal(18,6), [Octroi Amount] Decimal(18,6), NetValue Decimal(18,6))  

Insert into #BillDiscount ([Bill ID],[DocID],[Bill Reference],[Gross Value],
[Trade Discount%],[Trade Discount],[Addl.Discount%],[Addl.Discount],  
[Total Discount],
[Amount After Discount],  
[Freight],[Octroi%],[Octroi Amount],[NetValue])  

Select BA.BillID,
Case WHEN BA.DocumentReference IS NULL THEN  
BillPrefix.Prefix + CAST(BA.DocumentID AS nVARCHAR)  
ELSE  
BillAPrefix.Prefix + CAST(BA.DocumentID AS nVARCHAR)  
END,
BA.BillReference, (Select Sum(BD.Quantity * BD.PurchasePrice) From BillDetail BD Where BillID = BA.BillID),  
BA.Discount,
(Select Sum(BD.Quantity * BD.PurchasePrice) From BillDetail BD Where BillID = BA.BillID) * (BA.Discount /100),
BA.AddlDiscountPercentage,
BA.AddlDiscountAmount, 
(Select Sum(BD.Quantity * BD.PurchasePrice) From BillDetail BD Where BillID = BA.BillID) * (BA.Discount /100) + BA.AddlDiscountAmount + BA.ProductDiscount,
((Select Sum(BD.Quantity * BD.PurchasePrice) From BillDetail BD Where BillID = BA.BillID)) - ((Select Sum(BD.Quantity * BD.PurchasePrice) From BillDetail BD Where BillID = BA.BillID) * (BA.Discount /100) + BA.AddlDiscountAmount + BA.ProductDiscount),
BA.Freight,(Select Sum(OctroiPercentage) From BillDetail BD Where BillID = BA.BillID),BA.OctroiAmount,BA.Value   

From BillAbstract BA , VoucherPrefix BillPrefix,VoucherPrefix BillAPrefix    
Where BA.VendorID In (Select VendorID From #Vendors)  
And BillDate Between @FromDate And @ToDate  
And (isnull(BA.Status, 0) & 192) = 0      
And BillPrefix.TranID = 'BILL'
And BillAPrefix.TranID = 'BILL AMENDMENT'
Order by BA.BillDate  
  
      
Declare DiscDesc Cursor For      
Select Distinct DiscDescription From BillDiscountMaster  
      
Set @Field_Str = ''      
Open DiscDesc       
Fetch from DiscDesc Into @Description      
     
WHILE @@FETCH_STATUS = 0                    
BEGIN      
      
 SET @AlterSQL = 'ALTER TABLE #BillDiscount Add [' + Cast(@Description as nvarchar) + '% ] Decimal(18,6) null'            
 Set @Field_Str = @Field_Str + '['+ Cast(@Description as nvarchar) + '%], '      
 EXEC sp_executesql @AlterSQL                    
  
 SET @AlterSQL = 'ALTER TABLE #BillDiscount Add [' + Cast(@Description as nvarchar) + ' ] Decimal(18,6) null'                 
 Set @Field_Str = @Field_Str + '['+Cast(@Description as nvarchar) + '], '      
 EXEC sp_executesql @AlterSQL                     
      
 FETCH NEXT FROM DiscDesc INTO @Description         
END      
      
      
Close DiscDesc  
     
Declare DiscValue Cursor for      
Select DiscDescription,sum(DiscountPercentage) DiscountPercentage,
sum(DiscountAmount) DiscountAmount,BA.BillID  
from BillAbstract BA, BillDiscount BD,BillDiscountMaster BDM  
Where BA.BillID = BD.BillID   
And BA.VendorID In (Select VendorID From #Vendors)   
And BA.BillDate Between @FromDate And @ToDate  
And (isnull(BA.Status, 0) & 192) = 0      
And BD.DiscountID = BDM.DiscountID  
group by DiscDescription,ba.BillID

Open DiscValue       
Fetch From DiscValue Into @Description,@DiscPerc,@DiscAmount,@BillID  
      
WHILE @@FETCH_STATUS = 0                    
BEGIN      
      
  SET @UpdateSQL = 'Update #BillDiscount Set [' + @Description + '% ] = isnull((' + Cast(@DiscPerc as nvarchar) + '),0) Where [Bill ID] = ''' + Cast(@BillID as nvarchar)  +''''  
  exec sp_executesql @UpdateSQL                   
        
  SET @UpdateSQL = 'Update #BillDiscount Set [' + @Description + ' ] = isnull((' + Cast(@DiscAmount as nvarchar) + '),0) Where [Bill ID] = ''' + Cast(@BillID as nvarchar)  +''''  
  exec sp_executesql @UpdateSQL                   
      
Fetch Next From DiscValue Into @Description,@DiscPerc,@DiscAmount,@BillID  
END      
      
Close DiscValue  
  
DeAllocate DiscDesc      
DeAllocate DiscValue      
  
Set @Field_Str = 'Select [Bill ID],"Bill ID" = [DocID],[Bill Reference],[Gross Value],' + @Field_Str + '[Addl.Discount%],[Addl.Discount],[Trade Discount%],[Trade Discount],[Total Discount],[Amount After Discount],Freight, [Octroi%], [Octroi Amount], NetValue From #BillDiscount order by DocID'  
exec (@Field_Str)  
      
Drop Table #BillDiscount      
Drop table #Vendors  



