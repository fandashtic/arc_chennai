CREATE Procedure spr_list_PartywisePackingwiseSales (@Customer nvarchar(2550),         
@BeatName nvarchar(2550), @FromDate DateTime, @ToDate DateTime)        
As        
Declare @OTHERS As NVarchar(50)    
Set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)      
Declare @Delimeter as Char(1)        
Set @Delimeter=Char(15)      
Declare @tmpCust table(Company_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
Declare @tmpBeat table(BeatName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
    
if @Customer=N'%'      
   insert into @tmpCust select company_name from customer      
else      
   insert into @tmpCust select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter)      
    
if @BeatName = N'%'    
 insert into @tmpBeat select [Description] from Beat    
else    
 insert into @tmpBeat select * from dbo.sp_SplitIn2Rows(@BeatName, @Delimeter)       
  
Select cu.CustomerID + Char(15) + cast(ia.BeatID as nvarchar), "Beat" = IsNull(Beat.Description, @OTHERS),   
cu.CustomerID "Customer ID", Company_Name "Customer Name",          
"Address" = IsNull(REPLACE(REPLACE(REPLACE(CU.BillingAddress, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''),'') ,
Sum((Case InvoiceType When 4 Then -1 Else 1 End) * Amount) "Net Value",         
Sum((Case InvoiceType When 4 Then -1 Else 1 End) * Quantity) "Total Quantity" From Customer cu         
Join InvoiceAbstract ia On cu.CustomerID = ia.CustomerID Join InvoiceDetail ide On        
ia.InvoiceID = ide.InvoiceID Left Outer Join Beat On ia.BeatId = Beat.BeatId     
Where IsNull(Company_Name, N'') In (select Company_Name COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpCust) And         
IsNull(Beat.Description, N'') In (select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS  from @tmpBeat) And    
InvoiceDate Between @FromDate And @ToDate And (IsNull(Status, 0) & 192) = 0 And InvoiceType != 2        
Group By  Company_Name, cu.CustomerID, ia.BeatID,Beat.Description, cu.BillingAddress    
Order By Beat.Description    

