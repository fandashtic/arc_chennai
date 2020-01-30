
Create Procedure mERP_sp_RFADisplayPrint(@RFADocID Int)  
As  
Declare @RFA_Value Decimal(18,6)  
Create Table #tempDisplaySchemeAbstract(RFADocID Int, DocumentID nVarchar(255),RFAID Int,Activity_Code nVarchar(255),[Description] nVarchar(255),Applicable_Period nVarchar(255),RFA_Period nVarchar(255),Submission_Date nVarchar(255))  
Create Table #tempDisplaySchemeDetail(Outlet_Code nVarchar(255),Name_of_Outlet nVarchar(255),Channel_Type nVarchar(255),Outlet_Type nVarchar(255),Loyalty_Program nVarchar(255),RFA_Value Decimal(18,6),RFAID Int)  
  
------Display Scheme Abstract  
 Insert Into #tempDisplaySchemeAbstract  
 Select   
 Distinct "RFADocID" = RFADocID,  
 "DocumentID" = [Documentid],  
 "RFAID" = [RFAID],  
 "Activity_Code" = ActivityCode,  
 "Description" = [Description],  
 "Applicable_Period" = (Convert(varchar, ActiveFrom, 103) + ' - ' + Convert(varchar, ActiveTo, 103)),  
 "RFA_Period" = (Convert(varchar, PayoutFrom, 103) + ' - ' + Convert(varchar, PayoutTo, 103)),  
 "Submission_Date" = dbo.stripTimeFromdate(SubmissionDate) From tbl_mERP_RFAAbstract   
 Where  SchemeType = 'Display' And RFADocID = (@RFADocID)and Isnull(Status,0)<>5  
      
------Display Scheme Detail       
 Insert Into #tempDisplaySchemeDetail Select   
 Distinct "Outlet_Code" = RD.CustomerID,  
 "Name_of_Outlet" = C.Company_Name,  
 "Channel_Type" = OL.Channel_Type_Desc,  
 "Outlet_Type" = OL.Outlet_Type_Desc,  
 "Loyalty_Program" = OL.SubOutlet_Type_Desc,  
 "RFA_Value" = Sum(RD.Rebatevalue),  
 "RFAID" = TD.RFAID  
 From tbl_mERP_RFAdetail RD   
 Join #tempDisplayschemeAbstract TD On TD.RFAID = RD.RFAID   
 Join Customer C On C.CustomerID = RD.CustomerID  
 Join tbl_mERP_OLClassMapping OLM On OLM.CustomerID = RD.CustomerID And OLM.Active = 1  
 Join tbl_mERP_OLClass OL On OLM.OLClassID=OL.ID  
 Group By RD.CustomerID,C.Company_Name,OL.Channel_Type_Desc,OL.Outlet_Type_Desc,OL.SubOutlet_Type_Desc,TD.RFAID  
  
  
Select Activity_Code ,[Description] ,Applicable_Period ,RFA_Period ,Submission_Date From #tempDisplaySchemeAbstract  
  
Select Outlet_Code, Name_of_Outlet, Channel_Type, Outlet_Type ,Loyalty_Program, RFA_Value From #tempDisplayschemeDetail  
  
Select  '','','','','',Sum(RFA_Value) From #tempDisplayschemeDetail   
  
  
Drop table #tempDisplayschemeAbstract  
Drop table #tempDisplayschemeDetail  
  
