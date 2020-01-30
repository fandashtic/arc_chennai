CREATE PROCEDURE [dbo].[Sp_AbstractSend](@DOCTYPE as nvarchar(20),@CID as int)                  
AS                  
DECLARE @CLPRID nvarchar(20)                  
Declare @DocumentType nvarchar(1024)  
                
If CharIndex(N';',@DocType)>0   
 Set @DocumentType = Substring(@DocType,1,CharIndex(N';',@DocType)-1)  
Else  
 Set @DocumentType=@DocType  
  
IF @DocumentType = N'Claims'                   
BEGIN                  
  SELECT @CLPRID = prefix  FROM voucherprefix WHERE tranid = N'CLAIMS NOTE'                  
  SELECT "ClaimID" = cast(@CLPRID as nvarchar) + cast(cn.CLaimID as nvarchar) , "ClaimDate" = convert(char(10),cn.ClaimDate,103) ,cn.ClaimType ,"CustomerID"=isnull(vn.alternatecode,vn.vendorid), cn.DocumentReference ,cn.ClaimValue                  
  FROM claimsnote cn, vendors   vn                
  WHERE cn.claimid = @CID and vn.vendorid = cn.vendorid                
END                  
ELSE IF @DocumentType = N'Collection'                   
BEGIN            
 SELECT "CollectionID" = FullDocID, "DocumentDate" = dbo.StripDateFromTime(DocumentDate), "Value" = Coll.Value, "Balance" = Coll.Balance,             
 "PaymentMode" = Coll.PaymentMode, "ChequeNumber" = Coll.ChequeNumber,            
 "ChequeDate" = dbo.StripDateFromTime(ChequeDate), "ChequeDetails" = ChequeDetails, "CustomerID" = AlternateCode,             
 "Bank" = BankMaster.BankName, "Branch" = BranchName, "Beat" = Description,             
 "DocReference" =(Case DocReference When N'' then N'FORUM*UDH*FIX' Else            
 Cast(IsNull(DocReference,N'FORUM*UDH*FIX') As nvarchar) End) ,"DocumentReference"=DocumentReference           
 FROM Collections Coll
 Left Join Customer on Coll.CustomerID = Customer.CustomerID 
 Left Join BankMaster on Coll.BankCode = BankMaster.BankCode
 Left Join BranchMaster on Coll.BranchCode = BranchMaster.BranchCode 
 Left Join Beat on Coll.BeatID = Beat.BeatID  
--, Customer, BankMaster, BranchMaster, Beat            
 WHERE Coll.DocumentID = @CID
--Coll.CustomerID *= Customer.CustomerID            
-- And Coll.BankCode *= BankMaster.BankCode            
-- And Coll.BranchCode *= BranchMaster.BranchCode             
-- And Coll.BeatID *= Beat.BeatID            
-- And Coll.DocumentID = @CID            
End          
ELSE IF @DocumentType = N'SO'                   
BEGIN          
 Declare @Branch nvarchar(255)  
 Set @Branch=N''  
 Declare @owner nvarchar(255)  
 Select @owner=RegisteredOwner From Setup  
  
  
If CharIndex(N';',@Doctype)>0  
   Begin   
  
  Set @DocType=SubString (@DocType,charindex(N';',@DocType)+1,Len(@DocType))  
  
  Set @Branch=@DocType    
   End  
    
   SELECT                   
 "Soid" = (SELECT Isnull(Prefix,N'SO') FROM VoucherPrefix WHERE TranID = N'SALE CONFIRMATION') +N''+ convert(nvarchar,@Cid) ,          
 "SOSerialNo" =@owner +N'/'+ convert(nvarchar,@Cid),          
 "CompId" = @owner,          
 "OrgId" = @owner,          
 "CustomerID"= case            
    When len(@Branch)=0 then           
    Isnull(CustomerID,N'')           
        Else           
    (select isnull(AlternateCode,CUSTOMERID) From Customer           
    where Customerid = SoAbstract.Customerid)           
    end, -- This Should Be handled.ENH_LAPTOP=1 and BranchCode <> Null then Custom5 =1 else N''          
        "DTLocationId" = N'TN',          
        "CustomerMessage" = N'',          
        "Memo" = N'',          
        "BillToAddress" = BillingAddress,          
        "ShipToAddress" = ShippingAddress,          
        "PODate" = N'',          
        "Terms" = N'',          
        "Representative" = N'',          
        "DiscountType" = N'',          
        "Amount" = Isnull(VALUE,0),          
        "SODate" = isnull(convert(nvarchar,day(Sodate))+N'/'+convert(nvarchar,month(Sodate))+N'/'+Convert(nvarchar,Year(Sodate)),N''),          
        "AgreedDelivTime" = N'',          
        "SalesOrg" = N'',          
        "DistributionChannel" = N'',          
        "Division" = N'',          
        "RequiredDate" =isnull(convert(nvarchar,day(DeliveryDate))+N'/'+convert(nvarchar,month(DeliveryDate))+N'/'+Convert(nvarchar,Year(DeliveryDate)),N''),          
        "SalesGroup" = N'',          
        "SalesOffice" = N'',          
        "POMethod" = N'',          
        "CustomerGroup" = N'',          
        "SalesDist" =N'',          
        "IncoTerms" = N'',          
 "PriceDate" = N'',          
 "QuotDate" =N'',       
 "QuotDeadline" = N'',          
 "Currency" = N'',          
 "Custom1" = @owner,          
 "Custom2" = isnull(CreditTerm,0),          
 "Custom3" = isnull(POReference,0),          
 "Custom4" = Sonumber,          
 "Custom5" = case            
    When len(@Branch)=0 then  N'' else 1 end, -- -> 1 Only When Enh_laptop = 1 and Branchcode <> nullString Else For all Null Value only  
 "Custom6" = N'',          
 "Custom7" = N'',          
 "Custom8" = N'',          
 "Custom9" = N'',          
 "Custom10" = N'',          
 "Custom11" = N'',          
 "Custom12" = N'',          
 "Custom13" = N'',          
 "Custom14" = N'',          
 "Custom15" = Isnull((Select SalesMan_Name from SalesMan where SalesManID = Isnull(SOAbstract.SalesManId,0)),N''),   
 "Poid" = ISnull(PODocReference,0),          
 "ModifiedFlag" = 0          
  FROM SOAbstract                  
  WHERE SONumber = @Cid          
END 
