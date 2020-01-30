CREATE procedure Sp_Print_PlanSlipAbstract (@Customerid nvarchar(500))                                
As                                    
Set Nocount On                
Set Dateformat DMY
declare @Salesman_tmp nvarchar(200)                
exec SPR_Split_Values_Plan @Customerid,1,@Salesman_tmp output                
                
declare @WCPcode_tmp nvarchar(200)                
exec SPR_Split_Values_Plan @Customerid,2,@WCPcode_tmp output                
                
declare @Customerid_tmp nvarchar(200)                
exec SPR_Split_Values_Plan @Customerid,3,@Customerid_tmp output                
              
Declare @CampaignName_Tmp nVarchar(4000)  
exec Spr_Get_CampaignName @Customerid_tmp,1,@CampaignName_Tmp OutPut              

if @CampaignName_Tmp='0'            
	Set @CampaignName_Tmp=''            

declare @Date_tmp nvarchar(30)
exec SPR_Split_Values_Plan @Customerid,6,@Date_tmp output                


Declare @CampaignName_Tmp_Others nVarchar(4000)              
exec Spr_Get_CampaignName @Customerid_tmp,0,@CampaignName_Tmp_Others OutPut              
if @CampaignName_Tmp_Others='0'            
	Set @CampaignName_Tmp_Others=''            

-- To get Item count  
declare @Order_tmp nvarchar(200)        
exec SPR_Split_Values_Plan @Customerid,4,@Order_tmp output        
Create Table #TmpItem ([Item Code] nVarchar(15))  
  
if @Order_tmp <>'0'        
 Insert Into #TmpItem       
  select         
  i.Product_code        
  from Items i,orderdetail o        
  where o.product_code = i.product_code and        
  o.docserial = @Order_tmp        
else        
 Insert Into #TmpItem       
  Select         
  i.Product_code      
  From Items i  
Set NoCount Off                  

Select "Salesman ID" = WCPA.SalesmanID,                     
"Salesman Name" = S.Salesman_Name,
"Date" = @Date_tmp,  
"Customer ID" = WCPD.CustomerID ,                     
"WCP WeekDate" =dbo.stripdatefromtime ( WCPA.WeekDate) ,                    
"Beat" = (Select [Description] From Beat Where Beat.BeatID = (Select IsNull(BEATID,0) from beat_Salesman BS, Customer CUST Where BS.CustomerID = CUST.CustomerID And CUST.CustomerID = WCPD.CustomerID)),                    
"Customer Name" = CUST.Company_Name ,                    
"Volume Objective" = (Select SUM(Volume) From CustomerObjective CO Where CO.objyear = YEAR(WCPD.WCPDate) And CO.objmonth = MONTH(WCPD.WCPDate) And CO.CustomerID = WCPD.CustomerID),                    
"OHD Objective" = (Select Objective From CampaignMaster Where CampaignName = 'OHD' And Dbo.StripDateFromTime(WCPA.WeekDate) <= Dbo.StripDateFromTime(Todate)   ),          
"Campaign Name Default" = Replace(@CampaignName_Tmp,':',Char(9)),
"Campaign Name Others" = Replace(@CampaignName_Tmp_Others,':',Char(9)),
"OutStanding" = (Select SUM(Balance) From InvoiceAbstract Where CustomerID = WCPD.CustomerID And Dbo.StripDateFromTime(InvoiceDate) <= Dbo.StripDateFromTime(WCPA.WeekDate)),
"Remarks" = '',
"Item Count" = (Select count(Distinct([Item Code])) From #TmpItem)  
From WCPAbstract WCPA, WCPDetail WCPD , Salesman S, Customer Cust                    
Where WCPA.Code = WCPD.Code                     
And S.Salesmancode = WCPA.Salesmanid                     
And Cust.Customerid = WCPD.Customerid                     
And WCPA.SalesmanID = @Salesman_tmp                
And WCPD.CustomerID = @Customerid_tmp                
And WCPA.Code = @WCPcode_tmp                
And dbo.stripdatefromtime (WCPA.WeekDate) = dbo.stripdatefromtime (WCPD.WcpDate)


